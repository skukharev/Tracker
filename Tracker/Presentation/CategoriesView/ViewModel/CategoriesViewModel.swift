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
    var onNeedReloadCategoriesList: Binding<Void>?
    /// Ссылка на экземпляр Store-класса для работы с категориями трекеров
    lazy var trackerCategoryStore: TrackerCategoryStore = {
        let store = TrackerCategoryStore()
        store.delegate = self
        return store
    }()

    // MARK: - Private Properties


    // MARK: - Public Methods

    func сategoiresCount() -> Int {
        return trackerCategoryStore.numberOfCategories()
    }

    func category(at indexPath: IndexPath) -> CategoryCellModel? {
        guard let name = trackerCategoryStore.category(at: indexPath) else { return nil }
        let isSelected = name.caseInsensitiveCompare(categoryName ?? "") == .orderedSame
        return CategoryCellModel(name: name, isSelected: isSelected)
    }

    func didSelectCategory(at indexPath: IndexPath) {
        guard let category = trackerCategoryStore.category(at: indexPath) else {
            assertionFailure("Категория с заданным индексом не найдена в базе данных")
            return
        }
        delegate?.updateTrackerCategory(with: category)
    }
}

// MARK: - TrackerCategoryStoreDelegate

extension CategoriesViewModel: TrackerCategoryStoreDelegate {
    func didUpdate(_ update: TrackerCategoryStoreUpdate) {
        onCategoriesListChange?(update)
    }
}
