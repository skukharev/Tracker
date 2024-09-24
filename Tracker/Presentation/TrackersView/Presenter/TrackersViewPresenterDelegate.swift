//
//  TrackersViewPresenterDelegate.swift
//  Tracker
//
//  Created by Сергей Кухарев on 28.07.2024.
//

import UIKit

/// Протокол для делегатов презентера TrackersViewPresenter
protocol TrackersViewPresenterDelegate: AnyObject {
    /// Устанавливает цвет фона у кнопки фильтрации трекеров
    /// - Parameter color: Цвет фона кнопки
    func setTrackersFilterButtonBackgroundColor(_ color: UIColor)
    /// Используется для отображения заглушки трекеров
    func showTrackersListStub(with model: TrackersListStubModel)
    /// Используется для сокрытия заглушки трекеров
    func hideTrackersListStub()
    /// Устанавливает заданную дату элементу управления датами
    /// - Parameter date: Дата
    func setCurrentDate(_ date: Date)
    /// Используется для отображения списка трекеров на заданную дату
    func showTrackersList()
    /// Обновляет коллекцию трекеров
    func updateTrackersCollection()
}
