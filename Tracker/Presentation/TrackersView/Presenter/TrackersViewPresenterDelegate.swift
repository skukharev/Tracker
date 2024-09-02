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
    /// Обновляет коллекцию трекеров на основании массивов добавленных/удалённых индексов изменившихся данных в коллекции
    /// - Parameter indexPaths: Структура с массивами индексов добавленных / удалённых данных
    func updateTrackersCollection(at indexPaths: TrackerStoreUpdate)
}
