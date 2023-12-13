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
                return NSLocalizedString("scheduleMonday.full", comment: "Full name for Monday")
            case .Tuesday:
                return NSLocalizedString("scheduleTuesday.full", comment: "Full name for Tuesday")
            case .Wednesday:
                return NSLocalizedString("scheduleWednesday.full", comment: "Full name for Wednesday")
            case .Thursday:
                return NSLocalizedString("scheduleThursday.full", comment: "Full name for Thursday")
            case .Friday:
                return NSLocalizedString("scheduleFriday.full", comment: "Full name for Friday")
            case .Saturday:
                return NSLocalizedString("scheduleSaturday.full", comment: "Full name for Saturday")
            case .Sunday:
                return NSLocalizedString("scheduleSunday.full", comment: "Full name for Sunday")
        }
       
    }
    var shortDayName: String {
        switch self {
            case .Monday:
                return NSLocalizedString("scheduleMonday.short", comment: "Short name for Monday")
            case .Tuesday:
                return NSLocalizedString("scheduleTuesday.short", comment: "Short name for Tuesday")
            case .Wednesday:
                return NSLocalizedString("scheduleWednesday.short", comment: "Short name for Wednesday")
            case .Thursday:
                return NSLocalizedString("scheduleThursday.short", comment: "Short name for Thursday")
            case .Friday:
                return NSLocalizedString("scheduleFriday.short", comment: "Short name for Friday")
            case .Saturday:
                return NSLocalizedString("scheduleSaturday.short", comment: "Short name for Saturday")
            case .Sunday:
                return NSLocalizedString("scheduleSunday.short", comment: "Short name for Sunday")
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
