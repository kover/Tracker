//
//  TrackerSchedule.swift
//  Tracker
//
//  Created by Konstantin Penzin on 15.09.2023.
//

import Foundation

enum TrackerSchedule: CaseIterable, Codable {
    case Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday
    
    var dayName: String {
        switch self {
            case .Monday:
                return "Понедельник"
            case .Tuesday:
                return "Вторник"
            case .Wednesday:
                return "Среда"
            case .Thursday:
                return "Четверг"
            case .Friday:
                return "Пятница"
            case .Saturday:
                return "Суббота"
            case .Sunday:
                return "Воскресенье"
        }
       
    }
    var shortDayName: String {
        switch self {
            case .Monday:
                return "Пн"
            case .Tuesday:
                return "Вт"
            case .Wednesday:
                return "Ср"
            case .Thursday:
                return "Чт"
            case .Friday:
                return "Пт"
            case .Saturday:
                return "Сб"
            case .Sunday:
                return "Вс"
        }
    }
    var numberOfDay: Int {
        switch self {
            case .Monday:
                return 2
            case .Tuesday:
                return 3
            case .Wednesday:
                return 4
            case .Thursday:
                return 5
            case .Friday:
                return 6
            case .Saturday:
                return 7
            case .Sunday:
                return 1
        }
    }
}
