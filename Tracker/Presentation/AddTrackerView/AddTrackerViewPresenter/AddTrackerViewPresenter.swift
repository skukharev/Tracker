//
//  AddTrackerViewPresenter.swift
//  Tracker
//
//  Created by Сергей Кухарев on 11.08.2024.
//

import UIKit

final class AddTrackerViewPresenter: AddTrackerViewPresenterProtocol {
    // MARK: - Public Properties

    weak var viewController: (any AddTrackerViewPresenterDelegate)?
    weak var delegate: TrackersViewPresenterProtocol?

    // MARK: - Public Methods

    func addHabit() {
        viewController?.hide()
        showNewTrackerViewController(withTrackerType: .habit)
    }

    func addEvent() {
        viewController?.hide()
        showNewTrackerViewController(withTrackerType: .event)
    }

    // MARK: - Private Methods

    /// Отображает экран создания трекера
    /// - Parameter trackerType: тип добавляемого трекера: привычка либо событие
    private func showNewTrackerViewController(withTrackerType trackerType: TrackerType) {
        let newTrackerViewController = NewTrackerViewController()
        let newTrackerViewPresenter = NewTrackerViewPresenter()
        newTrackerViewPresenter.delegate = self.delegate
        newTrackerViewController.configure(newTrackerViewPresenter, trackerType: trackerType)

        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        window.rootViewController?.present(newTrackerViewController, animated: true)
    }
}
