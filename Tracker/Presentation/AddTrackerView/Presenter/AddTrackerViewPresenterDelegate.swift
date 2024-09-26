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
    ///   - tracker: модель трекера
    func trackerDidRecorded(tracker: Tracker)
}
