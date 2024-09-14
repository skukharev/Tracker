//
//  TrackerCategoryStoreDelegate.swift
//  Tracker
//
//  Created by Сергей Кухарев on 10.09.2024.
//

import Foundation

protocol TrackerCategoryStoreDelegate: AnyObject {
    /// Обраотчик, вызываемый Store-классом при изменении данных в категориях трекеров
    /// - Parameter update: структура со списком индексов изменённых данных
    func didUpdate(_ update: TrackerCategoryStoreUpdate)
}
