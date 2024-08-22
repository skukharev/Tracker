//
//  NewTrackerColorCell.swift
//  Tracker
//
//  Created by Сергей Кухарев on 21.08.2024.
//

import UIKit

final class NewTrackerColorCell: UICollectionViewCell {
    // MARK: - Types
    enum Constants {
        static let identifier = "NewTrackerColorCell"
    }

    // MARK: - Public Properties

    weak var delegate: NewTrackerColorCellDelegate?

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
    /// Плитка с цветом трекера
    private lazy var colorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.masksToBounds = true
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
    func showCellViewModel(_ model: NewTrackerColorCellModel) {
        colorView.backgroundColor = model.color
        selectionView.backgroundColor = model.color.withAlphaComponent(0.3)
        selectionView.isHidden = !model.isSelected
        if model.isSelected {
            colorView.layer.borderWidth = 3
            guard let delegate = delegate else { return }
            delegate.colorDidChange(model.color)
        } else {
            colorView.layer.borderWidth = 0
        }
    }

    // MARK: - Private Methods

    /// Создаёт и размещает элементы управления во вью контроллере
    private func createAndLayoutViews() {
        contentView.addSubviews([selectionView, colorView])
        setupConstraints()
    }

    /// Создаёт констрейнты для элементов управления
    private func setupConstraints() {
        selectionView.edgesToSuperview()
        NSLayoutConstraint.activate(
            [
                colorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
                colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
                colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
                colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
            ]
        )
    }
}
