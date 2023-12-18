//
//  Filter.swift
//  Tracker
//
//  Created by Konstantin Penzin on 17.12.2023.
//

import Foundation

enum Filter: String, CaseIterable {
    case allTrackers, todayTrackers, completedTrackers, uncompletedTrackers
    
    var localizedString: String {
        switch self {
            case .allTrackers:
                return NSLocalizedString("filter.allTrackers", comment: "Title for all trackers filter")
            case .todayTrackers:
                return NSLocalizedString("filter.todayTrackers", comment: "Title for today's trackers filter")
            case .completedTrackers:
                return NSLocalizedString("filter.completed", comment: "Title for completed trackers filter")
            case .uncompletedTrackers:
                return NSLocalizedString("filter.uncompleted", comment: "Title for uncompleted trackers filter")
        }
    }
}
