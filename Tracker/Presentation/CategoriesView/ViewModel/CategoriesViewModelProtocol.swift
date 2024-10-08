//
//  CategoriesViewModelProtocol.swift
//  Tracker
//
//  Created by Сергей Кухарев on 09.09.2024.
//

import Foundation

protocol CategoriesViewModelProtocol: AnyObject {
    /// Переменная используется для хранения выбранной категории у трекера перед вызовом вью контроллера создания/выбора категорий
    var categoryName: String? { get set }
    /// Переменная для делегата, получающего уведомление о выборе заданной категории трекера
    var delegate: NewTrackerViewPresenterProtocol? { get set }
    /// Событие, генерируемое при изменении списка категорий трекеров в базе данных
    var onCategoriesListChange: Binding<TrackerCategoryStoreUpdate>? { get set }
    /// Событие, генерируемое делегатом при необходимости перечитать список категорий из базы данных
    var onNeedCategoriesReload: Binding<Void>? { get set }
    /// Используется для определения количества категорий трекеров в базе данных
    /// - Returns: Количество категорий трекеров в базе данных
    func сategoiresCount() -> Int
    /// Возвращает наименование категории по заданному индексу внутри табличного представления со списком трекеров
    /// - Parameter indexPath: Индекс искомой категории
    /// - Returns: Наименование категории трекеров
    func category(at indexPath: IndexPath) -> CategoryCellModel?
    /// Событие, вызываемое делегатом при изменении редактируемой категории
    /// - Parameter categoryName: Новое значение отредактированной категории
    func didCategoryChange(with categoryName: String)
    /// Событие, вызываемое вью контроллером при выборе категории трекера из списка
    /// - Parameter indexPath: Индекс выбранной категории
    func didSelectCategory(at indexPath: IndexPath)
    /// Используется для удаления категории трекеров
    /// - Parameter categoryName: Наименование удаляемой категории
    func deleteCategory(withCategory categoryName: String)
    /// Используется для определения возможности удаления категории трекеров
    /// - Parameter categoryName: Наименование категории трекеров
    /// - Returns: Возвращает Истину в случае, если категорию трекеров можно удалить; возвращает Ложь в противном случае
    func deleteCategoryRequest(withCategory categoryName: String) -> Bool
}
