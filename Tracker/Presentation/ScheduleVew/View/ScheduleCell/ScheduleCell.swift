//
//  ScheduleCell.swift
//  Tracker
//
//  Created by Сергей Кухарев on 15.08.2024.
//

import UIKit

final class ScheduleCell: UITableViewCell {
    // MARK: - Types

    enum Constants {
        static let identifier = "ScheduleCell"
    }

    // MARK: - Public Properties

    weak var delegate: ScheduleCellDelegate?

    // MARK: - Private Properties
    private var weekDay: Weekday?

    /// Наименование дня недели
    private lazy var weekDayTitleLabel: InsetLabel = {
        let view = InsetLabel(insets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = GlobalConstants.ypRegular17
        view.textColor = .appBlack
        view.textAlignment = .natural
        return view
    }()
    /// Переключатель дня недели
    private lazy var weekDayToggle: UISwitch = {
        let view = UISwitch()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.onTintColor = .appBlue
        view.addTarget(self, action: #selector(weekDayToggleValueChanged(_ :)), for: .valueChanged)
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

    func showCellViewModel(_ model: ScheduleCellModel) {
        self.weekDay = model.weekDay
        weekDayTitleLabel.text = model.weekDayName
        weekDayToggle.isOn = model.isSelected
    }

    // MARK: - Private Methods

    /// Добавляет элементы управления и их констрейнты в ячейке
    private func createAndLayoutViews() {
        contentMode = .scaleToFill
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubviews([weekDayTitleLabel, weekDayToggle])
        setupConstraints()
    }

    /// Создаёт констрейнты для элементов управления
    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                /// Наименование дня недели
                weekDayTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                weekDayTitleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                /// Переключатель дня недели
                weekDayToggle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                weekDayToggle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ]
        )
    }

    /// Обработчик, вызываемый при изменении переключателя дня недели
    /// - Parameter sender: объект, инициировавший событие
    @objc private func weekDayToggleValueChanged(_ sender: UISwitch) {
        guard let weekDay = weekDay else { return }
        delegate?.weekDayScheduleChange(weekDay: weekDay, isSelected: sender.isOn)
    }
}
