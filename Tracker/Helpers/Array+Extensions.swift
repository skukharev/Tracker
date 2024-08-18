//
//  Array+Extensions.swift
//
//  Created by Сергей Кухарев on 02.04.2024.
//

import Foundation

/*
    Расширение для безопасного обращения к элементам массивов по индексу
 
    Использование:
        let arr: [String] = ["1", "2"]
        print(arr[safe: 3]) //Вернёт nil, а не ошибку времени исполнения
*/

extension Array {
    subscript(safe index: Index) -> Element? {
        indices ~= index ? self[index] : nil
    }
}
