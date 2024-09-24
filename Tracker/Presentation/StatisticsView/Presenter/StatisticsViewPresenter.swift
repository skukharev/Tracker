//
//  StatisticsViewPresenter.swift
//  Tracker
//
//  Created by Сергей Кухарев on 28.07.2024.
//

import Foundation

final class StatisticsViewPresenter: StatisticsViewPresenterProtocol {
    // MARK: - Types

    // MARK: - Constants

    // MARK: - Public Properties

    weak var viewController: (any StatisticsViewPresenterDelegate)?

    // MARK: - Private Properties

    private var statistics: [StatisticsElement] = []

    // MARK: - Initializers

    // MARK: - Public Methods

    func calculateStatistics() {
        statistics = [
            StatisticsElement(type: .completedTrackers, value: 5),
            StatisticsElement(type: .averageTrackers, value: 4),
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
            assertionFailure("В базе данных не найдена запись статистики с индексом \(indexPath)")
            return
        }
        let cellViewModel = StatisticsCellViewModel(
            title: statisticsItem.type.description,
            value: statisticsItem.value
        )
        cell.showCellViewModel(cellViewModel)
    }

    func statisticsCount() -> Int {
        return statistics.filter { $0.value > 0 }.count
    }

    // MARK: - Private Methods

}
