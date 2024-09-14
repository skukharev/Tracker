//
//  TrackerCategoryStoreUpdate.swift
//  Tracker
//
//  Created by Сергей Кухарев on 10.09.2024.
//

import Foundation

/// Структура для хранения индексов обновлённых данных табличного представления с категориями трекеров. Используется TrackerCategoryStore
struct TrackerCategoryStoreUpdate {
    let insertedIndexes: IndexSet?
    let deletedIndexes: IndexSet?
    let updatedIndexes: IndexSet?
}
