//
//  AddTrackerViewPresenter.swift
//  Tracker
//
//  Created by Сергей Кухарев on 11.08.2024.
//

import UIKit

final class AddTrackerViewPresenter: AddTrackerViewPresenterProtocol {
    // MARK: - Public Properties

    weak var viewController: AddTrackerViewControllerDelegate?
    weak var delegate: AddTrackerViewPresenterDelegate?

    // MARK: - Public Methods

    func addHabit() {
        let params: AnalyticsEventParam = ["tracker_type": "habit"]
        AnalyticsService.report(event: "AddTracker", params: params)
        showNewTrackerViewController(withTrackerType: .habit)
    }

    func addEvent() {
        let params: AnalyticsEventParam = ["tracker_type": "event"]
        AnalyticsService.report(event: "AddTracker", params: params)
        showNewTrackerViewController(withTrackerType: .event)
    }

    // MARK: - Private Methods

    /// Отображает экран создания трекера
    /// - Parameter trackerType: тип добавляемого трекера: привычка либо событие
    private func showNewTrackerViewController(withTrackerType trackerType: TrackerType) {
        guard let viewController = viewController as? UIViewController else { return }
        let targetViewController = NewTrackerScreenAssembley.build(withDelegate: self.delegate, forTrackerType: trackerType)
        let router = Router(viewController: viewController, targetViewController: targetViewController)
        router.showNext(animatedDismissCurrent: false)
    }
}
