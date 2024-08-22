//
//  NewTrackerEmojiCellDelegate.swift
//  Tracker
//
//  Created by Сергей Кухарев on 21.08.2024.
//

import Foundation

protocol NewTrackerEmojiCellDelegate: AnyObject {
    /// Обработчик события выделения заданного эмоджи
    /// - Parameter newEmoji: выделенный эмоджи трекера
    func emojiDidChange(_ newEmoji: String)
}
