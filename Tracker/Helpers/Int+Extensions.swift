//
//  Int+Extensions.swift
//
//  Created by Сергей Кухарев on 25.02.2024.
//

import Foundation

extension Int {
    /// Конвертирует число в строку с принятым в РФ разделителем групп разрядов " "
    var intToString: String {
        return NumberFormatter.defaultInt.string(from: (self as NSNumber)) ?? ""
    }

    /// Преобразует число в строку с добавлением настраиваемого суффикса, адаптированного для русского языка
    /// - Parameters:
    ///   - suffixOne: суффикс для числа, оканчивающегося на 1 за исключением числа 11
    ///   - suffixTwo_Four: суффикс для числа с последней цифрой в диапазоне [2..4]
    ///   - suffixDefault: суффикс для чисел по умолчанию
    /// - Returns: строковое представление числа с указанным суффисом
    func toStringWithSuffix(suffixOne: String, suffixTwoFour: String, suffixDefault: String) -> String {
        var suffix = ""
        let divisionByTenRemainder = self % 10
        if 11...14 ~= self % 100 {
            suffix = suffixDefault
        } else if divisionByTenRemainder == 0 {
            suffix = suffixDefault
        } else if divisionByTenRemainder == 1 {
            suffix = suffixOne
        } else if 2...4 ~= divisionByTenRemainder {
            suffix = suffixTwoFour
        } else if 5...9 ~= divisionByTenRemainder {
            suffix = suffixDefault
        }
        return self.description + " " + suffix
    }
}

private extension NumberFormatter {
    static let defaultInt: NumberFormatter = {
        let intFormatter = NumberFormatter()
        intFormatter.numberStyle = .decimal
        intFormatter.groupingSeparator = " "
        intFormatter.locale = Locale.current
        return intFormatter
    }()
}
