//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Konstantin Penzin on 12.11.2023.
//

import Foundation
import CoreData

protocol TrackerRecordStoreProtocol {
    func getRecords() -> [TrackerRecord]
}

final class TrackerRecordStore {
    private var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience init() {
        let context = CoreDataStack.shared.context
        self.init(context: context)
    }
}
