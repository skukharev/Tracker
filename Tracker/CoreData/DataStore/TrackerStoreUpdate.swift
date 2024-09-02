//
//  TrackerStoreUpdate.swift
//  Tracker
//
//  Created by Сергей Кухарев on 02.09.2024.
//

import Foundation

struct TrackerStoreUpdate {
    let insertedSectionIndexes: IndexSet?
    let deletedSectionIndexes: IndexSet?
    let insertedPaths: [IndexPath]
    let deletedPaths: [IndexPath]
}
