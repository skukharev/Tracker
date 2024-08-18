//
//  TrackersCollectionViewCell.swift
//  Tracker
//
//  Created by Сергей Кухарев on 07.08.2024.
//

import UIKit

final class TrackersCollectionViewCell: UICollectionViewCell {
    // MARK: - Types

    enum Constants {
        static let identifier = "TrackersCollectionViewCell"
    }

    // MARK: - Public Properties

    weak var delegate: TrackersCollectionViewCellDelegate?

    // MARK: - Private Properties

    /// Плашка трекера
    private lazy var trackerSplashView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    /// Эмоджи трекера
    private lazy var trackersEmoji: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("", for: .normal)
        view.titleLabel?.font = GlobalConstants.ypMedium16
        view.contentVerticalAlignment = .center
        view.contentHorizontalAlignment = .center
        view.backgroundColor = .appTrackersCellButtonSplash
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    /// Наименование трекера
    private lazy var trackersName: UIButton = {
        let view = UIButton(type: .system)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("", for: .normal)
        view.setTitleColor(.appWhite, for: .normal)
        view.titleLabel?.font = GlobalConstants.ypMedium12
        view.contentHorizontalAlignment = .leading
        view.contentVerticalAlignment = .bottom
        view.isUserInteractionEnabled = false
        return view
    }()
    /// Лейбл с количеством повторений трекера
    private lazy var repeatsCount: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = GlobalConstants.ypMedium12
        view.tintColor = .appBlack
        view.text = ""
        return view
    }()
    /// Кнопка фиксации события трекера
    private lazy var recordButton: UIButton = {
        let view = UIButton(type: .system)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("", for: .normal)
        view.tintColor = .appWhite
        view.contentHorizontalAlignment = .center
        view.contentVerticalAlignment = .center
        view.layer.cornerRadius = 17
        view.layer.masksToBounds = true
        view.addTarget(self, action: #selector(recordButtonTouchUpInside(_:)), for: .touchUpInside)
        view.addTarget(self, action: #selector(recordButtonTouchDown(_:)), for: .touchDown)
        view.addTarget(self, action: #selector(recordButtonTouchUpOutside(_:)), for: .touchUpOutside)
        return view
    }()

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)

        createAndLayoutViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    /// Выводит на экран содержимое ячейки
    /// - Parameter model: Вью модель отображаемой ячейки
    func showCellViewModel(_ model: TrackersCellViewModel) {
        /// Плашка трекера
        trackerSplashView.backgroundColor = model.color
        /// Эмоджи трекера
        trackersEmoji.setTitle(model.emoji, for: .normal)
        /// Наименование трекера
        trackersName.setTitle(model.name, for: .normal)
        /// Количество повторений
        repeatsCount.text = model.daysCount.toStringWithSuffix(suffixOne: "день", suffixTwoFour: "дня", suffixDefault: "дней")
        /// Кнопка трекера
        recordButton.backgroundColor = model.color
        if model.isCompleted {
            self.recordButton.layer.opacity = 0.3
            self.recordButton.setImage(GlobalConstants.doneButton, for: .normal)
        } else {
            self.recordButton.layer.opacity = 1
            self.recordButton.setImage(GlobalConstants.plusButton, for: .normal)
        }
    }

    // MARK: - Private Methods

    /// Создаёт и размещает элементы управления во вью контроллере
    private func createAndLayoutViews() {
        contentView.backgroundColor = .appWhite
        contentView.addSubviews([trackerSplashView, trackersEmoji, trackersName, repeatsCount, recordButton])
        setupConstraints()
    }

    /// Создаёт констрейнты для элементов управления
    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                /// Плашка трекера
                trackerSplashView.topAnchor.constraint(equalTo: contentView.topAnchor),
                trackerSplashView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                trackerSplashView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                trackerSplashView.heightAnchor.constraint(equalToConstant: 90),
                /// Эмоджи
                trackersEmoji.topAnchor.constraint(equalTo: trackerSplashView.topAnchor, constant: 12),
                trackersEmoji.leadingAnchor.constraint(equalTo: trackerSplashView.leadingAnchor, constant: 12),
                trackersEmoji.widthAnchor.constraint(equalToConstant: 24),
                trackersEmoji.heightAnchor.constraint(equalToConstant: 24),
                /// Наименование трекера
                trackersName.topAnchor.constraint(equalTo: trackerSplashView.topAnchor, constant: 44),
                trackersName.leadingAnchor.constraint(equalTo: trackerSplashView.leadingAnchor, constant: 12),
                trackersName.trailingAnchor.constraint(equalTo: trackerSplashView.trailingAnchor, constant: -12),
                trackersName.bottomAnchor.constraint(equalTo: trackerSplashView.bottomAnchor, constant: -12),
                /// Количество повторений трекера
                repeatsCount.topAnchor.constraint(equalTo: trackerSplashView.bottomAnchor, constant: 16),
                repeatsCount.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
                /// Кнопка записи события трекера
                recordButton.topAnchor.constraint(equalTo: trackerSplashView.bottomAnchor, constant: 8),
                recordButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
                recordButton.widthAnchor.constraint(equalToConstant: 34),
                recordButton.heightAnchor.constraint(equalToConstant: 34)
            ]
        )
    }

    /// Обработчик нажатия на кнопку записи события
    /// - Parameter sender: Объект, генерирующий событие
    @objc private func recordButtonTouchUpInside(_ sender: UIButton) {
        UIView.animateKeyframes(withDuration: 0.2, delay: 0) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2) {
                sender.transform = .identity
            }
        }
        guard let delegate = delegate else { return }

        sender.isEnabled = false

        UIImpactFeedbackGenerator.initiate(style: .heavy, view: self).impactOccurred()

        delegate.trackersCollectionViewCellDidTapRecord(self) {
            DispatchQueue.main.async {
                sender.layer.removeAllAnimations()
                sender.isEnabled = true
            }
        }
    }

    /// Обработчик нажатия на кнопку записи события трекера
    /// - Parameter sender: Объект, генерирующий событие
    @objc private func recordButtonTouchDown(_ sender: UIButton) {
        UIView.animateKeyframes(withDuration: 0.2, delay: 0) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2) {
                sender.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }
        }
    }

    /// Обработчик отжатия кнопки записи события трекера
    /// - Parameter sender: ОБъект, генерирующий событие
    @objc private func recordButtonTouchUpOutside(_ sender: UIButton) {
        UIView.animateKeyframes(withDuration: 0.2, delay: 0) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2) {
                sender.transform = .identity
            }
        }
    }
}
