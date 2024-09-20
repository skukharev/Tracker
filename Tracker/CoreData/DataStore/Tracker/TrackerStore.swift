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

    private let context: NSManagedObjectContext
    private let scheduleKeyPath = #keyPath(TrackerCoreData.schedule)
    private let trackerCategoryNameKeyPath = #keyPath(TrackerCoreData.category.name)
    private let trackerNameKeyPath = #keyPath(TrackerCoreData.name)

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
    private var insertedPaths: [IndexPath] = []
    private var deletedPaths: [IndexPath] = []
    private var insertedSectionIndexes: IndexSet?
    private var deletedSectionIndexes: IndexSet?
    // MARK: - Initializers

    override convenience init() {
        self.init(context: Database.shared.context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Public Methods

    /// Добавляет / изменяет трекер в базу данных
    /// - Parameters:
    ///   - tracker: данные атрибутов трекера
    ///   - categoryID: идентификатор категории трекера в базе данных
    /// - Returns: идентификатор трекера в базе данных
    public func addTracker(_ tracker: Tracker, withCategoryID categoryID: NSManagedObjectID) -> NSManagedObjectID? {
        /// Получение ссылки на запись БД с категорией трекера
        guard let category = try? context.existingObject(with: categoryID) as? TrackerCategoryCoreData else {
            assertionFailure("В базе данных не найдена категория с идентификатором \(categoryID)")
            return nil
        }
        /// Инициализация ссылки на запись БД с трекером
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

    // MARK: - Private Methods

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
        trackerCoreData.category = category
    }
}

// MARK: - TrackerStoreProtocol

extension TrackerStore: TrackerStoreProtocol {
    func categoryName(_ section: Int) -> String {
        return fetchedResultsController.sections?[safe: section]?.name ?? ""
    }

    func loadData(atDate currentDate: Date, withTrackerFilter filter: String?) {
        guard let dayOfTheWeek = Weekday.dayOfTheWeek(of: currentDate) else {
            assertionFailure("Ошибка определения дня недели на основании текущей даты")
            return
        }

        let scheduledTrackers = NSPredicate(format: "%K CONTAINS[c] %@", scheduleKeyPath, dayOfTheWeek.rawValue.intToString)
        let nonscheduledTrackers = NSPredicate(format: "%K = %@ AND SUBQUERY(%K, $X, $X.trackerId = SELF.id).@count = 0", scheduleKeyPath, "[]", #keyPath(TrackerCoreData.dates))
        let nonscheduledAndCompletedTrackers = NSPredicate(format: "%K = %@ AND ANY %K = %@", scheduleKeyPath, "[]", #keyPath(TrackerCoreData.dates.recordDate), currentDate as NSDate)
        var compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [scheduledTrackers, nonscheduledTrackers, nonscheduledAndCompletedTrackers])
        if
            let filter = filter,
            !filter.isEmpty {
            let filteredTrackers = NSPredicate(format: "%K CONTAINS[c] %@", trackerNameKeyPath, filter)
            let filteredCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [compoundPredicate, filteredTrackers])
            compoundPredicate = filteredCompoundPredicate
        }
        fetchedResultsController.fetchRequest.predicate = compoundPredicate
        do {
            try fetchedResultsController.performFetch()
        } catch {
            assertionFailure("Произошла ошибка при выполнении запроса к базе данных: \(error)")
        }
    }

    func numberOfCategories() -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    func numberOfTrackersInCategory(_ section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func tracker(at indexPath: IndexPath) -> Tracker? {
        let record = fetchedResultsController.object(at: indexPath)
        guard
            let id = record.id,
            let name = record.name,
            let color = record.color as? UIColor,
            let emoji = record.emoji
        else {
            return nil
        }
        let schedule = convertStringToSchedule(record.schedule ?? "")
        return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule)
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerStore: NSFetchedResultsControllerDelegate {
    /// Метод controllerWillChangeContent срабатывает перед тем, как изменится состояние объектов, которые добавляются или удаляются. В нём мы инициализируем переменные, которые содержат индексы изменённых объектов
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedSectionIndexes = IndexSet()
        deletedSectionIndexes = IndexSet()
        insertedPaths = []
        deletedPaths = []
    }

    /// Метод controllerDidChangeContent срабатывает после добавления или удаления объектов. В нём мы передаём индексы изменённых объектов в класс MainViewController и очищаем до следующего изменения переменные, которые содержат индексы.
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(
            TrackerStoreUpdate(
                insertedSectionIndexes: insertedSectionIndexes,
                deletedSectionIndexes: deletedSectionIndexes,
                insertedPaths: insertedPaths,
                deletedPaths: deletedPaths
            )
        )
        insertedSectionIndexes = nil
        deletedSectionIndexes = nil
        insertedPaths = []
        deletedPaths = []
    }

    /// Метод controller(_: didChange anObject) срабатывает после того как изменится состояние конкретного объекта. Мы добавляем индекс изменённого объекта в соответствующий набор индексов: deletedIndexes — для удалённых объектов, insertedIndexes — для добавленных.
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                insertedPaths.append(indexPath)
            }
        case .delete:
            if let indexPath = indexPath {
                deletedPaths.append(indexPath)
            }
        case .move:
            break
        case .update:
            break
        @unknown default:
            break
        }
    }

    /// Метод controller(: didChange sectionInfo) срабатывает после того, как изменится состояние конкретной секции объектов,
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            insertedSectionIndexes?.insert(sectionIndex)
        case .delete:
            deletedSectionIndexes?.insert(sectionIndex)
        case .move:
            break
        case .update:
            break
        @unknown default:
            break
        }
    }
}
