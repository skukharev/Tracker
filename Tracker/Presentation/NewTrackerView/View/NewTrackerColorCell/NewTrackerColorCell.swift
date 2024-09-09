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
        static let selectionViewCornerRadius: CGFloat = 16
        static let colorViewCornerRadius: CGFloat = 8
        static let colorViewSelectedBorderWidth: CGFloat = 3
        static let colorViewUnselectedBorderWidth: CGFloat = 0
        static let colorViewConstraints: CGFloat = 6
    }

    // MARK: - Public Properties

    weak var delegate: NewTrackerColorCellDelegate?

    // MARK: - Private Properties

    /// Плитка выделения ячейки
    private lazy var selectionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .appLightGray
        view.layer.cornerRadius = Constants.selectionViewCornerRadius
        view.layer.masksToBounds = true
        view.isHidden = true
        return view
    }()
    /// Плитка с цветом трекера
    private lazy var colorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Constants.colorViewCornerRadius
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
            colorView.layer.borderWidth = Constants.colorViewSelectedBorderWidth
            guard let delegate = delegate else { return }
            delegate.colorDidChange(model.color)
        } else {
            colorView.layer.borderWidth = Constants.colorViewUnselectedBorderWidth
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
                colorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.colorViewConstraints),
                colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.colorViewConstraints),
                colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.colorViewConstraints),
                colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.colorViewConstraints)
            ]
        )
    }
}
