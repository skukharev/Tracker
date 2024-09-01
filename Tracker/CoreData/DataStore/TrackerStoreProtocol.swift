//
//  TrackerStoreProtocol.swift
//  Tracker
//
//  Created by Сергей Кухарев on 28.08.2024.
//

import Foundation

protocol TrackerStoreProtocol: AnyObject {
    /// Возвращает количество категорий трекеров (секций) на заданную дату, используется для сегментирования коллекции трекеров
    /// - Returns: Количество категорий трекеров (секций) на заданную дату
    func numberOfCategories() -> Int
    /// Возвращает количество трекеров в заданной категории трекров (секции)
    /// - Parameter section: Индекс категории трекеров в наборе данных
    /// - Returns: Количество трекеров в заданной категории трекеров (секции)
    func numberOfTrackersInCategory(_ section: Int) -> Int
    /// Возвращает структуру с атрибутами трекера по заданному индексу внутри коллекции трекеров
    /// - Parameter indexPath: Индекс искомого трекера
    /// - Returns: Заполненная структура с атрибутами трекера
    func tracker(at indexPath: IndexPath) -> Tracker?
    /// Возвращает наименование категории трекеров (секции) по её индексу внутри коллекции трекеров
    /// - Parameter section: Индекс категории трекеров в наборе данных
    /// - Returns: Наименование категории трекеров
    func categoryName(_ section: Int) -> String
    /// Загружает список трекеров на заданную дату из базы данных
    /// - Parameter atDate: Дата, на которую необходимо вернуть список трекеров
    func loadData(atDate currentDate: Date)
}
