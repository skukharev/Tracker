//
//  NewTrackerScreenAssembley.swift
//  Tracker
//
//  Created by Сергей Кухарев on 18.08.2024.
//

import UIKit

enum NewTrackerScreenAssembley {
    /// Инициализирует вью контроллер перед отображением на экране
    /// - Parameters:
    ///   - withDelegate: делегат вью контроллера, который будет получать событие об успешном добавлении трекера
    ///   - forTrackerType: тип трекера, который требуется создать
    /// - Returns: вью контроллер, готовый к отображению на экране
    static func build(withDelegate delegate: AddTrackerViewPresenterDelegate?, forTrackerType trackerType: TrackerType) -> UIViewController {
        let newTrackerViewController = NewTrackerViewController()
        let newTrackerViewPresenter = NewTrackerViewPresenter()
        newTrackerViewPresenter.delegate = delegate
        newTrackerViewController.presenter = newTrackerViewPresenter
        newTrackerViewPresenter.viewController = newTrackerViewController
        newTrackerViewController.setupViewsWithTrackerType(trackerType: trackerType)
        return newTrackerViewController
    }
}
