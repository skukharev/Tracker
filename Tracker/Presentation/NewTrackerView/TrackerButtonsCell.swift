//
//  TrackerButtonsCell.swift
//  Tracker
//
//  Created by Сергей Кухарев on 14.08.2024.
//

import UIKit

final class TrackerButtonsCell: UITableViewCell {
    // MARK: - Types

    enum Constants {
        static let identifier = "TrackerButtonsCell"
    }

    // MARK: - Private Properties

    private lazy var labelsContainer: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.distribution = .fillProportionally
        view.spacing = 2
        return view
    }()
    /// Заголовок кнопки
    private lazy var titleLabel: InsetLabel = {
        let view = InsetLabel(insets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = GlobalConstants.ypRegular17
        view.textColor = .appBlack
        view.textAlignment = .natural
        return view
    }()
    /// Подзаголовок кнопки
    private lazy var subtitleLabel: InsetLabel = {
        let view = InsetLabel(insets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = GlobalConstants.ypRegular17
        view.textColor = .appGray
        view.textAlignment = .natural
        view.isHidden = true
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

    public func configureButton(title: String, subTitle: String? = nil) {
        titleLabel.text = title
        subtitleLabel.text = subTitle
        subtitleLabel.isHidden = subTitle == nil
    }

    // MARK: - Private Methods

    /// Добавляет элементы управления и их констрейнты в ячейке
    private func createAndLayoutViews() {
        backgroundColor = .clear
        selectionStyle = .none
        labelsContainer.addArrangedSubview(titleLabel)
        labelsContainer.addArrangedSubview(subtitleLabel)
        addSubviews([labelsContainer])
        setupConstraints()
    }

    /// Создаёт констрейнты для элементов управления
    private func setupConstraints() {
        labelsContainer.edgesToSuperview()
    }
}
