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
