//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Сергей Кухарев on 23.08.2024.
//

import Foundation
import CoreData

final class TrackerRecordStore {
    // MARK: - Constants

    static let shared = TrackerRecordStore()
    private let context: NSManagedObjectContext
    private let trackerStore = TrackerStore.shared
    private let recordDateKeyPath = #keyPath(TrackerRecordCoreData.recordDate)
    private let trackerIdKeyPath = #keyPath(TrackerRecordCoreData.trackerId)

    // MARK: - Initializers

    convenience init() {
        self.init(context: Database.shared.context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Public Methods

    /// Используется на экране статистики - вычисляет общее количество выполненных трекеров
    /// - Returns: результат вычислений
    public func getCompletedTrackerCount() -> Int {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.resultType = .countResultType
        guard
            let records = try? context.execute(request) as? NSAsynchronousFetchResult<NSFetchRequestResult>,
            let recordsCount = records.finalResult?.first as? Int
        else {
            return 0
        }
        return recordsCount
    }

    /// Используется на экране статистики - вычисляет среднее количество трекеров, выполняемых в день
    /// - Returns: результат вычислений
    public func getAverageTrackersCompletionPerDay() -> Int {
        let dateDescription = NSExpressionDescription()
        dateDescription.name = "date"
        dateDescription.expression = NSExpression(forKeyPath: recordDateKeyPath)
        dateDescription.expressionResultType = .dateAttributeType

        let countDescription = NSExpressionDescription()
        countDescription.name = "trackersCount"
        countDescription.expression = NSExpression(forFunction: "count:", arguments: [NSExpression(forKeyPath: trackerIdKeyPath)])
        countDescription.expressionResultType = .integer64AttributeType

        let completedTrackersCountRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerRecordCoreData")
        completedTrackersCountRequest.propertiesToFetch = [dateDescription, countDescription]
        completedTrackersCountRequest.propertiesToGroupBy = [dateDescription]
        completedTrackersCountRequest.resultType = .dictionaryResultType

        guard let results = try? context.fetch(completedTrackersCountRequest) as? [[String: Any]] else {
            return 0
        }
        var datesCount = 0
        var totalTrackersCount = 0
        for result in results {
            if let trackersCount = result["trackersCount"] as? Int {
                totalTrackersCount += trackersCount
                datesCount += 1
            }
        }
        return Int(datesCount > 0 ? Double(totalTrackersCount) / Double(datesCount) : 0)
    }

    /// Используется на экране статистики - вычисляет количество "идеальных" дней, в которые были выполнены все запланированные трекеры
    /// - Returns: результат вычислений
    public func getIdealCompletionDatesCount() -> Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerRecordCoreData")
        let dateExpression = NSExpression(forKeyPath: recordDateKeyPath)
        let dateDescription = NSExpressionDescription()
        dateDescription.name = "serviceDate"
        dateDescription.expression = dateExpression
        dateDescription.expressionResultType = .dateAttributeType
        fetchRequest.propertiesToFetch = [dateDescription]
        fetchRequest.propertiesToGroupBy = [dateDescription]
        fetchRequest.resultType = .dictionaryResultType

        guard let dates = try? context.fetch(fetchRequest) as? [[String: Any]] else {
            return 0
        }
        let uniqueDates = dates.compactMap { $0["serviceDate"] as? Date }
        var idealDaysCount = 0
        for date in uniqueDates where trackerStore.checkScheduledTrackersForCompletion(at: date) {
            idealDaysCount += 1
        }
        return idealDaysCount
    }

    /// Производит обработку выполнения трекера:
    ///  - при отсутствии события выполнения на заданную дату записывает факт выполнения трекера
    ///  - при наличии события выполнения трекера удаляет факт выполнения трекера на заданную дату
    /// - Parameter trackerRecord: структура с атрибутами трекера
    func processTracker(_ trackerRecord: TrackerRecord) {
        /// Поиск трекера в базе данных по его идентификатору
        guard let tracker = trackerStore.getTrackerCoreData(withId: trackerRecord.trackerId.uuidString) else {
            assertionFailure("Трекер с идентификатором '\(trackerRecord.trackerId)' не найден в базе данных")
            return
        }
        /// Обработка события трекера
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.resultType = .managedObjectIDResultType
        request.fetchLimit = 1
        request.predicate = NSPredicate(
            format: "%K == %@ AND %K == %@",
            #keyPath(TrackerRecordCoreData.recordDate),
            trackerRecord.recordDate as NSDate,
            #keyPath(TrackerRecordCoreData.trackerId),
            trackerRecord.trackerId.uuidString
        )
        if
            let trackerRecord = try? context.execute(request) as? NSAsynchronousFetchResult<NSFetchRequestResult>,
            let trackerRecordID = trackerRecord.finalResult?.first as? NSManagedObjectID,
            let trackerRecordData = try? context.existingObject(with: trackerRecordID) as? TrackerRecordCoreData {
            /// Удаление события трекера, в случае его существования в базе
            context.delete(trackerRecordData)
        } else {
            /// Создание события трекера в базе данных
            let trackerRecordCoreData = TrackerRecordCoreData(context: context)
            trackerRecordCoreData.recordDate = trackerRecord.recordDate
            trackerRecordCoreData.trackerId = trackerRecord.trackerId
            trackerRecordCoreData.tracker = tracker
        }
        do {
            try context.save()
        } catch let error {
            context.rollback()
            assertionFailure("При записи события трекера в базу данных произошла ошибка \(error.localizedDescription)")
        }
    }

    /// Определяет, был ли выполнен заданный трекер в заданную дату
    /// - Parameters:
    ///   - trackerId: Идентификатор трекера
    ///   - currentDate: Дата
    /// - Returns: Возвращает истину, если трекер был выполнен в заданную дату; возвращает ложь в противном случае
    func isTrackerCompletedOnDate(withId trackerId: UUID, atDate currentDate: Date) -> Bool {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.resultType = .countResultType
        request.predicate = NSPredicate(format: "%K == %@ AND %K == %@", #keyPath(TrackerRecordCoreData.trackerId), trackerId.uuidString, #keyPath(TrackerRecordCoreData.recordDate), currentDate as NSDate)
        guard
            let records = try? context.execute(request) as? NSAsynchronousFetchResult<NSFetchRequestResult>,
            let recordsCount = records.finalResult?.first as? Int
        else {
            return false
        }
        return recordsCount > 0 ? true : false
    }

    /// Используется для вычисления количества выполнений заданного трекера
    /// - Parameter trackerId: Идентификатор трекера
    /// - Returns: Общее количество выполнений заданного трекера
    func trackersRecordCount(withId trackerId: UUID) -> Int {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.resultType = .countResultType
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerRecordCoreData.trackerId), trackerId.uuidString)
        guard
            let records = try? context.execute(request) as? NSAsynchronousFetchResult<NSFetchRequestResult>,
            let recordsCount = records.finalResult?.first as? Int
        else {
            return 0
        }
        return recordsCount
    }
}
