//
//  TrackersViewPresenter.swift
//  Tracker
//
//  Created by Сергей Кухарев on 28.07.2024.
//

import Foundation

final class TrackersViewPresenter: TrackersViewPresenterProtocol {
    // MARK: - Types

    // MARK: - Constants

    // MARK: - Public Properties

    weak var viewController: (any TrackersViewPresenterDelegate)?

    // MARK: - IBOutlet

    // MARK: - Private Properties
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []

    // MARK: - Initializers

    // MARK: - UIViewController(\*)

    // MARK: - Public Methods

    func loadTrackers() {
        if trackersCount() == 0 {
            viewController?.showTrackersListStub()
        }
    }

    func trackersCount() -> Int {
        return 0
    }

    // MARK: - IBAction

    // MARK: - Private Methods

}
