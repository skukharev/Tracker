//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by Сергей Кухарев on 08.09.2024.
//

import UIKit

final class OnboardingPageViewController: UIViewController {
    // MARK: - Types

    enum Constants {
        static let onboardingLabelFont = GlobalConstants.ypBold32
        static let onboardingLabelTextAlignment: NSTextAlignment = .center
        static let onboardingLabelTextColor: UIColor = .appBlackUniversal
        static let onboardingLabelLeadingConstraint: CGFloat = 16
        static let onboardingLabelLowResBottomConstraint: CGFloat = 200
        static let onboardingLabelHighResBottomConstraint: CGFloat = 270
    }

    // MARK: - Private Properties

    /// Изображение страницы с онбордингом
    private let onboardingImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        return view
    }()
    /// Текст страницы с онбордингом
    private let onboardingLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = Constants.onboardingLabelFont
        view.textAlignment = Constants.onboardingLabelTextAlignment
        view.textColor = Constants.onboardingLabelTextColor
        view.numberOfLines = 3
        return view
    }()

    // MARK: - Initializers

    override func viewDidLoad() {
        super.viewDidLoad()
        createAndLayoutViews()
    }

    // MARK: - Public Methods

    /// Отображает на экране страницу онбординга в соответствии с моделью
    /// - Parameter model: изображение и текст страницы онбординга
    func showOnboardingPage(withModel model: OnboardingPage) {
        onboardingImageView.image = model.image
        onboardingLabel.text = model.title
    }

    // MARK: - Private Methods

    /// Создаёт и размещает элементы управления во вью контроллере
    private func createAndLayoutViews() {
        view.addSubviews([onboardingImageView, onboardingLabel])
        setupConstraints()
    }

    /// Создаёт констрейнты для элементов управления
    private func setupConstraints() {
        onboardingImageView.edgesToSuperview()
        NSLayoutConstraint.activate(
            [
                /// Текст страницы с онбордингом
                onboardingLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.onboardingLabelLeadingConstraint),
                onboardingLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.onboardingLabelLeadingConstraint)
            ]
        )
        if UIDevice.current.isiPhoneSE {
            NSLayoutConstraint.activate(
                [
                    /// Текст страницы с онбордингом
                    onboardingLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.onboardingLabelLowResBottomConstraint)
                ]
            )
        } else {
            NSLayoutConstraint.activate(
                [
                    /// Текст страницы с онбордингом
                    onboardingLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.onboardingLabelHighResBottomConstraint)
                ]
            )
        }
    }
}
