//
//  TrackerScheduleViewPresenterProtocol.swift
//  Tracker
//
//  Created by Сергей Кухарев on 15.08.2024.
//

import UIKit

protocol ScheduleViewPresenterProtocol: AnyObject {
    /// Ассоциированный вью контроллер
    var viewController: ScheduleViewPresenterDelegate? { get set }
    /// Конфигурирует ячейки табличного представления с расписанием
    /// - Parameters:
    ///   - cell: ссылка на ячейку
    ///   - indexPath: индекс ячейки
    func configureScheduleCell(for cell: ScheduleCell, with indexPath: IndexPath)
    /// Вызывается при сокрытии экрана настройки расписания запуска и необходимости обновить расписание трекера
    func needSaveSchedule()
}
