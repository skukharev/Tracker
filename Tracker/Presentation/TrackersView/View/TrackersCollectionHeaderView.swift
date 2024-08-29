//
//  TrackersCollectionHeaderView.swift
//  Tracker
//
//  Created by Сергей Кухарев on 11.08.2024.
//

import UIKit

final class TrackersCollectionHeaderView: UICollectionReusableView {
    // MARK: - Types

    enum Constants {
        static let identifier = "TrackersCollectionViewHeader"
    }

    // MARK: - Private Properties

    /// Заголовок секции
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = GlobalConstants.ypBold19
        view.textColor = .appBlack
        view.text = ""
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

    /// Отображает заданный текст в заголовке секции
    /// - Parameter headerTitle: Текст заголовка
    func setSectionHeaderTitle(_ headerTitle: String) {
        titleLabel.text = headerTitle
    }

    // MARK: - Private Methods

    /// Создаёт и размещает элементы управления во вью контроллере
    private func createAndLayoutViews() {
        addSubviews([titleLabel])
        setupConstraints()
    }

    /// Создаёт констрейнты для элементов управления
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 12)
        ])
    }
}
