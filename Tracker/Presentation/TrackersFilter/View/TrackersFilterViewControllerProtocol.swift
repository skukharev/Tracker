//
//  TrackersFilterViewControllerProtocol.swift
//  Tracker
//
//  Created by Сергей Кухарев on 23.09.2024.
//

protocol TrackersFilterViewControllerProtocol: AnyObject {
    /// Ассоциированный презентер вью контроллера
    var presenter: TrackersFilterViewPresenterProtocol { get }
}
