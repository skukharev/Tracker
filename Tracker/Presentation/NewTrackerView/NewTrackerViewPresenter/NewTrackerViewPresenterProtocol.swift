//
//  NewTrackerViewPresenterProtocol.swift
//  Tracker
//
//  Created by Сергей Кухарев on 12.08.2024.
//

import UIKit

protocol NewTrackerViewPresenterProtocol: AnyObject, UITableViewDataSource, UITableViewDelegate {
    /// Ассоциированный вью контроллер
    var viewController: NewTrackerViewPresenterDelegate? { get set }
}
