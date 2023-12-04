//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Konstantin Penzin on 12.11.2023.
//

import UIKit
import CoreData

protocol TrackerRecordStoreProtocol: AnyObject {
    var delegate: TrackerRecordStoreDelegate? { get set }
    func getRecords() -> [TrackerRecord]
    func check(tracker: TrackerCoreData, for date: Date)
    func uncheck(tracker: TrackerCoreData, for date: Date)
}

protocol TrackerRecordStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerRecordStoreUpdate)
}

struct TrackerRecordStoreUpdate {
    let insertedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

enum TrackerRecordError: Error {
    case failedToConvertTrackers
}

final class TrackerRecordStore: NSObject {
    private var context: NSManagedObjectContext
    
    weak var delegate: TrackerRecordStoreDelegate?
    
    private var insertedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience override init() {
        let context = CoreDataStack.shared.context
        self.init(context: context)
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {

        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerRecordCoreData.date, ascending: true)]
            
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        
        return fetchedResultsController
    }()
    
    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                context.rollback()
            }
        }
    }

}
// MARK: - NSFetchedResultsControllerDelegate
extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(TrackerRecordStoreUpdate(
                insertedIndexes: insertedIndexes!,
                updatedIndexes: updatedIndexes!,
                deletedIndexes: deletedIndexes!
            )
        )

        insertedIndexes = nil
        updatedIndexes = nil
        deletedIndexes = nil
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath.item)
            }
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexes?.insert(indexPath.item)
            }
        case .update:
            if let indexPath = newIndexPath {
                updatedIndexes?.insert(indexPath.item)
            }
        default:
            break
        }
    }
}
// MARK: - TrackerRecordStoreProtocol
extension TrackerRecordStore: TrackerRecordStoreProtocol {
    func getRecords() -> [TrackerRecord] {
        guard
            let objects = fetchedResultsController.fetchedObjects,
            let records = try? objects.map({ try self.convertRecord($0) })
        else {
            return []
        }
        return records
    }
    
    func check(tracker: TrackerCoreData, for date: Date) {
        let entity = TrackerRecordCoreData(context: context)
        entity.date = date
        entity.tracker = tracker
        saveContext()
    }
    
    func uncheck(tracker: TrackerCoreData, for date: Date) {
        guard let entity = fetchedResultsController.fetchedObjects?.first(where: { $0.tracker == tracker && $0.date == date }) else {
            return
        }
        context.delete(entity)
        saveContext()
    }
}
private extension TrackerRecordStore {
    func convertFetchedTracker(_ data: TrackerCoreData) throws -> Tracker {
        guard let id = data.id,
              let name = data.name,
              let color = data.color as? UIColor,
              let emoji = data.emoji,
              let scheduleRaw = data.schedule,
              let schedule = try? JSONDecoder().decode([TrackerSchedule].self, from: scheduleRaw)
        else {
            throw TrackerRecordError.failedToConvertTrackers
        }

        return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule)
    }
    
    func convertRecord(_ data: TrackerRecordCoreData) throws -> TrackerRecord {
        guard let date = data.date,
              let trackerRaw = data.tracker,
              let tracker = try? convertFetchedTracker(trackerRaw)
        else {
            throw TrackerRecordError.failedToConvertTrackers
        }
        return TrackerRecord(tracker: tracker, date: date)
    }
}
