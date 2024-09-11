//
//  CategoriesScreenAssembley.swift
//  Tracker
//
//  Created by Сергей Кухарев on 09.09.2024.
//

import UIKit

enum CategoriesScreenAssembley {
    /// Инициализирует вью контроллер перед отображением на экране
    /// - Parameters:
    ///   - withDelegate: делегат вью контроллера, который будет получать событие об успешном выборе категории трекера
    /// - Returns: вью контроллер, готовый к отображению на экране
    static func build(withDelegate delegate: NewTrackerViewPresenterProtocol?, withCategory categoryName: String?) -> UIViewController {
        let categoriesViewController = CategoriesViewController()
        let categoriesViewModel = CategoriesViewModel()
        categoriesViewModel.categoryName = categoryName
        categoriesViewController.initialize(viewModel: categoriesViewModel)
        categoriesViewModel.delegate = delegate
        return categoriesViewController
    }
}
