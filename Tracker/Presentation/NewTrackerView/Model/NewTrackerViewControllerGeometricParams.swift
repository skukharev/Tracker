//
//  NewTrackerViewControllerGeometricParams.swift
//  Tracker
//
//  Created by Сергей Кухарев on 20.08.2024.
//

import Foundation

/// Параметры отображения элементов управления вью контроллера в зависимости от типа устройства
struct NewTrackerViewControllerGeometricParams {
    /// Высота коллекции эмоджи
    let collectionViewHeight: CGFloat
    /// Настройки отображения коллекции эмоджи
    let collectionViewParams: UICollectionViewCellGeometricParams
}
