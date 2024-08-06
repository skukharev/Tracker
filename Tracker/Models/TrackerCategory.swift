//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Сергей Кухарев on 31.07.2024.
//

import Foundation

/// Cущность для хранения трекеров по категориям
public struct TrackerCategory {
    /// Наименование категории
    let categoryName: String
    /// Массив трекеров, относящихся к данной категории
    let trackers: [Tracker]
}
