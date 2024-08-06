//
//  TrackersViewPresenterProtocol.swift
//  Tracker
//
//  Created by Сергей Кухарев on 28.07.2024.
//

import Foundation

protocol TrackersViewPresenterProtocol: AnyObject {
    /// Ассоциированный вью контроллер
    var viewController: TrackersViewPresenterDelegate? { get set }
    /// Текущая дата трекеров
    var currentDate: Date { get set }
    /// Используется для определения количества используемых трекеров в приложении
    /// - Returns: Возвращает количество трекеров, используемых в приложении
    func trackersCount() -> Int
}
