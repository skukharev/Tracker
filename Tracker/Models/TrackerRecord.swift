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

    /// Конструктор структуры
    /// - Parameters:
    ///   - trackerId: Идентификатор трекера
    ///   - recordDate: Дата фиксации выполнения трекера. Дата записывается без отметки времени выполнения
    init(trackerId: UUID, recordDate: Date) {
        self.trackerId = trackerId
        self.recordDate = recordDate.removeTimeStamp
    }
}
