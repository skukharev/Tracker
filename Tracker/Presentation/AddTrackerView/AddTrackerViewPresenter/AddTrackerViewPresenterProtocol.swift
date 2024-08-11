//
//  AddTrackerPresenterProtocol.swift
//  Tracker
//
//  Created by Сергей Кухарев on 11.08.2024.
//

import Foundation

protocol AddTrackerViewPresenterProtocol: AnyObject {
    /// Ассоциированный вью контроллер
    var viewController: AddTrackerViewPresenterDelegate? { get set }
}
