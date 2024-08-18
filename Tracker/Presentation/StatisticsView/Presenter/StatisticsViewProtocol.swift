//
//  StatisticsViewProtocol.swift
//  Tracker
//
//  Created by Сергей Кухарев on 28.07.2024.
//

import Foundation

protocol StatisticsViewPresenterProtocol: AnyObject {
    var viewController: StatisticsViewPresenterDelegate? { get set }
}
