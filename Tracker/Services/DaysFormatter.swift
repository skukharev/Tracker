//
//  DaysFormatter.swift
//  Tracker
//
//  Created by Сергей Кухарев on 16.09.2024.
//

import Foundation

/// Используется для плюрализации строкового представления числа дней повторений трекера
final class DaysFormatter {
    // MARK: - Constants

    static let shared = DaysFormatter()

    // MARK: - Private Properties

    let formatter: DateComponentsFormatter

    // MARK: - Initializers

    init(formatter: DateComponentsFormatter) {
        self.formatter = formatter
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.day]
    }

    convenience init() {
        self.init(formatter: DateComponentsFormatter())
    }

    // MARK: - Public Methods

    /// Используется для плюрализации строкового представления числа дней повторений трекера
    /// - Parameter value: Количество дней
    /// - Returns: Строковое представление количества дней с добавлением суффикса "дней" в словоформе, соответствующей локали приложения
    func daysToStringWithSuffix(_ value: Double) -> String {
        guard let result = formatter.string(from: value * 60 * 60 * 24) else { return "" }
        return result
    }
}
