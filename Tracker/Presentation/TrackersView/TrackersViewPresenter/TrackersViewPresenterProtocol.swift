//
//  TrackersViewPresenterProtocol.swift
//  Tracker
//
//  Created by Сергей Кухарев on 28.07.2024.
//

import Foundation

protocol TrackersViewPresenterProtocol: AnyObject {
    var viewController: TrackersViewPresenterDelegate? { get set }
    /// Используется для определения количества используемых трекеров в приложении
    /// - Returns: Возвращает количество трекеров, используемых в приложении
    func trackersCount() -> Int
    /// Загружает трекеры из базы данных
    func loadTrackers()
}
