//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Сергей Кухарев on 23.08.2024.
//

import Foundation
import CoreData

final class TrackerCategoryStore {
    // MARK: - Constants

    private let context: NSManagedObjectContext

    // MARK: - Initializers

    convenience init() {
        self.init(context: Database.shared.context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Public Methods

    /// Добавляет / изменяет категорию трекеров
    /// - Parameter categoryName: Наименование категории трекера
    /// - Returns: Идентификатор категории трекеров в базе данных
    func addTrackerCategory(withName categoryName: String) -> NSManagedObjectID? {
        var trackerCategoryCoreData: TrackerCategoryCoreData?
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.returnsObjectsAsFaults = false
        request.resultType = .managedObjectIDResultType
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "%K =[c] %@", #keyPath(TrackerCategoryCoreData.name), categoryName)
        if
            let categories = try? context.execute(request) as? NSAsynchronousFetchResult<NSFetchRequestResult>,
            let categoryID = categories.finalResult?.first as? NSManagedObjectID,
            let categoryRecord = try? context.existingObject(with: categoryID) as? TrackerCategoryCoreData {
            trackerCategoryCoreData = categoryRecord
        } else {
            trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        }
        guard let trackerCategoryCoreData = trackerCategoryCoreData else { return nil }
        updateExistingCategory(trackerCategoryCoreData, with: categoryName)
        do {
            try context.save()
            return trackerCategoryCoreData.objectID
        } catch let error {
            context.rollback()
            assertionFailure("При записи категории в базу данных произошла ошибка \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Private Methods

    /// Используется для заполнения записи в базе данных по категории трекера перед добавлением / изменением
    /// - Parameters:
    ///   - trackerCategoryCoreData: Ссылка на экземпляр категории трекеров в базе данных
    ///   - name: Наименование категории трекера
    private func updateExistingCategory(_ trackerCategoryCoreData: TrackerCategoryCoreData, with name: String) {
        trackerCategoryCoreData.name = name
    }
}
