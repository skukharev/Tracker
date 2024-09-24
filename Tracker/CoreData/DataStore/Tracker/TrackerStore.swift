//
//  TrackerStore.swift
//  Tracker
//
//  Created by Сергей Кухарев on 23.08.2024.
//

import Foundation
import CoreData
import UIKit

final class TrackerStore: NSObject {
    // MARK: - Constants

    static let shared = TrackerStore()
    private let context: NSManagedObjectContext
    private let scheduleKeyPath = #keyPath(TrackerCoreData.schedule)
    private let trackerCategoryNameKeyPath = #keyPath(TrackerCoreData.category.name)
    private let trackerNameKeyPath = #keyPath(TrackerCoreData.name)
    private let isFixedKeyPath = #keyPath(TrackerCoreData.isFixed)

    // MARK: - Public Properties

    weak var delegate: TrackerStoreDelegate?

    // MARK: - Private Properties

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: trackerCategoryNameKeyPath, ascending: true),
            NSSortDescriptor(key: trackerNameKeyPath, ascending: true)
        ]
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.context,
            sectionNameKeyPath: #keyPath(TrackerCoreData.category.name),
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    private lazy var fixedFetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: trackerNameKeyPath, ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()

    // MARK: - Initializers

    override convenience init() {
        self.init(context: Database.shared.context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Public Methods

    /// Удаляет трекер на основании его индекса в отображаемой коллекции
    /// - Parameters
    ///   - indexPath: Индекс трекера в отображаемой коллекции
    ///   - completion: Обработчик, вызываемый по окончании выполнения метода, который возвращает ошибку при её возникновении в момент удаления
    public func deleteTracker(at indexPath: IndexPath, _ completion: ((Result<Void, Error>) -> Void)? = nil) {
        let record = fetchedResultsController.object(at: indexPath)
        do {
            context.delete(record)
            try context.save()
            completion?(.success(()))
        } catch let error {
            context.rollback()
            completion?(.failure(error))
            assertionFailure("При удалении трекера произошла ошибка \(error.localizedDescription)")
        }
    }

    /// Добавляет / изменяет трекер в базу данных
    /// - Parameters:
    ///   - tracker: данные атрибутов трекера
    ///   - categoryID: идентификатор категории трекера в базе данных
    /// - Returns: идентификатор трекера в базе данных
    public func saveTracker(_ tracker: Tracker, withCategoryID categoryID: NSManagedObjectID) -> NSManagedObjectID? {
        guard let category = try? context.existingObject(with: categoryID) as? TrackerCategoryCoreData else {
            assertionFailure("В базе данных не найдена категория с идентификатором \(categoryID)")
            return nil
        }
        let trackerCoreData = getTrackerCoreData(withId: tracker.id.uuidString) ?? TrackerCoreData(context: context)
        updateExistingTracker(trackerCoreData, withCategory: category, withTracker: tracker)
        do {
            try context.save()
            return trackerCoreData.objectID
        } catch let error {
            context.rollback()
            assertionFailure("При записи трекера в базу данных произошла ошибка \(error.localizedDescription)")
            return nil
        }
    }

    /// Возвращает ссылку на объект трекера в базе данных по заданному идентификатору трекера
    /// - Parameter id: Идентификатор трекера
    /// - Returns: ссылка на объект трекера в базе данных
    public func getTrackerCoreData(withId id: String) -> TrackerCoreData? {
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        request.returnsObjectsAsFaults = false
        request.resultType = .managedObjectIDResultType
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "id == %@", id)
        guard
            let trackers = try? context.execute(request) as? NSAsynchronousFetchResult<NSFetchRequestResult>,
            let trackerID = trackers.finalResult?.first as? NSManagedObjectID,
            let trackerRecord = try? context.existingObject(with: trackerID) as? TrackerCoreData
        else {
            return nil
        }
        return trackerRecord
    }

    /// Включает/исключает трекер из списка закреплённых трекеров
    /// - Parameters
    ///   - indexPath: Индекс трекера в отображаемой коллекции
    ///   - completion: Обработчик, вызываемый по окончании выполнения метода, который возвращает ошибку при её возникновении в момент записи
    public func toggleFixTracker(at indexPath: IndexPath, _ completion: ((Result<Void, Error>) -> Void)? = nil) {
        var record: TrackerCoreData
        let fixedSectionsCount = (fixedFetchedResultsController.fetchedObjects?.count ?? 0) > 0 ? 1 : 0
        if indexPath.section == 0 && fixedSectionsCount > 0 {
            record = fixedFetchedResultsController.object(at: indexPath)
        } else {
            record = fetchedResultsController.object(at: indexPath)
        }
        record.isFixed.toggle()
        do {
            try context.save()
            completion?(.success(()))
        } catch let error {
            context.rollback()
            completion?(.failure(error))
            assertionFailure("При записи трекера произошла ошибка \(error.localizedDescription)")
        }
    }

    // MARK: - Private Methods

    /// Конвертирует дни недели трекера в строковое представление для хранения в базе данных
    /// - Parameter schedule: Дни недели повторения трекера
    /// - Returns: Строковое представление расписания трекера для хранения в базе данных
    private func convertScheduleToString(_ schedule: Week) -> String {
        var result = "["
        schedule.forEach { element in
            result += element.rawValue.intToString
        }
        result += "]"
        return result
    }

    /// Конвертирует строковое представление расписания трекера, хранимое в базе данных, в представление, используемое в приложении
    /// - Parameter schedule: Строковое представление расписания трекера
    /// - Returns: Представление расписания трекера, используемое в приложении
    private func convertStringToSchedule(_ schedule: String) -> Week {
        var result: Week = []
        schedule.forEach { char in
            switch char {
            case "0":
                result.insert(.monday)
            case "1":
                result.insert(.tuesday)
            case "2":
                result.insert(.wednesday)
            case "3":
                result.insert(.thursday)
            case "4":
                result.insert(.friday)
            case "5":
                result.insert(.saturday)
            case "6":
                result.insert(.sunday)
            default:
                break
            }
        }
        return result
    }

    /// Используется для заполнения записи в базе данных по трекеру перед добавлением / изменением
    /// - Parameters:
    ///   - trackerCoreData: Ссылка на экземпляр записи сущности TrackerCoreData в базе данных
    ///   - category: Ссылка на экземпляр записи сущности TrackerCategoryCoreData в базе данных
    ///   - tracker: заполненная структура с атрибутами трекера
    private func updateExistingTracker(_ trackerCoreData: TrackerCoreData, withCategory category: TrackerCategoryCoreData, withTracker tracker: Tracker) {
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = tracker.color
        trackerCoreData.schedule = convertScheduleToString(tracker.schedule)
        trackerCoreData.isFixed = tracker.isFixed
        trackerCoreData.category = category
    }
}

// MARK: - TrackerStoreProtocol

extension TrackerStore: TrackerStoreProtocol {
    func categoryName(_ section: Int) -> String {
        let fixedSectionsCount = (fixedFetchedResultsController.fetchedObjects?.count ?? 0) > 0 ? 1 : 0
        if section == 0 && fixedSectionsCount > 0 {
            return L10n.fixedTrackersSectionTitle
        } else {
            let modifiedSection = fixedSectionsCount > 0 ? section - 1 : section
            return fetchedResultsController.sections?[safe: modifiedSection]?.name ?? ""
        }
    }

    func loadData(atDate currentDate: Date, withTrackerSearchFilter searchFilter: String?, withTrackersFilter trackersFilter: TrackersFilter) {
        guard let dayOfTheWeek = Weekday.dayOfTheWeek(of: currentDate) else {
            assertionFailure("Ошибка определения дня недели на основании текущей даты")
            return
        }

        let scheduledTrackers = NSPredicate(format: "%K CONTAINS[c] %@", scheduleKeyPath, dayOfTheWeek.rawValue.intToString)
        let nonscheduledTrackers = NSPredicate(format: "%K = %@ AND SUBQUERY(%K, $X, $X.trackerId = SELF.id).@count = 0", scheduleKeyPath, "[]", #keyPath(TrackerCoreData.dates))
        let nonscheduledAndCompletedTrackers = NSPredicate(format: "%K = %@ AND ANY %K = %@", scheduleKeyPath, "[]", #keyPath(TrackerCoreData.dates.recordDate), currentDate as NSDate)
        var compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [scheduledTrackers, nonscheduledTrackers, nonscheduledAndCompletedTrackers])
        if
            let searchFilter = searchFilter,
            !searchFilter.isEmpty {
            let filteredTrackers = NSPredicate(format: "%K CONTAINS[c] %@", trackerNameKeyPath, searchFilter)
            let filteredCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [compoundPredicate, filteredTrackers])
            compoundPredicate = filteredCompoundPredicate
        }
        let nonFixedTrackers = NSPredicate(format: "%K = false", isFixedKeyPath)
        compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [compoundPredicate, nonFixedTrackers])
        fetchedResultsController.fetchRequest.predicate = compoundPredicate

        let fixedCompoundPredicate = NSPredicate(format: "%K = true", isFixedKeyPath)
        fixedFetchedResultsController.fetchRequest.predicate = fixedCompoundPredicate

        do {
            try fetchedResultsController.performFetch()
            try fixedFetchedResultsController.performFetch()
            let allRecordsCount = (fetchedResultsController.fetchedObjects?.count ?? 0) + (fixedFetchedResultsController.fetchedObjects?.count ?? 0)
            if trackersFilter == .complitedTrackers {
                let complitedTrackers = NSPredicate(format: "ANY %K = %@", #keyPath(TrackerCoreData.dates.recordDate), currentDate as NSDate)
                fetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [compoundPredicate, complitedTrackers])
                fixedFetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fixedCompoundPredicate, complitedTrackers])
                try fetchedResultsController.performFetch()
                try fixedFetchedResultsController.performFetch()
            }
            if trackersFilter == .notComplitedTrackers {
                let complitedTrackers = NSPredicate(format: "SUBQUERY(%K, $X, $X.recordDate = %@).@count = 0", #keyPath(TrackerCoreData.dates), currentDate as NSDate)
                fetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [compoundPredicate, complitedTrackers])
                fixedFetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fixedCompoundPredicate, complitedTrackers])
                try fetchedResultsController.performFetch()
                try fixedFetchedResultsController.performFetch()
            }
            let allFilteredRecordsCount = (fetchedResultsController.fetchedObjects?.count ?? 0) + (fixedFetchedResultsController.fetchedObjects?.count ?? 0)
            delegate?.didUpdate(recordCounts: RecordCounts(allRecordsCount: allRecordsCount, filteredRecordsCount: allFilteredRecordsCount))
        } catch {
            assertionFailure("Произошла ошибка при выполнении запроса к базе данных: \(error)")
        }
    }

    func numberOfCategories() -> Int {
        let fixedSectionsCount = (fixedFetchedResultsController.fetchedObjects?.count ?? 0) > 0 ? 1 : 0
        let sectionsCount = fetchedResultsController.sections?.count ?? 0
        return (sectionsCount + fixedSectionsCount)
    }

    func numberOfTrackersInCategory(_ section: Int) -> Int {
        let fixedSectionsCount = (fixedFetchedResultsController.fetchedObjects?.count ?? 0) > 0 ? 1 : 0
        if section == 0 && fixedSectionsCount > 0 {
            return fixedFetchedResultsController.sections?[section].numberOfObjects ?? 0
        } else {
            let modifiedSection = fixedSectionsCount > 0 ? section - 1 : section
            return fetchedResultsController.sections?[modifiedSection].numberOfObjects ?? 0
        }
    }

    func tracker(at indexPath: IndexPath) -> Tracker? {
        var record: TrackerCoreData
        let fixedSectionsCount = (fixedFetchedResultsController.fetchedObjects?.count ?? 0) > 0 ? 1 : 0
        if indexPath.section == 0 && fixedSectionsCount > 0 {
            record = fixedFetchedResultsController.object(at: indexPath)
        } else {
            let modifiedIndexPath = fixedSectionsCount > 0 ? IndexPath(row: indexPath.row, section: indexPath.section - 1) : indexPath
            record = fetchedResultsController.object(at: modifiedIndexPath)
        }
        guard
            let id = record.id,
            let name = record.name,
            let color = record.color as? UIColor,
            let emoji = record.emoji,
            let categoryName = record.category?.name
        else {
            return nil
        }
        let schedule = convertStringToSchedule(record.schedule ?? "")
        let trackerType = schedule.isEmpty ? TrackerType.event : TrackerType.habit
        return Tracker(trackerType: trackerType, categoryName: categoryName, id: id, name: name, color: color, emoji: emoji, schedule: schedule, isFixed: record.isFixed)
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate()
    }
}
