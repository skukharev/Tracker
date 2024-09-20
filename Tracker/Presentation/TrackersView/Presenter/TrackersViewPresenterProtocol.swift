//
//  TrackersViewPresenterProtocol.swift
//  Tracker
//
//  Created by Сергей Кухарев on 28.07.2024.
//

import UIKit


protocol TrackersViewPresenterProtocol: AnyObject {
    /// Ассоциированный вью контроллер
    var viewController: TrackersViewPresenterDelegate? { get set }
    /// Текущая дата трекеров
    var currentDate: Date { get set }
    /// Текущий фильтр по трекерам
    var trackersFilter: String? { get set }
    /// Запускает функционал по добавлению трекера
    func addTracker()
    /// В случае если трекер на текущую дату не выполнялся, то производит фиксацию выполнения трекера; и удаляет фиксацию выполнения трекера в противном случае
    /// - Parameters:
    ///   - for: Индекс трекера в коллекции трекеров
    ///   - completion: Обработчик, вызываемый по окончании выполнения метода, возвращает истину в случае фиксации выполнения трекера, возвращает ложь в случае если фиксация выполнения трекера была удалена, либо ошибку при возникновении ошибок работы с данными
    func recordTracker(for indexPath: IndexPath, _ completion: @escaping (Result<Void, Error>) -> Void)
    /// Конифугрирует ячейку для её отображения в коллекции
    /// - Parameters:
    ///   - cell: Объект-ячейка
    ///   - indexPath: Индекс ячейки внутри коллекции
    func showCell(for cell: TrackersCollectionViewCell, with indexPath: IndexPath)
    /// Вызывается после успешного завершения редактирования данных трекера
    /// - Parameters:
    ///   - trackerCategory: выбранная категория трекера
    ///   - tracker: данные трекера
    /// Конфигурирует заголовок секции для его отображения
    /// - Parameters:
    ///   - header: Объект-заголовок
    ///   - indexPath: ИНдекс заголовка внутри коллекции
    func showHeader(for header: TrackersCollectionHeaderView, with indexPath: IndexPath)
    /// Возвращает количество категорий трекеров на текущую дату
    /// - Returns: количество категорий трекеров
    func trackerCategoriesCount() -> Int
    /// Возвращает количество трекеров на текущую дату в секции с заданным индексом внутри коллекции
    /// - Parameter section: индекс секции, для которой необходимо вернуть общее число трекеров
    /// - Returns: количество трекеров
    func trackersCount(inSection section: Int) -> Int
}
