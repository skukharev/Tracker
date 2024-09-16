//
//  ScheduleModel.swift
//  Tracker
//
//  Created by Сергей Кухарев on 15.08.2024.
//

import Foundation

/// Структура для хранения настроек отображения ячейки расписания повторения трекера
struct ScheduleCellModel {
    /// День недели
    let weekDay: Weekday
    /// Повторение трекера в заданный день недели включено
    let isSelected: Bool
    /// Текстовое представление дня недели
    var weekDayName: String {
        switch weekDay {
        case .monday:
            return NSLocalizedString("mondayTitle", comment: "")
        case .tuesday:
            return NSLocalizedString("tuesdayTitle", comment: "")
        case .wednesday:
            return NSLocalizedString("wednesdayTitle", comment: "")
        case .thursday:
            return NSLocalizedString("thursdayTitle", comment: "")
        case .friday:
            return NSLocalizedString("fridayTitle", comment: "")
        case .saturday:
            return NSLocalizedString("saturdayTitle", comment: "")
        case .sunday:
            return NSLocalizedString("sundayTitle", comment: "")
        }
    }
}
