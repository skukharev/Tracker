//
//  FilterCell.swift
//  Tracker
//
//  Created by Сергей Кухарев on 23.09.2024.
//

import UIKit

final class FilterCell: UITableViewCell {
    // MARK: - Types

    enum Constants {
        static let identifier = "FilterCell"
        static let filterNameInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        static let filterNameFont = GlobalConstants.ypRegular17
        static let filterNameTextColor = UIColor.appBlack
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
    private lazy var filterNameLabel: InsetLabel = {
        let view = InsetLabel(insets: Constants.filterNameInsets)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = Constants.filterNameFont
        view.textColor = Constants.filterNameTextColor
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

    public func configureCell(with model: FilterCellModel) {
        filterNameLabel.text = model.title
        if model.isSelected {
            self.accessoryType = .checkmark
        } else {
            self.accessoryType = .none
        }
    }

    // MARK: - Private Methods

    private func createAndLayoutViews() {
        backgroundColor = .clear
        selectionStyle = .none
        labelsContainer.addArrangedSubview(filterNameLabel)
        contentView.addSubviews([labelsContainer])
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                labelsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                labelsContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ]
        )
    }
}
