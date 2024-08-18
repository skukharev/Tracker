//
//  AddTrackerViewPresenterDelegate.swift
//  Tracker
//
//  Created by Сергей Кухарев on 11.08.2024.
//

import UIKit

protocol AddTrackerViewPresenterDelegate: AnyObject {
    /// Обработчик, вызываемый при успешном создании/редактировании трекера
    /// - Parameters:
    ///   - trackerCategory: наименование категории трекера
    ///   - tracker: модель трекера
    func trackerDidRecorded(trackerCategory: String, tracker: Tracker)
}
