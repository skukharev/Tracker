//
//  TrackerCategoryProtocol.swift
//  Tracker
//
//  Created by Сергей Кухарев on 10.09.2024.
//

import Foundation

protocol TrackerCategoryProtocol: AnyObject {
    /// Возвращает количество категорий трекеров
    /// - Returns: Количество категорий трекеров
    func numberOfCategories() -> Int
    /// Возвращает наименование категории по заданному индексу внутри табличного представления со списком трекеров
    /// - Parameter indexPath: Индекс искомой категории
    /// - Returns: Наименование категории трекеров
    func category(at indexPath: IndexPath) -> String?
}
