//
//  TrackersCellGeometricParams.swift
//  Tracker
//
//  Created by Сергей Кухарев on 07.08.2024.
//

import Foundation

/// Структура для хранения размеров отступов ячеек в коллекции трекеров
struct TrackersCellGeometricParams {
    let cellCount: Int
    let topInset: CGFloat
    let leftInset: CGFloat
    let rightInset: CGFloat
    let bottomInset: CGFloat
    let cellSpacing: CGFloat
    let cellHeight: CGFloat
    let lineSpacing: CGFloat
    let paddingWidth: CGFloat

    init(cellCount: Int, topInset: CGFloat, leftInset: CGFloat, rightInset: CGFloat, bottomInset: CGFloat, cellSpacing: CGFloat, cellHeight: CGFloat, lineSpacing: CGFloat) {
        self.cellCount = cellCount
        self.topInset = topInset
        self.leftInset = leftInset
        self.rightInset = rightInset
        self.bottomInset = bottomInset
        self.cellSpacing = cellSpacing
        self.cellHeight = cellHeight
        self.lineSpacing = lineSpacing
        self.paddingWidth = leftInset + rightInset + CGFloat(cellCount - 1) * cellSpacing
    }
}
