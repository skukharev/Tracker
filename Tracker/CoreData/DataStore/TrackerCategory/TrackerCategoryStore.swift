//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Сергей Кухарев on 23.08.2024.
//

import Foundation
import CoreData

final class TrackerCategoryStore: NSObject {
    // MARK: - Constants

    private let context: NSManagedObjectContext
    private let trackerCategoryNameKeyPath = #keyPath(TrackerCategoryCoreData.name)
    static let shared = TrackerCategoryStore()


    // MARK: - Public Properties

    weak var delegate: TrackerCategoryStoreDelegate?

    // MARK: - Private Properties

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: trackerCategoryNameKeyPath, ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?

    // MARK: - Initializers

    override convenience init() {
        self.init(context: Database.shared.context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Public Methods

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

    func checkCategory(withName categoryName: String?, withModel category: NewCategoryModel?) -> Result<Void, Error> {
        do {
            try validateOnAllowedName(categoryName)
            if category == nil || (category != nil && categoryName != category?.name) {
                try validateOnExistingCategory(categoryName)
            }
        } catch {
            return .failure(error)
        }
        return .success(())
    }

    func checkCategoryDelete(withName categoryName: String) -> Bool {
        var result = true
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.returnsObjectsAsFaults = false
        request.resultType = .managedObjectIDResultType
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "%K =[c] %@", #keyPath(TrackerCategoryCoreData.name), categoryName)
        if
            let categories = try? context.execute(request) as? NSAsynchronousFetchResult<NSFetchRequestResult>,
            let categoryID = categories.finalResult?.first as? NSManagedObjectID,
            let categoryRecord = try? context.existingObject(with: categoryID) as? TrackerCategoryCoreData {
            if
                let trackers = categoryRecord.trackers,
                trackers.count >= 1 {
                result = false
            }
        }
        return result
    }

    func deleteCategory(withName categoryName: String) {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.returnsObjectsAsFaults = false
        request.resultType = .managedObjectIDResultType
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "%K =[c] %@", #keyPath(TrackerCategoryCoreData.name), categoryName)
        if
            let categories = try? context.execute(request) as? NSAsynchronousFetchResult<NSFetchRequestResult>,
            let categoryID = categories.finalResult?.first as? NSManagedObjectID,
            let categoryRecord = try? context.existingObject(with: categoryID) {
            do {
                context.delete(categoryRecord)
                try context.save()
            } catch let error {
                context.rollback()
                assertionFailure("При удалении категории из базы данных произошла ошибка \(error.localizedDescription)")
            }
        }
    }

    func editTrackerCategory(withName categoryName: String, andNewName newCategoryName: String) -> Bool {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.returnsObjectsAsFaults = false
        request.resultType = .managedObjectIDResultType
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "%K =[c] %@", #keyPath(TrackerCategoryCoreData.name), categoryName)
        guard
            let categories = try? context.execute(request) as? NSAsynchronousFetchResult<NSFetchRequestResult>,
            let categoryID = categories.finalResult?.first as? NSManagedObjectID,
            let categoryRecord = try? context.existingObject(with: categoryID) as? TrackerCategoryCoreData
        else { return false }
        let trackerCategoryCoreData = categoryRecord
        updateExistingCategory(trackerCategoryCoreData, with: newCategoryName)
        do {
            try context.save()
            return true
        } catch let error {
            context.rollback()
            assertionFailure("При записи категории в базу данных произошла ошибка \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Private Methods

    private func updateExistingCategory(_ trackerCategoryCoreData: TrackerCategoryCoreData, with name: String) {
        trackerCategoryCoreData.name = name
    }

    private func validateOnAllowedName(_ categoryName: String?) throws {
        guard let categoryName = categoryName else {
            throw TrackerCategoryError.emptyCategoryName
        }
        if categoryName.isEmpty {
            throw TrackerCategoryError.emptyCategoryName
        }
    }

    private func validateOnExistingCategory(_ categoryName: String?) throws {
        guard let categoryName = categoryName else { return }
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.returnsObjectsAsFaults = false
        request.resultType = .managedObjectIDResultType
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "%K =[c] %@", #keyPath(TrackerCategoryCoreData.name), categoryName)
        guard
            let categories = try? context.execute(request) as? NSAsynchronousFetchResult<NSFetchRequestResult>,
            categories.finalResult?.first != nil
        else { return }
        throw TrackerCategoryError.categoryNameAlreadyExists
    }
}

// MARK: - TrackerCategoryProtocol

extension TrackerCategoryStore: TrackerCategoryProtocol {
    func category(at indexPath: IndexPath) -> String? {
        let record = fetchedResultsController.object(at: indexPath)
        guard
            let categoryName = record.name
        else {
            return nil
        }
        return categoryName
    }

    func numberOfCategories() -> Int {
        return fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    /// Метод controllerWillChangeContent срабатывает перед тем, как изменится состояние объектов, которые добавляются или удаляются. В нём мы инициализируем переменные, которые содержат индексы изменённых объектов
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
    }

    /// Метод controllerDidChangeContent срабатывает после добавления или удаления объектов. В нём мы передаём индексы изменённых объектов в класс MainViewController и очищаем до следующего изменения переменные, которые содержат индексы.
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(
            TrackerCategoryStoreUpdate(
                insertedIndexes: insertedIndexes,
                deletedIndexes: deletedIndexes,
                updatedIndexes: updatedIndexes
            )
        )
        insertedIndexes = nil
        deletedIndexes = nil
        updatedIndexes = nil
    }

    /// Метод controller(_: didChange anObject) срабатывает после того как изменится состояние конкретного объекта. Мы добавляем индекс изменённого объекта в соответствующий набор индексов: deletedIndexes — для удалённых объектов, insertedIndexes — для добавленных.
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexes?.insert(indexPath.item)
            }
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath.item)
            }
        case .move:
            break
        case .update:
            if let indexPath = indexPath {
                updatedIndexes?.insert(indexPath.item)
            }
        @unknown default:
            break
        }
    }
}
