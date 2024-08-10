//
//  UIImpactFeedbackGenerator+Extensions.swift
//  Tracker
//
//  Created by Сергей Кухарев on 10.08.2024.
//

import UIKit

extension UIImpactFeedbackGenerator {
    /// Инициализирует генератор обратной связи с учётом используемой версии iOS
    /// - Parameters:
    ///   - style: Стиль обратной связи
    ///   - view: Вью контроллер, используемый для инициализации с версий iOS 17.5+
    /// - Returns: Экземпляр класса UIImpactFeedbackGenerator
    static func initiate(style: UIImpactFeedbackGenerator.FeedbackStyle, view: UIView) -> UIImpactFeedbackGenerator {
        if #available(iOS 17.5, *) {
            return UIImpactFeedbackGenerator(style: style, view: view)
        } else {
            return UIImpactFeedbackGenerator(style: style)
        }
    }
}
