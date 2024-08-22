//
//  NewTrackerEmojiCell.swift
//  Tracker
//
//  Created by Сергей Кухарев on 20.08.2024.
//

import UIKit

final class NewTrackerEmojiCell: UICollectionViewCell {
    // MARK: - Types
    enum Constants {
        static let identifier = "NewTrackerEmojiCell"
    }

    // MARK: - Public Properties

    weak var delegate: NewTrackerEmojiCellDelegate?

    // MARK: - Private Properties

    /// Плитка выделения ячейки
    private lazy var selectionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .appLightGray
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.isHidden = true
        return view
    }()
    /// Эмоджи
    private lazy var emojiLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = GlobalConstants.ypBold32
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
    func showCellViewModel(_ model: NewTrackerEmojiCellModel) {
        emojiLabel.text = model.emoji
        selectionView.isHidden = !model.isSelected
        if model.isSelected {
            guard let delegate = delegate else { return }
            delegate.emojiDidChange(model.emoji)
        }
    }

    // MARK: - Private Methods

    /// Создаёт и размещает элементы управления во вью контроллере
    private func createAndLayoutViews() {
        contentView.addSubviews([selectionView, emojiLabel])
        setupConstraints()
    }

    /// Создаёт констрейнты для элементов управления
    private func setupConstraints() {
        selectionView.edgesToSuperview()
        NSLayoutConstraint.activate(
            [
                emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ]
        )
    }
}
