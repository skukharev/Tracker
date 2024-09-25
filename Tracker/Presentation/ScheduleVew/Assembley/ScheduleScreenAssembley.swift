//
//  ScheduleScreenAssembley.swift
//  Tracker
//
//  Created by Сергей Кухарев on 18.08.2024.
//

import UIKit

enum ScheduleScreenAssembley {
    static func build(withDelegate delegate: NewTrackerViewPresenterProtocol?, forSchedule schedule: Week) -> UIViewController {
        let scheduleViewPresenter = ScheduleViewPresenter()
        let scheduleVewController = ScheduleViewController(withPresenter: scheduleViewPresenter)
        scheduleViewPresenter.schedule = schedule
        scheduleViewPresenter.delegate = delegate
        return scheduleVewController
    }
}
