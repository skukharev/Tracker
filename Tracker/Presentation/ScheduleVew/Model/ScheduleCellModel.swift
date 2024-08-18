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
            return "Понедельник"
        case .tuesday:
            return "Вторник"
        case .wednesday:
            return "Среда"
        case .thursday:
            return "Четверг"
        case .friday:
            return "Пятница"
        case .saturday:
            return "Суббота"
        case .sunday:
            return "Воскресенье"
        }
    }
}
