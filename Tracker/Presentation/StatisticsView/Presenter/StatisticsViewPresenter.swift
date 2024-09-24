//
//  StatisticsViewPresenter.swift
//  Tracker
//
//  Created by Сергей Кухарев on 28.07.2024.
//

import Foundation

final class StatisticsViewPresenter: StatisticsViewPresenterProtocol {
    // MARK: - Constants

    private let trackerStore = TrackerStore.shared
    private let trackerRecordStore = TrackerRecordStore.shared

    // MARK: - Public Properties

    weak var viewController: (any StatisticsViewPresenterDelegate)?

    // MARK: - Private Properties

    private var statistics: [StatisticsElement] = []

    // MARK: - Public Methods

    func calculateStatistics() {
        statistics = [
            StatisticsElement(
                type: .completedTrackers,
                value: trackerRecordStore.getCompletedTrackerCount()
            ),
            StatisticsElement(
                type: .averageTrackers,
                value: trackerRecordStore.getAverageTrackersCompletionPerDay()
            ),
            StatisticsElement(type: .idealDaysCount, value: 2)
        ]

        if statistics.filter({ $0.value > 0 }).isEmpty {
            viewController?.showStatisticsStub()
        } else {
            viewController?.hideStatisticsStub()
        }
    }

    func showCell(for cell: StatisticsCollectionViewCell, with indexPath: IndexPath) {
        guard let statisticsItem = statistics[safe: indexPath.row] else {
            assertionFailure("Не найдена запись статистики с индексом \(indexPath)")
            return
        }
        let cellViewModel = StatisticsCellViewModel(
            title: statisticsItem.type.description,
            value: statisticsItem.value
        )
        cell.showCellViewModel(cellViewModel)
    }

    func statisticsCount() -> Int {
        if statistics.filter({ $0.value > 0 }).isEmpty {
            return 0
        } else {
            return statistics.count
        }
    }
}
