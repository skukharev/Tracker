//
//  AddTrackerPresenterProtocol.swift
//  Tracker
//
//  Created by Сергей Кухарев on 11.08.2024.
//

import Foundation

protocol AddTrackerViewPresenterProtocol: AnyObject {
    /// Ассоциированный вью контроллер
    var viewController: AddTrackerViewControllerDelegate? { get set }
    /// Инициирует процесс добавления привычки
    func addHabit()
    /// Инициирует процесс добавления события
    func addEvent()
}
