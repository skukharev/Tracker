//
//  TrackersViewPresenterDelegate.swift
//  Tracker
//
//  Created by Сергей Кухарев on 28.07.2024.
//

import Foundation

/// Протокол для делегатов презентера TrackersViewPresenter
protocol TrackersViewPresenterDelegate: AnyObject {
    /// Используется для отображения заглушки в случае, если список трекеров пуст
    func showTrackersListStub()
}
