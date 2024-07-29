//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Сергей Кухарев on 28.07.2024.
//

import Foundation
import UIKit

final class StatisticsViewController: UIViewController, StatisticsViewPresenterDelegate {
    // MARK: - Types

    // MARK: - Constants

    // MARK: - Public Properties

    // MARK: - IBOutlet

    // MARK: - Private Properties
    private var presenter: StatisticsViewPresenterProtocol?

    // MARK: - Initializers

    // MARK: - UIViewController(\*)

    // MARK: - Public Methods

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        createAndLayoutViews()
    }

    /// Используется для связи вью контроллера с презентером
    /// - Parameter presenter: презентер вью контроллера
    func configure(_ presenter: StatisticsViewPresenterProtocol) {
        self.presenter = presenter
        presenter.viewController = self
    }

    // MARK: - IBAction

    // MARK: - Private Methods

    /// Создаёт и размещает элементы управления во вью контроллере
    private func createAndLayoutViews() {
        view.backgroundColor = .appWhite
    }
}
