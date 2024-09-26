//
//  TrackersFilterViewPresenter.swift
//  Tracker
//
//  Created by Сергей Кухарев on 23.09.2024.
//

import UIKit

final class TrackersFilterViewPresenter: TrackersFilterViewPresenterProtocol {
    // MARK: - Types

    enum Constants {
        static let trackersFilterTitleForAllTrackers = L10n.trackersFilterTitleForAllTrackers
        static let trackersFilterTitleForCurrentDayTrackers = L10n.trackersFilterTitleForCurrentDayTrackers
        static let trackersFilterTitleForComplitedTrackers = L10n.trackersFilterTitleForComplitedTrackers
        static let trackersFilterTitleForRunningTrackers = L10n.trackersFilterTitleForRunningTrackers
    }

    // MARK: - Public Properties

    weak var viewController: (any TrackersFilterViewControllerProtocol)?
    weak var delegate: (any TrackersFilterDelegate)?

    // MARK: - Private Properties

    private var trackersFilter: TrackersFilter = .allTrackers

    // MARK: - Public Methods

    public func didSelectTrackersFilter(at indexPath: IndexPath) {
        trackersFilter = TrackersFilter(rawValue: indexPath.row) ?? .allTrackers
        delegate?.filterDidChange(trackersFilter)
    }

    public func setFilter(with filter: TrackersFilter) {
        trackersFilter = filter
    }

    public func trackersFilter(at indexPath: IndexPath) -> FilterCellModel? {
        var trackersFilterTitle: String = ""
        switch indexPath.row {
        case 0:
            trackersFilterTitle = Constants.trackersFilterTitleForAllTrackers
        case 1:
            trackersFilterTitle = Constants.trackersFilterTitleForCurrentDayTrackers
        case 2:
            trackersFilterTitle = Constants.trackersFilterTitleForComplitedTrackers
        case 3:
            trackersFilterTitle = Constants.trackersFilterTitleForRunningTrackers
        default:
            break
        }
        let isSelected = indexPath.row == trackersFilter.rawValue
        return FilterCellModel(title: trackersFilterTitle, isSelected: isSelected)
    }
}
