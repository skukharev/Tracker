//
//  TrackersCellViewModel.swift
//  Tracker
//
//  Created by Сергей Кухарев on 07.08.2024.
//

import UIKit

/// Структура хранения элементо ячейки коллекции трекеров
struct TrackersCellViewModel {
    /// Эмоджи трекера
    let emoji: String
    /// Цвет фона трекера
    let color: UIColor
    /// Наименование трекера
    let name: String
    /// Количество дней повторения трекера
    let daysCount: Int
    /// Признак выполненного трекера на заданную дату
    let isCompleted: Bool
}
