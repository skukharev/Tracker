//
//  TrackersCollectionViewCellDelegate.swift
//  Tracker
//
//  Created by Сергей Кухарев on 09.08.2024.
//

import Foundation

protocol TrackersCollectionViewCellDelegate: AnyObject {
    /// Обработчик события, генерируемого при нажатии на кнопку записи события трекера
    /// - Parameters:
    ///   - cell: ячейка коллекции трекеров, инициирующая событие
    ///   - completion: обработчик, вызываемый по завершении обработки события
    func trackersCollectionViewCellDidTapRecord(_ cell: TrackersCollectionViewCell, _ completion: @escaping () -> Void)
}
