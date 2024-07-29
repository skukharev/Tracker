//
//  UIView+Extensions.swift
//  Tracker
//
//  Created by Сергей Кухарев on 28.07.2024.
//

import UIKit

extension UIView {
    /// Добавляет массив подчинённых представлений
    /// - Parameter subviews: Массив представлений
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach { addSubview($0) }
    }

    /// Привязывает границы представления к родительскому представлению
    /// - Returns: Ссылка на представление
    @discardableResult
    func edgesToSuperview() -> Self {
        guard let superview = superview else {
            fatalError("View не в иерархии!")
        }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                topAnchor.constraint(equalTo: superview.topAnchor),
                leftAnchor.constraint(equalTo: superview.leftAnchor),
                rightAnchor.constraint(equalTo: superview.rightAnchor),
                bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ]
        )
        return self
    }
}
