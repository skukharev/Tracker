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

    func showNext(dismissCurrent: Bool = true, animatedDismissCurrent: Bool = true, animatedShowTarget: Bool = true) {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        if dismissCurrent {
            viewController.dismiss(animated: animatedDismissCurrent)
            window.rootViewController?.present(targetViewController, animated: animatedShowTarget)
        } else {
            viewController.present(targetViewController, animated: animatedShowTarget)
        }
    }
}
