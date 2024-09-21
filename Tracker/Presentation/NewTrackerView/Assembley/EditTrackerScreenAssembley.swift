//
//  EditTrackerScreenAssembley.swift
//  Tracker
//
//  Created by Сергей Кухарев on 21.09.2024.
//

import UIKit

enum EditTrackerScreenAssembley {
    static func build(withDelegate delegate: AddTrackerViewPresenterDelegate?, tracker: Tracker) -> UIViewController {
        let newTrackerViewController = NewTrackerViewController()
        let newTrackerViewPresenter = NewTrackerViewPresenter()
        newTrackerViewPresenter.delegate = delegate
        newTrackerViewController.presenter = newTrackerViewPresenter
        newTrackerViewPresenter.viewController = newTrackerViewController
        newTrackerViewPresenter.startEditing(tracker: tracker)
        return newTrackerViewController
    }
}
