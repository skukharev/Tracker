//
//  Tracker.swift
//  Tracker
//
//  Created by Сергей Кухарев on 31.07.2024.
//

import UIKit

/// Сущность для хранения информации про трекер (для «Привычки» или «Нерегулярного события»)
public struct Tracker {
    /// Идентификатор трекера
    let id: UUID
    /// Наименование трекера
    let name: String
    /// Цвет трекера
    let color: UIColor
    /// Эмоджи трекера
    let emoji: String
    /// Расписание трекера
    let schedule: Set<Weekday>
}
