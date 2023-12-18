//
//  AnalyticsItems.swift
//  Tracker
//
//  Created by Konstantin Penzin on 16.12.2023.
//

import Foundation

enum AnalyticsItems: String, CaseIterable {
    case addTracker = "add_track"
    case record = "track"
    case filter = "filter"
    case edit = "edit"
    case remove = "delete"
}
