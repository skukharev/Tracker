//
//  CategoriesViewModel.swift
//  Tracker
//
//  Created by Сергей Кухарев on 09.09.2024.
//

import Foundation

final class CategoriesViewModel: CategoriesViewModelProtocol {
    // MARK: - Public Properties

    var categoryName: String?
    weak var delegate: NewTrackerViewPresenterProtocol?
    var onCategoriesListChange: Binding<TrackerCategoryStoreUpdate>?
    let trackerCategoryStore = TrackerCategoryStore.shared

    // MARK: - Initializers

    init() {
        trackerCategoryStore.delegate = self
    }

    // MARK: - Public Methods

    func сategoiresCount() -> Int {
        return trackerCategoryStore.numberOfCategories()
    }

    func category(at indexPath: IndexPath) -> CategoryCellModel? {
        guard let name = trackerCategoryStore.category(at: indexPath) else { return nil }
        let isSelected = name.caseInsensitiveCompare(categoryName ?? "") == .orderedSame
        return CategoryCellModel(name: name, isSelected: isSelected)
    }

    func deleteCategory(withCategory categoryName: String) {
        trackerCategoryStore.deleteCategory(withName: categoryName)
    }

    func deleteCategoryRequest(withCategory categoryName: String) -> Bool {
        return trackerCategoryStore.checkCategoryDelete(withName: categoryName)
    }

    func didSelectCategory(at indexPath: IndexPath) {
        guard let category = trackerCategoryStore.category(at: indexPath) else {
            assertionFailure("Категория с заданным индексом не найдена в базе данных")
            return
        }
        delegate?.processCategory(category)
    }
}

// MARK: - TrackerCategoryStoreDelegate

extension CategoriesViewModel: TrackerCategoryStoreDelegate {
    func didUpdate(_ update: TrackerCategoryStoreUpdate) {
        onCategoriesListChange?(update)
    }
}
