//
//  NewCategoryViewModelProtocol.swift
//  Tracker
//
//  Created by Сергей Кухарев on 11.09.2024.
//

import Foundation

protocol NewCategoryViewModelProtocol: AnyObject {
    /// Модель данных о добавляемой/редактируемой категории
    var category: NewCategoryModel? { get set }
    /// Делегат, получающий уведомление о добавлении/изменении категории трекера
//    var delegate: CategoriesViewModelProtocol? { get set }
    /// Событие, генерируемое при изменении модели данных о добавляемой/редактируемой категории
    var onCategoryChange: Binding<NewCategoryModel?>? { get set }
    /// Событие, генерируемое при возникновении ошибок проверки допустимости записи категории с заданным наименованием
    var onErrorStateChange: Binding<String?>? { get set }
    /// Событие, генерируемое после проверки допустимости записи категории трекеров в базу данных
    var onSaveCategoryAllowedStateChange: Binding<Bool>? { get set }
    /// Метод вызывается View при вводе наименования категории
    /// - Parameter categoryName: Текущее значение наименования категории
    func didCategoryNameEnter(_ categoryName: String?)
    /// Записывает категорию трекеров в базе данных
    /// - Parameter categoryName: Наименование категории
    func saveCategory(withName categoryName: String)
}
