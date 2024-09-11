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
    var onErrorStateChange: Binding<String?>?

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
            onErrorStateChange?(nil)
        case .failure(let error):
            onSaveCategoryAllowedStateChange?(false)
            if let error = error as? TrackerCategoryError {
                switch error {
                case .categoryNameAlreadyExists:
                    onErrorStateChange?(error.localizedDescription)
                default:
                    break
                }
            }
        }
    }

    func saveCategory(withName categoryName: String) {
        if let category = category {
            let editResult = trackerCategoryStore.editTrackerCategory(withName: category.name, andNewName: categoryName)
            if editResult {
                delegate?.onNeedReloadCategoriesList?(())
            }
        } else {
            _ = trackerCategoryStore.addTrackerCategory(withName: categoryName)
        }
    }
}
