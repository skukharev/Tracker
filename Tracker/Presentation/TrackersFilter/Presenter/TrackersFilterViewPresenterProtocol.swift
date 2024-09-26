//
//  TrackersFilterViewPresenterProtocol.swift
//  Tracker
//
//  Created by Сергей Кухарев on 23.09.2024.
//

import Foundation

protocol TrackersFilterViewPresenterProtocol: AnyObject {
    /// Ассоциированный вью контроллер
    var viewController: TrackersFilterViewControllerProtocol? { get set }
    /// Делегат фильтра трекеров
    var delegate: TrackersFilterDelegate? { get set }
    /// Устанавливает активным заданный тип фильтра списка трекеров
    /// - Parameter filter: Тип фильтра списка трекеров
    func setFilter(with filter: TrackersFilter)
    /// Возвращает наименование фильтра трекеров по заданному индексу внутри табличного представления со списком фильтров
    /// - Parameter indexPath: Индекс фильтра трекеров внутри табличного представления
    /// - Returns: Модель с данными о фильтре трекеров
    func trackersFilter(at indexPath: IndexPath) -> FilterCellModel?
    /// Событие, генерируемое при выборе пользователем фильтра трекеров
    /// - Parameter indexPath: Индекс выбранного фильтра трекеров
    func didSelectTrackersFilter(at indexPath: IndexPath)
}
