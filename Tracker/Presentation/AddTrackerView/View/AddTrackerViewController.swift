//
//  AddTrackerViewController.swift
//  Tracker
//
//  Created by Сергей Кухарев on 11.08.2024.
//

import UIKit

final class AddTrackerViewController: UIViewController, AddTrackerViewControllerDelegate {
    // MARK: - Types

    enum Constants {
        static let viewTitleText = L10n.viewTitleText
        static let viewTitleTopConstraint: CGFloat = 27
        static let addHabitButtonTitle = L10n.addHabitButtonTitle
        static let addHabitButtonCornerRadius: CGFloat = 16
        static let addEventButtonTitle = L10n.addEventButtonTitle
        static let addEventButtonCornerRadius: CGFloat = 16
        static let buttonsContainerLeadingConstraint: CGFloat = 20
        static let buttonsContainerHeightConstraint: CGFloat = 136
        static let addHabitButtonHeightConstraint: CGFloat = 60
        static let addEventButtonTopConstraint: CGFloat = 16
        static let addEventButtonHeightConstraint: CGFloat = 60
    }

    // MARK: - Public Properties

    var presenter: AddTrackerViewPresenterProtocol?

    // MARK: - Private Properties

    /// Заголовок окна
    private lazy var viewTitle: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = GlobalConstants.ypMedium16
        view.textColor = .appBlack
        view.text = Constants.viewTitleText
        return view
    }()
    /// Контейнер для удобного размещения кнопок в соответствии с дизайном
    private lazy var buttonsContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    /// Кнопка "Добавить привычку"
    private lazy var addHabitButton: UIButton = {
        let view = UIButton(type: .system)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitleColor(.appWhite, for: .normal)
        view.setTitle(Constants.addHabitButtonTitle, for: .normal)
        view.backgroundColor = .appBlack
        view.titleLabel?.font = GlobalConstants.ypMedium16
        view.contentVerticalAlignment = .center
        view.contentHorizontalAlignment = .center
        view.layer.cornerRadius = Constants.addHabitButtonCornerRadius
        view.layer.masksToBounds = true
        view.addTarget(self, action: #selector(addHabitButtonTouchUpInside(_:)), for: .touchUpInside)
        return view
    }()
    /// Кнопка "Добавить нерегулярное событие"
    private lazy var addEventButton: UIButton = {
        let view = UIButton(type: .system)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitleColor(.appWhite, for: .normal)
        view.setTitle(Constants.addEventButtonTitle, for: .normal)
        view.backgroundColor = .appBlack
        view.titleLabel?.font = GlobalConstants.ypMedium16
        view.contentVerticalAlignment = .center
        view.contentHorizontalAlignment = .center
        view.layer.cornerRadius = Constants.addEventButtonCornerRadius
        view.layer.masksToBounds = true
        view.addTarget(self, action: #selector(addEventButtonTouchUpInside(_:)), for: .touchUpInside)
        return view
    }()

    // MARK: - Initializers

    override func viewDidLoad() {
        super.viewDidLoad()
        createAndLayoutViews()
    }

    // MARK: - Private Methods

    /// Обработчик нажатия на кнопку "Добавить привычку"
    /// - Parameter sender: объект-иницатор события
    @objc private func addHabitButtonTouchUpInside(_ sender: UIButton) {
        let impact = UIImpactFeedbackGenerator.initiate(style: .heavy, view: self.view)
        impact.impactOccurred()
        presenter?.addHabit()
    }

    /// Обработчик нажатия на кнопку "Добавить нерегулярное событие"
    /// - Parameter sender: объект-инициатор события
    @objc private func addEventButtonTouchUpInside(_ sender: UIButton) {
        let impact = UIImpactFeedbackGenerator.initiate(style: .heavy, view: self.view)
        impact.impactOccurred()
        presenter?.addEvent()
    }

    /// Создаёт и размещает элементы управления во вью контроллере
    private func createAndLayoutViews() {
        view.backgroundColor = .appWhite
        buttonsContainer.addSubviews([addHabitButton, addEventButton])
        view.addSubviews([viewTitle, buttonsContainer])
        setupConstraints()
    }

    /// Создаёт констрейнты для элементов управления
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            /// Заголовок окна
            viewTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.viewTitleTopConstraint),
            viewTitle.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            /// Контейнер для кнопок
            buttonsContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.buttonsContainerLeadingConstraint),
            buttonsContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.buttonsContainerLeadingConstraint),
            buttonsContainer.heightAnchor.constraint(equalToConstant: Constants.buttonsContainerHeightConstraint),
            buttonsContainer.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            /// Кнопка "Привычка"
            addHabitButton.topAnchor.constraint(equalTo: buttonsContainer.topAnchor),
            addHabitButton.leadingAnchor.constraint(equalTo: buttonsContainer.leadingAnchor),
            addHabitButton.trailingAnchor.constraint(equalTo: buttonsContainer.trailingAnchor),
            addHabitButton.heightAnchor.constraint(equalToConstant: Constants.addHabitButtonHeightConstraint),
            /// Кнопка "Нерегулярное событие"
            addEventButton.topAnchor.constraint(equalTo: addHabitButton.bottomAnchor, constant: Constants.addEventButtonTopConstraint),
            addEventButton.leadingAnchor.constraint(equalTo: buttonsContainer.leadingAnchor),
            addEventButton.trailingAnchor.constraint(equalTo: buttonsContainer.trailingAnchor),
            addEventButton.heightAnchor.constraint(equalToConstant: Constants.addEventButtonHeightConstraint)
        ])
    }
}
