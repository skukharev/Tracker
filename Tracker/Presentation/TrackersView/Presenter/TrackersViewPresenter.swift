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

    public var currentDate: Date {
        get {
            return trackersDate
        }
        set {
            trackersDate = newValue.removeTimeStamp
            loadTrackers()
        }
    }
    public var trackersFilter: String? {
        didSet {
            let params: AnalyticsEventParam = ["searchTracker": trackersFilter ?? ""]
            AnalyticsService.report(event: "SearchTracker", params: params)
            loadTrackers()
        }
    }

    // MARK: - Private Properties

    /// Переменная для хранения значения currentDate
    private var trackersDate = Date()

    /// Ссылка на экземпляр Store-класса для работы с категориями трекеров
    private lazy var trackerCategoryStore: TrackerCategoryStore = {
        let store = TrackerCategoryStore()
        return store
    }()
    /// Ссылка на экземпляр Store-класса для работы с трекерами
    private lazy var trackerStore: TrackerStore = {
        let store = TrackerStore()
        store.delegate = self
        return store
    }()
    /// Ссылка на экземпляр Store-класса для работы с записями событий трекеров
    private lazy var trackerRecordStore: TrackerRecordStore = {
        let store = TrackerRecordStore()
        return store
    }()

    // MARK: - Public Methods

    func addTracker() {
        let params: AnalyticsEventParam = ["tracker_type": "init"]
        AnalyticsService.report(event: "AddTracker", params: params)
        guard let viewController = viewController as? UIViewController else { return }
        let targetViewController = AddTrackerScreenAssembley.build(withDelegate: self)
        let router = Router(viewController: viewController, targetViewController: targetViewController)
        router.showNext(dismissCurrent: false)
    }

    func recordTracker(for indexPath: IndexPath, _ completion: @escaping (Result<Void, Error>) -> Void) {
        if currentDate > Date().removeTimeStamp {
            completion(.failure(TrackersViewPresenterErrors.trackerCompletionInTheFutureIsProhibited))
            return
        }
        guard let trackerRecord = trackerStore.tracker(at: indexPath) else {
            assertionFailure("В базе данных не найден трекер с индексом \(indexPath)")
            return
        }
        trackerRecordStore.processTracker(TrackerRecord(trackerId: trackerRecord.id, recordDate: currentDate))
        loadTrackers()
        completion(.success(()))
    }

    func showCell(for cell: TrackersCollectionViewCell, with indexPath: IndexPath) {
        guard let trackerRecord = trackerStore.tracker(at: indexPath) else {
            assertionFailure("В базе данных не найден трекер с индексом \(indexPath)")
            return
        }
        let cellViewModel = TrackersCellViewModel(
            emoji: trackerRecord.emoji,
            color: trackerRecord.color,
            name: trackerRecord.name,
            daysCount: trackersRecordCount(withId: trackerRecord.id),
            isCompleted: isTrackerCompleted(withId: trackerRecord.id)
        )
        cell.showCellViewModel(cellViewModel)
    }

    func showHeader(for header: TrackersCollectionHeaderView, with indexPath: IndexPath) {
        header.setSectionHeaderTitle(trackerStore.categoryName(indexPath.section))
    }

    func trackerCategoriesCount() -> Int {
        let numberOfCategories = trackerStore.numberOfCategories()
        if numberOfCategories == 0 {
            viewController?.showTrackersListStub()
        } else {
            viewController?.hideTrackersListStub()
        }
        return trackerStore.numberOfCategories()
    }

    func trackersCount(inSection section: Int) -> Int {
        return trackerStore.numberOfTrackersInCategory(section)
    }

    // MARK: - Private Methods

    /// Используется для определения факта выполнения заданного трекера на текущую дату
    /// - Parameter id: Идентификатор трекера
    /// - Returns: Возвращает истину, если трекер был выполнен на текущую дату; ложь - в противном случае
    private func isTrackerCompleted(withId id: UUID) -> Bool {
        return trackerRecordStore.isTrackerCompletedOnDate(withId: id, atDate: currentDate)
    }

    /// Загружает трекеры из базы данных
    private func loadTrackers() {
        trackerStore.loadData(atDate: currentDate, withTrackerFilter: trackersFilter)
        if trackerStore.numberOfCategories() == 0 {
            viewController?.showTrackersListStub()
        } else {
            viewController?.showTrackersList()
        }
    }

    /// Используется для вычисления количества выполнений заданного трекера
    /// - Parameter id: Идентификатор трекера
    /// - Returns: Общее количество выполнений заданного трекера
    private func trackersRecordCount(withId id: UUID) -> Int {
        return trackerRecordStore.trackersRecordCount(withId: id)
    }
}

// MARK: - AddTrackerViewPresenterDelegate

extension TrackersViewPresenter: AddTrackerViewPresenterDelegate {
    func trackerDidRecorded(trackerCategory: String, tracker: Tracker) {
        if let categoryID = trackerCategoryStore.addTrackerCategory(withName: trackerCategory) {
            _ = trackerStore.addTracker(tracker, withCategoryID: categoryID)
            let params: AnalyticsEventParam = ["tracker_type": "success"]
            AnalyticsService.report(event: "AddTracker", params: params)
        }
    }
}

// MARK: - TrackerStoreDelegate

extension TrackersViewPresenter: TrackerStoreDelegate {
    func didUpdate(_ update: TrackerStoreUpdate) {
        viewController?.updateTrackersCollection(at: update)
    }
}
