//
//  InsetLabel.swift
//  Tracker
//
//  Created by Сергей Кухарев on 14.08.2024.
//

import UIKit

/// Лейбл с настраиваемыми отступами текста от внутренних границ
final class InsetLabel: UILabel {
    // MARK: - Public Properties
    var insets = UIEdgeInsets()

    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width += insets.left + insets.right
        size.height += insets.top + insets.bottom
        return size
    }

    // MARK: - Initializers

    convenience init(insets: UIEdgeInsets) {
        self.init(frame: CGRect.zero)
        self.insets = insets
    }

    convenience init(insetX: CGFloat, insetY: CGFloat) {
        let insets = UIEdgeInsets(top: insetY, left: insetX, bottom: insetY, right: insetX)
        self.init(insets: insets)
    }

    // MARK: - UILabel

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
}
