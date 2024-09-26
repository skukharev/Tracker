//
//  StatisticsViewProtocol.swift
//  Tracker
//
//  Created by Сергей Кухарев on 28.07.2024.
//

import Foundation

protocol StatisticsViewPresenterProtocol: AnyObject {
    /// Ассоциированный вью контроллер
    var viewController: StatisticsViewPresenterDelegate? { get set }
    /// Запускает подсчёт статистики
    func calculateStatistics()
    /// Конифугрирует ячейку для её отображения в коллекции
    /// - Parameters:
    ///   - cell: Объект-ячейка
    ///   - indexPath: Индекс ячейки внутри коллекции
    func showCell(for cell: StatisticsCollectionViewCell, with indexPath: IndexPath)
    /// Возвращает количество ячеек со статистикой
    func statisticsCount() -> Int
}
