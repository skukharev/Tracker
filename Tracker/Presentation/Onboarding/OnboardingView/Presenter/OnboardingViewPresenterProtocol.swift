//
//  OnboardingViewPresenterProtocol.swift
//  Tracker
//
//  Created by Сергей Кухарев on 08.09.2024.
//

import UIKit

protocol OnboardingViewPresenterProtocol: AnyObject {
    /// Массив вью контроллеров, отображаемых на экране онбординга
    var pages: [UIViewController] { get set }
    /// Ассоциированный вью контроллер
    var viewController: OnboardingViewPresenterDelegate? { get set }
    /// Обработчик нажатия на кнопку входа в основную часть приложения
    func didLaunchApplicationButtonPressed()
}
