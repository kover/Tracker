//
//  Tracker.swift
//  Tracker
//
//  Created by Konstantin Penzin on 15.09.2023.
//

import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [TrackerSchedule]
    let pinned: Bool
}
