//
//  UIViewController+Extensions.swift
//  Tracker
//
//  Created by Сергей Кухарев on 13.08.2024.
//

import UIKit

extension UIViewController {
    /// Скрывает открытую клавиатуру при тапе в любом месте вью контроллера
    func setupHideKeyboardOnTap() {
        self.view.addGestureRecognizer(self.endEditingRecognizer())
        self.navigationController?.navigationBar.addGestureRecognizer(self.endEditingRecognizer())
    }

    /// Скрывает клавиатуру с self.view
    private func endEditingRecognizer() -> UIGestureRecognizer {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing(_:)))
        tap.cancelsTouchesInView = false
        return tap
    }
}
