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
    /// Удаляет трекер из базы данных
    /// - Parameters:
    ///   - indexPath: Индекс трекера в коллекции трекеров
    ///   - completion: Обработчик, вызываемый по окончании выполнения метода, который возвращает ошибку при её возникновении в момент удаления трекера из базы данных
    func deleteTracker(at indexPath: IndexPath, _ completion: @escaping (Result<Void, Error>) -> Void)
    /// Редактирует трекер
    /// - Parameters:
    ///   - indexPath: Индекс трекера в коллекции трекеров
    ///   - completion: Обработчик, вызываемый по окончании выполнения метода, который возвращает ошибку при её возникновении в момент записи трекера в базу данных
    func editTracker(at indexPath: IndexPath, _ completion: @escaping (Result<Void, Error>) -> Void)
    /// Возвращает текст элемента меню управления закреплением/откреплением трекеров
    /// - Parameter indexPath: Индекс трекера в коллекции трекеров
    /// - Returns: Возвращает текст элемента меню
    func getPinnedTrackerMenuText(at indexPath: IndexPath) -> String
    /// В случае если трекер на текущую дату не выполнялся, то производит фиксацию выполнения трекера; и удаляет фиксацию выполнения трекера в противном случае
    /// - Parameters:
    ///   - for: Индекс трекера в коллекции трекеров
    ///   - completion: Обработчик, вызываемый по окончании выполнения метода, который возвращает ошибку при её возникновении в момент записи
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
    /// Включает/исключает трекер из списка закреплённых трекеров
    /// - Parameters
    ///   - indexPath: Индекс трекера в коллекции трекеров
    ///   - completion: Обработчик, вызываемый по окончании выполнения метода, который возвращает ошибку при её возникновении в момент записи
    func toggleFixTracker(at indexPath: IndexPath, _ completion: @escaping (Result<Void, Error>) -> Void)
    /// Возвращает количество категорий трекеров на текущую дату
    /// - Returns: количество категорий трекеров
    func trackerCategoriesCount() -> Int
    /// Возвращает количество трекеров на текущую дату в секции с заданным индексом внутри коллекции
    /// - Parameter section: индекс секции, для которой необходимо вернуть общее число трекеров
    /// - Returns: количество трекеров
    func trackersCount(inSection section: Int) -> Int
}
