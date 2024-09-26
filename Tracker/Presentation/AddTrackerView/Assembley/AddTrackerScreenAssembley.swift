//
//  AddTrackerScreenAssembley.swift
//  Tracker
//
//  Created by Сергей Кухарев on 18.08.2024.
//

import UIKit

enum AddTrackerScreenAssembley {
    /// Инициализирует вью контроллер перед отображением на экране
    /// - Parameter withDelegate: делегат вью контроллера, который будет получать событие об успешном добавлении трекера
    /// - Returns: вью контроллер, готовый к показу на экране
    static func build(withDelegate: AddTrackerViewPresenterDelegate) -> UIViewController {
        let addTrackerViewPresenter = AddTrackerViewPresenter()
        let addTrackerViewController = AddTrackerViewController(withPresenter: addTrackerViewPresenter)
        addTrackerViewPresenter.delegate = withDelegate
        return addTrackerViewController
    }
}
