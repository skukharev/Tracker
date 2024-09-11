//
//  NewCategoryViewModel.swift
//  Tracker
//
//  Created by Сергей Кухарев on 11.09.2024.
//

import Foundation

final class NewCategoryViewModel: NewCategoryViewModelProtocol {
    // MARK: - Public Properties

    var category: NewCategoryModel? {
        didSet {
            onCategoryChange?(category)
        }
    }
    var delegate: (any CategoriesViewModelProtocol)?
    var onCategoryChange: Binding<NewCategoryModel?>?
    var onSaveCategoryAllowedStateChange: Binding<Bool>?

    // MARK: - Private Properties

    /// Ссылка на экземпляр Store-класса для работы с категориями трекеров
    private lazy var trackerCategoryStore: TrackerCategoryStore = {
        let store = TrackerCategoryStore()
        return store
    }()

    // MARK: - Public Methods

    func didCategoryNameEnter(_ categoryName: String?) {
        let checkResult = trackerCategoryStore.checkCategory(withName: categoryName, withModel: category)
        switch checkResult {
        case .success:
            onSaveCategoryAllowedStateChange?(true)
        case .failure:
            onSaveCategoryAllowedStateChange?(false)
        }
    }

    func saveCategory(withName categoryName: String) {
        if category == nil {
            _ = trackerCategoryStore.addTrackerCategory(withName: categoryName)
        }
    }
}
