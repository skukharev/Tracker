//
//  TrackersViewPresenterDelegate.swift
//  Tracker
//
//  Created by Сергей Кухарев on 28.07.2024.
//

import Foundation

/// Протокол для делегатов презентера TrackersViewPresenter
protocol TrackersViewPresenterDelegate: AnyObject {
    /// Используется для отображения заглушки трекеров
    func showTrackersListStub()
    /// Используется для сокрытия заглушки трекеров
    func hideTrackersListStub()
    /// Используется для отображения списка трекеров на заданную дату
    func showTrackersList()
    /// Обновляет коллекцию трекеров
    func updateTrackersCollection()
}
