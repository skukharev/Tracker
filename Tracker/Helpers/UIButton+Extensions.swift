//
//  UIButton+Extensions.swift
//  Tracker
//
//  Created by Сергей Кухарев on 14.08.2024.
//

import UIKit

extension UIButton {
    /// Добавляет изображение сзади от текста кнопки на заданном расстоянии от границы
    /// - Parameters:
    ///   - image: Изображение
    ///   - trailingMargin: Отступ от задней границы кнопки
    func addRightIcon(image: UIImage, trailingMargin: CGFloat) {
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -trailingMargin),
            imageView.widthAnchor.constraint(equalToConstant: image.size.width),
            imageView.heightAnchor.constraint(equalToConstant: image.size.height)
        ])
    }
}
