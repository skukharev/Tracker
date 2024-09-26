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
            return L10n.mondayTitle
        case .tuesday:
            return L10n.tuesdayTitle
        case .wednesday:
            return L10n.wednesdayTitle
        case .thursday:
            return L10n.thursdayTitle
        case .friday:
            return L10n.fridayTitle
        case .saturday:
            return L10n.saturdayTitle
        case .sunday:
            return L10n.sundayTitle
        }
    }
}
