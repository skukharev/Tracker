//
//  TrackersCellGeometricParams.swift
//  Tracker
//
//  Created by Сергей Кухарев on 07.08.2024.
//

import Foundation

/// Структура для хранения размеров отступов ячеек в коллекциях
struct UICollectionViewCellGeometricParams {
    /// Количество ячеек в одной строке
    let cellCount: Int
    /// Отступ ячеек от верхней границы коллекции
    let topInset: CGFloat
    /// Отступ ячеек от левой границы коллекции
    let leftInset: CGFloat
    /// Отступ ячеек от правой границы коллекции
    let rightInset: CGFloat
    /// Отступ ячеек от нижней границы коллекции
    let bottomInset: CGFloat
    /// Минимальный отступ между ячейками одной строки
    let cellSpacing: CGFloat
    /// Минимальный отступ между строками коллекции
    let lineSpacing: CGFloat
    /// Высота ячейки
    let cellHeight: CGFloat
    /// Желаемая ширина ячейки
    let cellWidth: CGFloat
    /// Вычисляемый размер служебного пространства между ячейками
    let paddingWidth: CGFloat

    init(cellCount: Int, topInset: CGFloat, leftInset: CGFloat, rightInset: CGFloat, bottomInset: CGFloat, cellSpacing: CGFloat, lineSpacing: CGFloat, cellHeight: CGFloat, cellWidth: CGFloat = 0) {
        self.cellCount = cellCount
        self.topInset = topInset
        self.leftInset = leftInset
        self.rightInset = rightInset
        self.bottomInset = bottomInset
        self.cellSpacing = cellSpacing
        self.lineSpacing = lineSpacing
        self.cellHeight = cellHeight
        self.cellWidth = cellWidth
        self.paddingWidth = leftInset + rightInset + CGFloat(cellCount - 1) * cellSpacing
    }
}
