//
//  TrackerRecord.swift
//  Tracker
//
//  Created by Сергей Кухарев on 31.07.2024.
//

import Foundation

/// Сущность для хранения записи о том, что некий трекер был выполнен на некоторую дату
public struct TrackerRecord: Hashable {
    /// Идентификатор трекера
    let trackerId: UUID
    /// Дата, в которую был выполнен трекер
    let recordDate: Date
}
