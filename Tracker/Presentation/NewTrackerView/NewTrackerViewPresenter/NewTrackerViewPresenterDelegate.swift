//
//  NewTrackerPresenterDelegate.swift
//  Tracker
//
//  Created by Сергей Кухарев on 12.08.2024.
//

import UIKit

protocol NewTrackerViewPresenterDelegate: AnyObject {
    /// Тип обрабатываемого трекера
    var trackerType: TrackerType? { get }
    /// Скрывает предупреждение о недопустимом значении нименования трекера
    func hideTrackersNameViolation()
    /// Отображает модально вью контроллер
    func showViewController(_ viewController: UIViewController)
    /// Отображает предупреждение о недопустимом значении наименования трекера
    func showTrackersNameViolation()
    /// Меняет внешний вид кнопки записи трекера на недоступный для записи
    func setCreateButtonEnable()
    /// Меняет внешний вид кнопки записи трекера на доступный для записи
    func setCreateButtonDisable()
    /// Обновляет внешний вид кнопок "Категория" и "Расписание"
    func updateButtonsPanel()
}
