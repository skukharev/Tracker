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
    private let emptyWeek: Week = []
    private let scheduleKeyPath = #keyPath(TrackerCoreData.schedule)

    // MARK: - Private Properties

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "category.name", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.context,
            sectionNameKeyPath: #keyPath(TrackerCoreData.category.name),
            cacheName: nil
        )
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
        trackerCoreData.schedule = tracker.schedule as NSObject
        trackerCoreData.category = category
    }
}

// MARK: - TrackerStoreProtocol

extension TrackerStore: TrackerStoreProtocol {
    func categoryName(_ section: Int) -> String {
        return fetchedResultsController.sections?[safe: section]?.name ?? ""
    }

    func loadData(atDate currentDate: Date) {
        guard let dayOfTheWeek = Weekday.dayOfTheWeek(of: currentDate) else {
            assertionFailure("Ошибка определения дня недели на основании текущей даты")
            return
        }

        let scheduledTrackers = NSPredicate(format: "%K CONTAINS %ld", scheduleKeyPath, dayOfTheWeek.rawValue)
        let nonscheduledTrackers = NSPredicate(format: "%K = %@ AND SUBQUERY(%K, $X, $X.trackerId = SELF.id).@count = 0", scheduleKeyPath, emptyWeek, #keyPath(TrackerCoreData.dates))
        let nonscheduledAndCompletedTrackers = NSPredicate(format: "%K = %@ AND ANY %K = %@", scheduleKeyPath, emptyWeek, #keyPath(TrackerCoreData.dates.recordDate), currentDate as NSDate)
        let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [scheduledTrackers, nonscheduledTrackers, nonscheduledAndCompletedTrackers])
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
        let schedule = record.schedule as? Week ?? []
        return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule)
    }
}
