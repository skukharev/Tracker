//
//  TrackersFilterDelegate.swift
//  Tracker
//
//  Created by Сергей Кухарев on 23.09.2024.
//

protocol TrackersFilterDelegate: AnyObject {
    /// Событие, генерируемое при выборе пользователем одного из предопределённых фильтров списка трекеров
    /// - Parameter filter: Выбранный тип фильтрации списка
    func filterDidChange(_ filter: TrackersFilter)
}
