//
//  NewTrackerColorCellDelegate.swift
//  Tracker
//
//  Created by Сергей Кухарев on 21.08.2024.
//

import UIKit

protocol NewTrackerColorCellDelegate: AnyObject {
    /// Обработчик события выделения заданного цвета трекера
    /// - Parameter newColor: новый цвет трекера
    func colorDidChange(_ newColor: UIColor)
}
