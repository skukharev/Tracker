//
//  NewCategoryScreenAssembley.swift
//  Tracker
//
//  Created by Сергей Кухарев on 11.09.2024.
//

import UIKit

enum NewCategoryScreenAssembley {
    /// Инициализирует вью контроллер перед отображением на экране
    /// - Parameters:
    ///   - withDelegate: делегат вью контроллера, который будет получать событие об успешном добавлении/редактировании категории трекера
    /// - Returns: вью контроллер, готовый к отображению на экране
    static func build(withDelegate delegate: CategoriesViewModelProtocol?, withCategory category: NewCategoryModel? = nil) -> UIViewController {
        let newCategoryViewController = NewCategoryViewController()
        let newCategoryViewModel = NewCategoryViewModel()
        newCategoryViewController.initialize(viewModel: newCategoryViewModel, withCategory: category)
        newCategoryViewModel.delegate = delegate
        return newCategoryViewController
    }
}
