//
//  AnalyticsItems.swift
//  Tracker
//
//  Created by Konstantin Penzin on 16.12.2023.
//

import Foundation

enum AnalyticsItems: String, CaseIterable {
    case AddTracker = "add_track"
    case Record = "track"
    case Filter = "filter"
    case Edit = "edit"
    case Remove = "delete"
}
