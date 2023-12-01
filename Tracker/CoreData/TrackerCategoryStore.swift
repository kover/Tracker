//
//  CategoryStore.swift
//  Tracker
//
//  Created by Konstantin Penzin on 11.11.2023.
//

import CoreData
import UIKit

protocol TrackerCategoryStoreProtocol: AnyObject {
    func getCategories() -> [TrackerCategory]
    func addCategory(_ category: TrackerCategory)
    var delegate: TrackerCategoryStoreDelegate? { get set }
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(at: IndexPath) -> TrackerCategory?
    func addTracker(_ tracker: TrackerCoreData, to category: TrackerCategory)
}

struct TrackerCategoryStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerCategoryStoreUpdate)
}

enum TrackerCategoryError: Error {
    case failedToConvertCategory
}

final class TrackerCategoryStore: NSObject {
    private var context: NSManagedObjectContext
    
    weak var delegate: TrackerCategoryStoreDelegate?
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    init(context: NSManagedObjectContext, delegate: TrackerCategoryStoreDelegate?) {
        self.context = context
        self.delegate = delegate
    }
    
    convenience override init() {
        let context = CoreDataStack.shared.context
        self.init(context: context)
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {

        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCategoryCoreData.title, ascending: true)]
            
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        
//        if let objects = fetchedResultsController.fetchedObjects, objects.isEmpty {
//            addCategory(TrackerCategory(title: "Default", trackers: []))
//        }
        
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
private extension TrackerCategoryStore {
    func convertFetchedTrackers(_ data: [TrackerCoreData]) -> [Tracker] {
        var trackers: [Tracker] = []
        
        data.forEach {
            guard let id = $0.id,
                  let name = $0.name,
                  let color = $0.color as? UIColor,
                  let emoji = $0.emoji,
                  let scheduleRaw = $0.schedule,
                  let schedule = try? JSONDecoder().decode([TrackerSchedule].self, from: scheduleRaw)
            else {
                return
            }
            
            trackers.append(Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule))
        }
        return trackers
    }
    
    func convertFetchedCategory(_ data: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let title = data.title,
              let trackers = data.trackers?.allObjects as? [TrackerCoreData] else {
            throw TrackerCategoryError.failedToConvertCategory
        }
        return TrackerCategory(title: title, trackers: convertFetchedTrackers(trackers))
    }
}
// MARK: - TrackerCategoryStoreProtocol
extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
    func getCategories() -> [TrackerCategory] {
        guard
            let objects = fetchedResultsController.fetchedObjects,
            let categories = try? objects.map({ try self.convertFetchedCategory($0) })
        else {
            return []
        }
        
        return categories
    }
    
    func addCategory(_ category: TrackerCategory) {
        let entity = TrackerCategoryCoreData(context: context)
        entity.title = category.title
        saveContext()
    }
    
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at: IndexPath) -> TrackerCategory? {
        try? convertFetchedCategory(fetchedResultsController.object(at: at))
    }
    
    func addTracker(_ tracker: TrackerCoreData, to category: TrackerCategory) {
        guard let entity = fetchedResultsController.fetchedObjects?.first(where: { $0.title == category.title }) else {
            return
        }
        entity.addToTrackers(tracker)
        saveContext()
    }
}
// MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(TrackerCategoryStoreUpdate(
                insertedIndexes: insertedIndexes!,
                deletedIndexes: deletedIndexes!
            )
        )
        insertedIndexes = nil
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
        default:
            break
        }
    }
}
