//
//  TrackersViewPresenter.swift
//  Tracker
//
//  Created by Сергей Кухарев on 28.07.2024.
//

import UIKit

final class TrackersViewPresenter: NSObject, TrackersViewPresenterProtocol {
    // MARK: - Types

    enum Constants {
        static let trackersStubImageLabelText = L10n.trackersStubImageLabelText
        static let trackersStubEmptyFilterLabelText = L10n.trackersStubEmptyFilterLabelText
    }

    enum TrackersViewPresenterErrors: Error {
        case trackerNotFound
        case trackerCompletionInTheFutureIsProhibited
    }

    // MARK: - Constants

    /// Ссылка на экземпляр Store-класса для работы с категориями трекеров
    private let trackerCategoryStore = TrackerCategoryStore.shared
    /// Ссылка на экземпляр Store-класса для работы с записями событий трекеров
    private let trackerRecordStore = TrackerRecordStore.shared

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
    public var trackersSearchFilter: String? {
        didSet {
            let params: AnalyticsEventParam = ["searchTracker": trackersSearchFilter ?? ""]
            AnalyticsService.report(event: "SearchTracker", params: params)
            loadTrackers()
        }
    }
    public var trackersFilter: TrackersFilter = .allTrackers {
        didSet {
            processTrackersFilter()
        }
    }

    // MARK: - Private Properties

    /// Переменная для хранения значения currentDate
    private var trackersDate = Date()
    /// Ссылка на экземпляр Store-класса для работы с трекерами
    private lazy var trackerStore: TrackerStore = {
        let store = TrackerStore()
        store.delegate = self
        return store
    }()

    // MARK: - Public Methods

    func addTracker() {
        let params: AnalyticsEventParam = ["screen": "Main", "item": "add_track"]
        AnalyticsService.report(event: "click", params: params)
        print("Зарегистрировано событие аналитики 'click' с параметрами \(params)")

        guard let viewController = viewController as? UIViewController else { return }
        let targetViewController = AddTrackerScreenAssembley.build(withDelegate: self)
        let router = Router(viewController: viewController, targetViewController: targetViewController)
        router.showNext(dismissCurrent: false)
    }

    func deleteTracker(at indexPath: IndexPath, _ completion: @escaping (Result<Void, Error>) -> Void) {
        trackerStore.deleteTracker(at: indexPath) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func editTracker(at indexPath: IndexPath, _ completion: @escaping (Result<Void, any Error>) -> Void) {
        guard
            let viewController = viewController as? UIViewController,
            let tracker = trackerStore.tracker(at: indexPath)
        else {
            return
        }
        let targetViewController = EditTrackerScreenAssembley.build(withDelegate: self, tracker: tracker)
        let router = Router(viewController: viewController, targetViewController: targetViewController)
        router.showNext(dismissCurrent: false)
    }

    func getPinnedTrackerMenuText(at indexPath: IndexPath) -> String {
        guard let trackerRecord = trackerStore.tracker(at: indexPath) else {
            assertionFailure("В базе данных не найден трекер с индексом \(indexPath)")
            return ""
        }
        if trackerRecord.isFixed {
            return L10n.trackersCollectionMenuPinOffTitle
        } else {
            return L10n.trackersCollectionMenuPinOnTitle
        }
    }

    func recordTracker(for indexPath: IndexPath, _ completion: @escaping (Result<Void, Error>) -> Void) {
        let params: AnalyticsEventParam = ["screen": "Main", "item": "track"]
        AnalyticsService.report(event: "click", params: params)
        print("Зарегистрировано событие аналитики 'click' с параметрами \(params)")

        if currentDate > Date().removeTimeStamp {
            completion(.failure(TrackersViewPresenterErrors.trackerCompletionInTheFutureIsProhibited))
            return
        }
        guard let trackerRecord = trackerStore.tracker(at: indexPath) else {
            assertionFailure("В базе данных не найден трекер с индексом \(indexPath)")
            return
        }
        trackerRecordStore.processTracker(TrackerRecord(trackerId: trackerRecord.id, recordDate: currentDate))
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

    func showTrackersFilters() {
        let params: AnalyticsEventParam = ["screen": "Main", "item": "filter"]
        AnalyticsService.report(event: "click", params: params)
        print("Зарегистрировано событие аналитики 'click' с параметрами \(params)")

        guard let viewController = viewController as? UIViewController else { return }
        let targetviewController = TrackersFilterScreenAssembley.build(withDelegate: self, withCurrentFilter: trackersFilter)
        let router = Router(viewController: viewController, targetViewController: targetviewController)
        router.showNext(dismissCurrent: false)
    }

    func toggleFixTracker(at indexPath: IndexPath, _ completion: @escaping (Result<Void, Error>) -> Void) {
        trackerStore.toggleFixTracker(at: indexPath) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func trackerCategoriesCount() -> Int {
        return trackerStore.numberOfCategories()
    }

    func trackersCount(inSection section: Int) -> Int {
        return trackerStore.numberOfTrackersInCategory(section)
    }

    // MARK: - Private Methods

    private func adjustTrackersFilterButton() {
        let buttonBackgroundColor = trackersFilter == .allTrackers || trackersFilter == .currentDayTrackers ? TrackersViewController.Constants.filterButtonDefaultBackgroundColor : TrackersViewController.Constants.filterButtonSelectedBackgroundColor
        viewController?.setTrackersFilterButtonBackgroundColor(buttonBackgroundColor)
    }

    /// Используется для определения факта выполнения заданного трекера на текущую дату
    /// - Parameter id: Идентификатор трекера
    /// - Returns: Возвращает истину, если трекер был выполнен на текущую дату; ложь - в противном случае
    private func isTrackerCompleted(withId id: UUID) -> Bool {
        return trackerRecordStore.isTrackerCompletedOnDate(withId: id, atDate: currentDate)
    }

    /// Загружает трекеры из базы данных
    private func loadTrackers() {
        trackerStore.loadData(atDate: currentDate, withTrackerSearchFilter: trackersSearchFilter, withTrackersFilter: trackersFilter)
    }

    private func processTrackersFilter() {
        adjustTrackersFilterButton()
        if trackersFilter == .currentDayTrackers {
            currentDate = Date()
            viewController?.setCurrentDate(currentDate)
        } else {
            loadTrackers()
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
    func trackerDidRecorded(tracker: Tracker) {
        if let categoryID = trackerCategoryStore.addTrackerCategory(withName: tracker.categoryName) {
            _ = trackerStore.saveTracker(tracker, withCategoryID: categoryID)

            let params: AnalyticsEventParam = ["tracker_type": "success"]
            AnalyticsService.report(event: "AddTracker", params: params)

            if trackerCategoriesCount() == 0 {
                viewController?.showTrackersListStub(
                    with: TrackersListStubModel(
                        stubImage: Asset.Images.trackersStub.image,
                        stubTitle: Constants.trackersStubImageLabelText,
                        isFilterButtonHidden: true
                    )
                )
            } else {
                viewController?.showTrackersList()
            }
        }
    }
}

// MARK: - TrackerStoreDelegate

extension TrackersViewPresenter: TrackerStoreDelegate {
    func didUpdate(recordCounts: RecordCounts) {
        if recordCounts.allRecordsCount == 0 {
            viewController?.showTrackersListStub(
                with: TrackersListStubModel(
                    stubImage: Asset.Images.trackersStub.image,
                    stubTitle: Constants.trackersStubImageLabelText,
                    isFilterButtonHidden: true
                )
            )
        } else {
            if recordCounts.filteredRecordsCount == 0 {
                viewController?.showTrackersListStub(
                    with: TrackersListStubModel(
                        stubImage: Asset.Images.statisticsStub.image,
                        stubTitle: Constants.trackersStubEmptyFilterLabelText,
                        isFilterButtonHidden: false
                    )
                )
            } else {
                viewController?.showTrackersList()
            }
        }
    }

    func didUpdate(at indexPaths: TrackerStoreUpdate) {
        viewController?.updateTrackersCollection(at: indexPaths)
    }
}

// MARK: - TrackersFilterDelegate

extension TrackersViewPresenter: TrackersFilterDelegate {
    func filterDidChange(_ filter: TrackersFilter) {
        trackersFilter = filter
    }
}
