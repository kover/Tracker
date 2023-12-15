//
//  CategoryStore.swift
//  Tracker
//
//  Created by Konstantin Penzin on 11.11.2023.
//

import CoreData
import UIKit

protocol TrackerCategoryStoreProtocol: AnyObject {
    var delegate: TrackerCategoryStoreDelegate? { get set }
    var changeDelegate: TrackerCategoryChangeDelegate? { get set }
    var numberOfSections: Int { get }
    func getCategories() -> [TrackerCategory]
    func addCategory(_ category: TrackerCategory)
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(at: IndexPath) -> TrackerCategory?
    func entityFor(category: TrackerCategory) -> TrackerCategoryCoreData?
    func categoryForTracker(_ tracker: Tracker) -> TrackerCategory?
}

struct TrackerCategoryStoreUpdate {
    let insertedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerCategoryStoreUpdate)
}

protocol TrackerCategoryChangeDelegate: AnyObject {
    func didChange(_ change: TrackerCategoryStoreUpdate)
}

enum TrackerCategoryError: Error {
    case failedToConvertCategory
}

final class TrackerCategoryStore: NSObject {
    private var context: NSManagedObjectContext
    
    weak var delegate: TrackerCategoryStoreDelegate?
    weak var changeDelegate: TrackerCategoryChangeDelegate?
    private var insertedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
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
                  let schedule = $0.schedule as? [TrackerSchedule]
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
    
    func entityFor(category: TrackerCategory) -> TrackerCategoryCoreData? {
        fetchedResultsController.fetchedObjects?.first(where: { $0.title == category.title })
    }
    
    func categoryForTracker(_ tracker: Tracker) -> TrackerCategory? {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "ANY trackers.id == %@", tracker.id.uuidString)
        
        guard let categories = try? context.fetch(request),
              let category = categories.first else {
            return nil
        }
    
        return try? convertFetchedCategory(category)
    }
}
// MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(TrackerCategoryStoreUpdate(
                insertedIndexes: insertedIndexes ?? [],
                updatedIndexes: updatedIndexes ?? [],
                deletedIndexes: deletedIndexes ?? []
            )
        )
        changeDelegate?.didChange(TrackerCategoryStoreUpdate(
            insertedIndexes: insertedIndexes ?? [],
            updatedIndexes: updatedIndexes ?? [],
            deletedIndexes: deletedIndexes ?? []
        ))
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
