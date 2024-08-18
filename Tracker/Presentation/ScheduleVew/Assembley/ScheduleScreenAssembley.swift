//
//  ScheduleScreenAssembley.swift
//  Tracker
//
//  Created by Сергей Кухарев on 18.08.2024.
//

import UIKit

enum ScheduleScreenAssembley {
    static func build(withDelegate delegate: NewTrackerViewPresenterProtocol?, forSchedule schedule: Week) -> UIViewController {
        let scheduleVewController = ScheduleViewController()
        let scheduleViewPresenter = ScheduleViewPresenter()
        scheduleViewPresenter.schedule = schedule
        scheduleViewPresenter.delegate = delegate
        scheduleVewController.presenter = scheduleViewPresenter
        scheduleViewPresenter.viewController = scheduleVewController
        return scheduleVewController
    }
}
