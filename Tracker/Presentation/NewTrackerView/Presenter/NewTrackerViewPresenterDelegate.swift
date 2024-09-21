//
//  NewTrackerPresenterDelegate.swift
//  Tracker
//
//  Created by Сергей Кухарев on 12.08.2024.
//

import UIKit

protocol NewTrackerViewPresenterDelegate: AnyObject {
    /// Скрывает предупреждение о недопустимом значении нименования трекера
    func hideTrackersNameViolation()
    /// Отображает предупреждение о недопустимом значении наименования трекера
    func showTrackersNameViolation()
    /// Меняет внешний вид кнопки записи трекера на недоступный для записи
    func setCreateButtonEnable()
    /// Меняет внешний вид кнопки записи трекера на доступный для записи
    func setCreateButtonDisable()
    /// Выделяет цвет с заданным индексом в коллекции цветов
    /// - Parameter indexPath: Индекс цвета
    func setColor(at indexPath: IndexPath)
    /// Выделяет эмоджи с заданным индексом в коллекции эмоджи
    /// - Parameter indexPath: Индекс эмоджи
    func setEmoji(at indexPath: IndexPath)
    /// Заполняет поле ввода названия трекера заданным текстом
    /// - Parameter text: текст с названием трекера
    func setTrackerName(_ text: String)
    /// Устанавливает заголовок с текстом количества дней повторений трекера (для привычек)
    /// - Parameter title: текст с количеством дней повторений трекера
    func setTrackerRepeatsCountTitle(_ title: String)
    /// Устанавливает заголовок экрана редактирования трекера
    /// - Parameter title: Текст заголовка
    func setViewControllerTitle(_ title: String)
    /// Устанавливает заголовок кнопки записи трекера
    /// - Parameter title: текст с заголовком кнопки
    func setSaveButtonTitle(_ title: String)
    /// Конфигурирует представление в зависимости от типа добавляемого трекера
    /// - Parameter trackerType: Тип трекера
    func setupViewsWithTrackerType(trackerType: TrackerType)
    /// Обновляет внешний вид кнопок "Категория" и "Расписание"
    func updateButtonsPanel()
}
