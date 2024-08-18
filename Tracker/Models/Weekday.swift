//
//  Weekday.swift
//  Tracker
//
//  Created by Сергей Кухарев on 06.08.2024.
//

import Foundation

typealias Week = Set<Weekday>

/// Дни недели для использования в структуре Tracker
enum Weekday: Int {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday

    /// Возвращает день недели заданной даты
    /// - Parameter date: дата, для которой определяется день недели
    /// - Returns: день недели
    static func dayOfTheWeek(of date: Date) -> Weekday? {
        let currentWeekDay = (Calendar.current.component(.weekday, from: date) - Calendar.current.firstWeekday + 7) % 7
        return Weekday(rawValue: currentWeekDay)
    }
}
