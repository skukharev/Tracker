//
//  TrackersFilterScreenAssembley.swift
//  Tracker
//
//  Created by Сергей Кухарев on 23.09.2024.
//

import UIKit

enum TrackersFilterScreenAssembley {
    static func build(withDelegate delegate: TrackersFilterDelegate, withCurrentFilter filter: TrackersFilter) -> UIViewController {
        let trackersFilterViewPresenter = TrackersFilterViewPresenter()
        let trackersFilterViewController = TrackersFilterViewController(withPresenter: trackersFilterViewPresenter)
        trackersFilterViewPresenter.delegate = delegate
        trackersFilterViewPresenter.setFilter(with: filter)
        return trackersFilterViewController
    }
}
