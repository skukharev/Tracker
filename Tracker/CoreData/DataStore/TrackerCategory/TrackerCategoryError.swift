//
//  TrackerCategoryError.swift
//  Tracker
//
//  Created by Сергей Кухарев on 11.09.2024.
//

import Foundation

enum TrackerCategoryError: Error {
    case emptyCategoryName
    case categoryNameAlreadyExists

    var localizedDescription: String {
        switch self {
        case .emptyCategoryName:
            return "Необходимо ввести наименование категории"
        case .categoryNameAlreadyExists:
            return "Категория с заданным именем уже существует!"
        }
    }
}
