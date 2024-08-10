//
//  Date+Extensions.swift
//  Tracker
//
//  Created by Сергей Кухарев on 10.08.2024.
//

import Foundation

extension Date {
    /// Возвращает дату, очищенную от порции времени
    public var removeTimeStamp: Date {
        guard
            let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: self))
        else {
            return Date()
        }
        return date
    }
}
