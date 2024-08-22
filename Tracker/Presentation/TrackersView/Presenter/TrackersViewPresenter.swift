//
//  TrackersViewPresenter.swift
//  Tracker
//
//  Created by Сергей Кухарев on 28.07.2024.
//

import UIKit

final class TrackersViewPresenter: NSObject, TrackersViewPresenterProtocol {
    // MARK: - Types

    enum TrackersViewPresenterErrors: Error {
        case trackerNotFound
        case trackerCompletionInTheFutureIsProhibited
    }

    // MARK: - Public Properties

    weak var viewController: TrackersViewPresenterDelegate?

    /// Дата, на которую отображается коллекция трекеров
    public var currentDate: Date {
        get {
            return trackersDate
        }
        set {
            trackersDate = newValue.removeTimeStamp
            loadTrackers()
        }
    }

    // MARK: - Private Properties

    /// Переменная для хранения значения currentDate
    private var trackersDate = Date()
    /// Список категорий и вложенных в них трекеров
    private var categoriesDatabase: [TrackerCategory] = []
    /// Список категорий и вложенных в них трекеров на текущую дату
    private var categoriesOnDate: [TrackerCategory] = []
    /// Список выполненных трекеров
    private var completedTrackers: Set<TrackerRecord> = []

    // MARK: - Public Methods

    func addTracker() {
        guard let viewController = viewController as? UIViewController else { return }
        let targetViewController = AddTrackerScreenAssembley.build(withDelegate: self)
        let router = Router(viewController: viewController, targetViewController: targetViewController)
        router.showNext(dismissCurrent: false)
    }

    func recordTracker(for indexPath: IndexPath, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard
            let category = categoriesOnDate[safe: indexPath.section],
            let tracker = category.trackers[safe: indexPath.row]
        else {
            assertionFailure("Критическая ошибка доступа к данным трекеров - искомые категория и/или трекер не найдены")
            completion(.failure(TrackersViewPresenterErrors.trackerNotFound))
            return
        }

        if currentDate > Date().removeTimeStamp {
            completion(.failure(TrackersViewPresenterErrors.trackerCompletionInTheFutureIsProhibited))
            return
        }

        if let trackerRecord = completedTrackers.first(where: {
            $0.trackerId == tracker.id && $0.recordDate == currentDate
        }) {
            completedTrackers.remove(trackerRecord)
        } else {
            completedTrackers.insert(TrackerRecord(trackerId: tracker.id, recordDate: currentDate))
        }
        completion(.success(()))
    }

    func showCell(for cell: TrackersCollectionViewCell, with indexPath: IndexPath) {
        guard
            let category = categoriesOnDate[safe: indexPath.section],
            let tracker = category.trackers[safe: indexPath.row] else {
            assertionFailure("Критическая ошибка доступа к данным трекера: искомый объект не найден по индексу секции \(indexPath.section) и индексу трекера \(indexPath.row)")
            return
        }
        let cellViewModel = TrackersCellViewModel(
            emoji: tracker.emoji,
            color: tracker.color,
            name: tracker.name,
            daysCount: trackersRecordCount(withId: tracker.id),
            isCompleted: isTrackerCompleted(withId: tracker.id)
        )
        cell.showCellViewModel(cellViewModel)
    }

    func showHeader(for header: TrackersCollectionHeaderView, with indexPath: IndexPath) {
        guard let category = categoriesOnDate[safe: indexPath.section] else {
            assertionFailure("Критическая ошибка доступа к данным трекера: искомая категория трекеров не найдена по индексу секции \(indexPath.section)")
            return
        }
        header.setSectionHeaderTitle(category.categoryName)
    }

    func trackerCategoriesCount() -> Int {
        return categoriesOnDate.count
    }

    func trackersCount(inSection section: Int) -> Int {
        guard let trackersCount = categoriesOnDate[safe: section]?.trackers.count else { return 0 }
        return trackersCount
    }

    // MARK: - Private Methods

    /// Используется для определения факта выполнения заданного трекера на текущую дату
    /// - Parameter id: Идентификатор трекера
    /// - Returns: Возвращает истину, если трекер был выполнен на текущую дату; ложь - в противном случае
    private func isTrackerCompleted(withId id: UUID) -> Bool {
        return completedTrackers.contains {
            $0.trackerId == id && $0.recordDate == currentDate
        }
    }

    /// Загружает трекеры из базы данных
    private func loadTrackers() {
        guard let dayOfTheWeek = Weekday.dayOfTheWeek(of: currentDate) else {
            assertionFailure("Ошибка определения дня недели на основании текущей даты")
            return
        }

        categoriesOnDate = []
        categoriesDatabase.forEach { category in
            let trackersOnDate = category.trackers.filter { tracker in
                if tracker.schedule.contains(dayOfTheWeek) {
                    return true
                } else {
                    if tracker.schedule.isEmpty {
                        if trackersRecordCount(withId: tracker.id) == 0 {
                            return true
                        } else {
                            guard
                                let trackerRecord = completedTrackers.first(where: { $0.trackerId == tracker.id })
                            else {
                                return false
                            }
                            if trackerRecord.recordDate == currentDate {
                                return true
                            } else {
                                return false
                            }
                        }
                    } else {
                        return false
                    }
                }
            }
            if !trackersOnDate.isEmpty {
                categoriesOnDate.append(TrackerCategory(categoryName: category.categoryName, trackers: trackersOnDate))
            }
        }
        if categoriesOnDate.isEmpty {
            viewController?.showTrackersListStub()
        } else {
            viewController?.showTrackersList()
        }
    }

    /// Используется для вычисления количества выполнений заданного трекера
    /// - Parameter id: Идентификатор трекера
    /// - Returns: Общее количество выполнений заданного трекера
    private func trackersRecordCount(withId id: UUID) -> Int {
        return completedTrackers.filter { $0.trackerId == id }.count
    }
}

extension TrackersViewPresenter: AddTrackerViewPresenterDelegate {
    func trackerDidRecorded(trackerCategory: String, tracker: Tracker) {
        var tmpCategories = categoriesDatabase
        if let categoryIndex = tmpCategories.firstIndex(where: {
            $0.categoryName.lowercased() == trackerCategory.lowercased()
        }) {
            var trackers = tmpCategories[categoryIndex].trackers
            trackers.append(tracker)
            tmpCategories[categoryIndex] = TrackerCategory(categoryName: tmpCategories[categoryIndex].categoryName, trackers: trackers)
        } else {
            tmpCategories.append(TrackerCategory(categoryName: trackerCategory, trackers: [tracker]))
        }
        categoriesDatabase = tmpCategories
        loadTrackers()
    }
}
