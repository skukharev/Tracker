//
//  Weekday.swift
//  Tracker
//
//  Created by Сергей Кухарев on 06.08.2024.
//

import Foundation

typealias Week = Set<Weekday>

/// Дни недели для использования в структуре Tracker
enum Weekday: Int, Codable {
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
        let currentWeekDay = Calendar.current.component(.weekday, from: date)

        switch currentWeekDay {
        case 1:
            return .sunday
        case 2:
            return .monday
        case 3:
            return .tuesday
        case 4:
            return .wednesday
        case 5:
            return .thursday
        case 6:
            return .friday
        case 7:
            return .saturday
        default:
            return nil
        }
    }
}
