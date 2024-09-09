//
//  Router.swift
//  Tracker
//
//  Created by Сергей Кухарев on 17.08.2024.
//

import UIKit

/// Используется для отображения переходов между экранами приложения
final class Router {
    // MARK: - Private Properties
    /// Текущий вью контроллер
    private var viewController: UIViewController
    /// Целевой вью контроллер
    private var targetViewController: UIViewController

    // MARK: - Initializers

    init(viewController: UIViewController, targetViewController: UIViewController) {
        self.viewController = viewController
        self.targetViewController = targetViewController
    }

    // MARK: - Public Methods

    /// Отображает заданный свойством targetViewController вью контроллер на экране
    /// - Parameters:
    ///   - dismissCurrent: если Истина, то текущий вью контроллер скрывается с экрана, в противном случае - текущий вью контроллер остаётся на экране, а новый вью контроллер отображается поверх него. Значение по умолчанию - Истина
    ///   - animatedDismissCurrent: если Истина и значение параметра dismissCurrent=Истина, то текущий вью контроллер скрывается с экрана с использованием анимации; если Ложь и значение параметра dismissCurrent=Истина, то текущий вью контроллер скрывается с экрана без использования анимации. Значение по умолчанию - Истина
    ///   - animatedShowTarget: если Истина, то новый вью контроллер показывается на экране с использованием анимации, в противном случае - без использования анимации. Значение по умолчанию - Истина
    func showNext(dismissCurrent: Bool = true, animatedDismissCurrent: Bool = true, animatedShowTarget: Bool = true) {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Ошибка получения ссылки на экран устройства")
            return
        }
        if dismissCurrent {
            if viewController.presentingViewController != nil {
                viewController.dismiss(animated: animatedDismissCurrent)
                window.rootViewController?.present(targetViewController, animated: animatedShowTarget)
            } else {
                window.rootViewController = targetViewController
            }
        } else {
            viewController.present(targetViewController, animated: animatedShowTarget)
        }
    }
}
