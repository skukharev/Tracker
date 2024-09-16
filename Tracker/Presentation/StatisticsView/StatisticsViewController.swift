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

    enum Constants {
        static let statisticsStubImageName = "StatisticsStub"
        static let statisticsStubImageLabelText = NSLocalizedString("statisticsStubImageLabelText", comment: "")
        static let statisticsStubImageWidthConstraint: CGFloat = 80
        static let statisticsStubImageLabelTopConstraint: CGFloat = 8
    }

    // MARK: - Private Properties
    private var presenter: StatisticsViewPresenterProtocol?

    /// Заглушка 
    /// Заглушка списка с трекерами
    private lazy var statisticsStubImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        guard let stubImage = UIImage(named: Constants.statisticsStubImageName) else {
            assertionFailure("Ошибка загрузки логотипа заглушки")
            return image
        }
        image.image = stubImage
        image.contentMode = .center
        return image
    }()
    /// Текст заглушки списка с трекерами
    private lazy var statisticsStubImageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = GlobalConstants.ypMedium12
        label.textColor = .appBlack
        label.text = Constants.statisticsStubImageLabelText
        return label
    }()

    // MARK: - Initializers

    override func viewDidLoad() {
        super.viewDidLoad()
        createAndLayoutViews()
    }

    // MARK: - Public Methods

    /// Используется для связи вью контроллера с презентером
    /// - Parameter presenter: презентер вью контроллера
    func configure(_ presenter: StatisticsViewPresenterProtocol) {
        self.presenter = presenter
        presenter.viewController = self
    }

    // MARK: - Private Methods

    /// Создаёт и размещает элементы управления во вью контроллере
    private func createAndLayoutViews() {
        view.backgroundColor = .appWhite
        /// Панель навигации
        navigationItem.title = GlobalConstants.statisticsTabBarItemTitle
        navigationController?.navigationBar.prefersLargeTitles = true
        /// Элементы управления
        view.addSubviews([statisticsStubImage, statisticsStubImageLabel])
        /// Разметка элементов управления
        setupConstraints()
    }

    /// Создаёт констрейнты для элементов управления
    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                // Заглушка
                statisticsStubImage.widthAnchor.constraint(equalToConstant: Constants.statisticsStubImageWidthConstraint),
                statisticsStubImage.heightAnchor.constraint(equalToConstant: Constants.statisticsStubImageWidthConstraint),
                statisticsStubImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                statisticsStubImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
                // Текст заглушки
                statisticsStubImageLabel.topAnchor.constraint(equalTo: statisticsStubImage.bottomAnchor, constant: Constants.statisticsStubImageLabelTopConstraint),
                statisticsStubImageLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
            ]
        )
    }
}
