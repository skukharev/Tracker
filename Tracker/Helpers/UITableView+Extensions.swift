//
//  UITableView+Extensions.swift
//  Tracker
//
//  Created by Сергей Кухарев on 14.08.2024.
//

import UIKit

extension UITableView {
    /// Вычисляет индекс последней ячейки если это возможно
    var lastCellIndexPath: IndexPath? {
        for section in (0..<self.numberOfSections).reversed() {
            let rows = numberOfRows(inSection: section)
            guard rows > 0 else { continue }
            return IndexPath(row: rows - 1, section: section)
        }
        return nil
    }
}
