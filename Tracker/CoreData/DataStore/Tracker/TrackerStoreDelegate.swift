//
//  TrackerStoreDelegate.swift
//  Tracker
//
//  Created by Сергей Кухарев on 02.09.2024.
//

import Foundation

protocol TrackerStoreDelegate: AnyObject {
    /// Обраотчик, вызываемый Store-классом при изменении данных в трекерах
    func didUpdate()
}
