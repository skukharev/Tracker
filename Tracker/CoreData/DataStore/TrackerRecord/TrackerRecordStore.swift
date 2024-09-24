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

    // MARK: - Initializers

    convenience init() {
        self.init(context: Database.shared.context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Public Methods

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
