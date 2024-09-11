//
//  CategoryCell.swift
//  Tracker
//
//  Created by Сергей Кухарев on 10.09.2024.
//

import UIKit

final class CategoryCell: UITableViewCell {
    // MARK: - Types

    enum Constants {
        static let identifier = "CategoryCell"
        static let categoryNameInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        static let categoryNameFont = GlobalConstants.ypRegular17
        static let categoryNameTextColor = UIColor.appBlack
    }

    // MARK: - Private Properties

    private lazy var labelsContainer: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.distribution = .equalSpacing
        view.alignment = .leading
        return view
    }()
    /// Наименование категории
    private lazy var categoryNameLabel: InsetLabel = {
        let view = InsetLabel(insets: Constants.categoryNameInsets)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = Constants.categoryNameFont
        view.textColor = Constants.categoryNameTextColor
        view.textAlignment = .natural
        return view
    }()

    // MARK: - Initializers

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createAndLayoutViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    public func configureCell(with model: CategoryCellModel) {
        categoryNameLabel.text = model.name
        if model.isSelected {
            self.accessoryType = .checkmark
        } else {
            self.accessoryType = .none
        }
    }

    // MARK: - Private Methods

    /// Добавляет элементы управления и их констрейнты в ячейке
    private func createAndLayoutViews() {
        backgroundColor = .clear
        selectionStyle = .none
        labelsContainer.addArrangedSubview(categoryNameLabel)
        contentView.addSubviews([labelsContainer])
        setupConstraints()
    }

    /// Создаёт констрейнты для элементов управления
    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                labelsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                labelsContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ]
        )
    }
}
