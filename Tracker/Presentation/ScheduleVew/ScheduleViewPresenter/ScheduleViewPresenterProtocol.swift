//
//  TrackerScheduleViewPresenterProtocol.swift
//  Tracker
//
//  Created by Сергей Кухарев on 15.08.2024.
//

import UIKit

protocol ScheduleViewPresenterProtocol: AnyObject, UITableViewDataSource, UITableViewDelegate {
    /// Ассоциированный вью контроллер
    var viewController: ScheduleViewPresenterDelegate? { get set }
    /// Отображает окно выбора расписания повторения трекера
    /// - Parameters:
    ///   - schedule: начальное состояние расписания
    ///   - viewController: текущий, отображаемый, вью контроллер
    ///   - delegate: делегат, вызывающий данный метод
    func showTrackerSchedule(with schedule: Set<Weekday>, on viewController: UIViewController, by delegate: NewTrackerViewPresenterProtocol)
    /// Вызывается при сокрытии экрана настройки расписания запуска и необходимости обновить расписание трекера
    func needSaveSchedule()
}
