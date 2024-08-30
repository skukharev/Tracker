//
//  Database.swift
//  Tracker
//
//  Created by Сергей Кухарев on 22.08.2024.
//

import Foundation
import CoreData

final class Database {
    // MARK: - Types

    enum DatabaseError: Error {
        case objectNotFound
    }

    // MARK: - Constants

    static let shared = Database()

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Database")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Ошибка загрузки базы данных \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    lazy var context: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()

    lazy var backgroundContext: NSManagedObjectContext = {
        return persistentContainer.newBackgroundContext()
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                context.rollback()
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
