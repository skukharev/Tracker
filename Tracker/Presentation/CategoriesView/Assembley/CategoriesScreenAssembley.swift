//
//  CategoriesScreenAssembley.swift
//  Tracker
//
//  Created by Сергей Кухарев on 09.09.2024.
//

import UIKit

enum CategoriesScreenAssembley {
    static func build(withDelegate delegate: NewTrackerViewPresenterProtocol?, withCategory categoryName: String?) -> UIViewController {
        let categoriesViewController = CategoriesViewController()
        let categoriesViewModel = CategoriesViewModel()
        categoriesViewModel.categoryName = categoryName
        categoriesViewController.initialize(viewModel: categoriesViewModel)
        categoriesViewModel.delegate = delegate
        return categoriesViewController
    }
}
