//
//  EditTrackerScreenAssembley.swift
//  Tracker
//
//  Created by Сергей Кухарев on 21.09.2024.
//

import UIKit

enum EditTrackerScreenAssembley {
    static func build(withDelegate delegate: AddTrackerViewPresenterDelegate?, tracker: Tracker) -> UIViewController {
        let newTrackerViewPresenter = NewTrackerViewPresenter()
        let newTrackerViewController = NewTrackerViewController(withPresenter: newTrackerViewPresenter)
        newTrackerViewPresenter.delegate = delegate
        newTrackerViewPresenter.startEditing(tracker: tracker)
        return newTrackerViewController
    }
}
