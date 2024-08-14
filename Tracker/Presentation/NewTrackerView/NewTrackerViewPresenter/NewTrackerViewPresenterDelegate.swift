//
//  NewTrackerPresenterDelegate.swift
//  Tracker
//
//  Created by Сергей Кухарев on 12.08.2024.
//

import Foundation

protocol NewTrackerViewPresenterDelegate: AnyObject {
    var trackerType: NewTrackerType? { get }
}
