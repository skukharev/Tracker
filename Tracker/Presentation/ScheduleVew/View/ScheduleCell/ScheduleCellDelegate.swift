//
//  ScheduleCellDelegate.swift
//  Tracker
//
//  Created by Сергей Кухарев on 15.08.2024.
//

import Foundation

protocol ScheduleCellDelegate: AnyObject {
    /// Обработчик изменения расписания выполнения трекера
    /// - Parameters:
    ///   - weekDay: день недели
    ///   - isSelected: трекер должен выполняться в заданный день недели
    func weekDayScheduleChange(weekDay: Weekday, isSelected: Bool)
}
