//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Сергей Кухарев on 28.07.2024.
//

import Foundation
import UIKit

final class TrackersViewController: UIViewController, TrackersViewPresenterDelegate {
    // MARK: - Types

    private enum Identifiers {
        static let addTrackerButtonImageName = "AddTrackerImage"
        static let trackersStubImageName = "TrackersStub"
    }

    // MARK: - Constants

    // MARK: - Public Properties

    // MARK: - IBOutlet

    // MARK: - Private Properties

    private var presenter: TrackersViewPresenterProtocol?
    /// Верхняя группа элементов
    private lazy var topContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    /// Кнопка "Добавить трекер"
    private lazy var addTrackerButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: Identifiers.addTrackerButtonImageName), for: .normal)
        button.tintColor = .appBlack
        button.addTarget(self, action: #selector(addTrackerTouchUpInside), for: .touchUpInside)
        button.accessibilityIdentifier = "AddTracker"
        return button
    }()
    /// Заголовок "Трекеры"
    private lazy var trackersLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Constants.ypBold34
        label.textColor = .appBlack
        label.text = "Трекеры"
        return label
    }()
    /// Заглушка списка с трекерами
    private lazy var trackersStubImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        guard let stubImage = UIImage(named: Identifiers.trackersStubImageName) else {
            assertionFailure("Ошибка загрузки логотипа заглушки")
            return image
        }
        image.image = stubImage
        image.contentMode = .center
        return image
    }()
    /// Текст заглушки списка с трекерами
    private lazy var trackersStubImageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Constants.ypMedium12
        label.textColor = .appBlack
        label.text = "Что будем отслеживать?"
        return label
    }()

    // MARK: - Initializers

    // MARK: - UIViewController(\*)

    // MARK: - Public Methods

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        createAndLayoutViews()
        guard let presenter = presenter else {
            assertionFailure("Необходимо определить презентер для TrackersViewController")
            return
        }
        presenter.loadTrackers()
    }

    /// Используется для связи вью контроллера с презентером
    /// - Parameter presenter: презентер вью контроллера
    func configure(_ presenter: TrackersViewPresenterProtocol) {
        self.presenter = presenter
        presenter.viewController = self
    }

    func showTrackersListStub() {
        if !view.subviews.contains(trackersStubImage) {
            view.addSubviews([trackersStubImage, trackersStubImageLabel])
            NSLayoutConstraint.activate(
                [
                    // Заглушка
                    trackersStubImage.widthAnchor.constraint(equalToConstant: 80),
                    trackersStubImage.heightAnchor.constraint(equalToConstant: 80),
                    trackersStubImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                    trackersStubImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
                    // Текст заглушки
                    trackersStubImageLabel.topAnchor.constraint(equalTo: trackersStubImage.bottomAnchor, constant: 8),
                    trackersStubImageLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
                ]
            )
        } else {
            trackersStubImage.isHidden = false
        }
    }
    // MARK: - IBAction

    // MARK: - Private Methods
    /// Обработчик нажатия кнопки "Добавить трекер"
    @objc private func addTrackerTouchUpInside() {}

    /// Создаёт и размещает элементы управления во вью контроллере
    private func createAndLayoutViews() {
        view.backgroundColor = .appWhite
        title = "Трекеры"
        topContainer.addSubviews([addTrackerButton, trackersLabel])
        view.addSubviews([topContainer])
        setupConstraints()
    }

    // Создаёт констрейнты для элементов управления
    private func setupConstraints() {
        trackersLabel.sizeToFit()       // используется для вычисления размеров заголовка и определения корректной высоты topContainer
        let topContainerHeaight = 1 + 42 + 1 + trackersLabel.frame.height + 10

        NSLayoutConstraint.activate(
            [
                // Верхняя навигационная панель
                topContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                topContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                topContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                topContainer.heightAnchor.constraint(equalToConstant: topContainerHeaight),
                // Кнопка "Добавить трекер"
                addTrackerButton.topAnchor.constraint(equalTo: topContainer.topAnchor, constant: 1),
                addTrackerButton.leadingAnchor.constraint(equalTo: topContainer.leadingAnchor, constant: 6),
                addTrackerButton.widthAnchor.constraint(equalToConstant: 42),
                addTrackerButton.heightAnchor.constraint(equalToConstant: 42),
                // Заголовок "Трекеры"
                trackersLabel.topAnchor.constraint(equalTo: addTrackerButton.bottomAnchor, constant: 1),
                trackersLabel.leadingAnchor.constraint(equalTo: topContainer.leadingAnchor, constant: 16)
            ]
        )
    }
}
