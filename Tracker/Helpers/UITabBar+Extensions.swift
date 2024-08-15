//
//  UITabBar+Extensions.swift
//  Tracker
//
//  Created by Сергей Кухарев on 15.08.2024.
//

import UIKit

extension UITabBar {
    /// Добавляет верхнюю окантовку к панели управления
    /// - Parameters:
    ///   - color: цвет окантовки
    ///   - borderWidth: толщина окантовки
    func addTopBorder(with color: UIColor?, andWidth borderWidth: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        border.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: borderWidth)
        self.addSubview(border)
    }
}
