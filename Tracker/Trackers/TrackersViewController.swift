//
//  ViewController.swift
//  Tracker
//
//  Created by Konstantin Penzin on 29.08.2023.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Data structures
    private var completedTrackers: [TrackerRecord] = []
    private var currentDate: Date?
    
    // MARK: - Stores
    private let trackerStore: TrackerStoreProtocol
    private let trackerCategoryStore: TrackerCategoryStoreProtocol
    private let trackerRecordStore: TrackerRecordStoreProtocol
    
    init(trackerStore: TrackerStoreProtocol, trackerCategoryStore: TrackerCategoryStoreProtocol, trackerRecordStore: TrackerRecordStoreProtocol) {
        self.trackerStore = trackerStore
        self.trackerCategoryStore = trackerCategoryStore
        self.trackerRecordStore = trackerRecordStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Layout items
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(TrackersCollectionViewCell.self, forCellWithReuseIdentifier: TrackersCollectionViewCell.trackersCollectionViewCellIdentifier)
        
        collectionView.register(
            TrackersCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackersCollectionReusableView.trackerCollectionReusableViewIdentifier
        )
        
        return collectionView
    }()
    
    private var placeholderView: TrackersPlaceholderView = {
        let placeholder = TrackersPlaceholderView(placeholderText: NSLocalizedString("trackers.placeholderViewText", comment: "Text for the empty trackers list"), frame: .zero)
        
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        
        return placeholder
    }()
    
    private let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trackerStore.delegate = self
        
        configureNavBar()
        configureSearch()
        configureCollection()
        
        completedTrackers = trackerRecordStore.getRecords()
        trackersForSelectedDate()
    }
    
    @objc func createTracker() {
        let createTrackerViewController = CreateTrackerViewController(trackerCategoryStore: trackerCategoryStore)
        createTrackerViewController.delegate = self
        let navigationController = UINavigationController()
        navigationController.viewControllers = [createTrackerViewController]
        present(navigationController, animated: true)
    }
    
    @objc func filterByDate() {
        trackersForSelectedDate()
    }
}
// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        trackerStore.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        trackerStore.numberOfRowsInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let trackerCell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersCollectionViewCell.trackersCollectionViewCellIdentifier, 
                                                                   for: indexPath) as? TrackersCollectionViewCell,
              let item = trackerStore.object(at: indexPath)
        else {
            return TrackersCollectionViewCell()
        }
        
        trackerCell.delegate = self
        trackerCell.setupCell(for: item, runFor: calculateCompletion(id: item.id), done: isTrackerCompletedToday(tracker: item), at: datePicker.date)
        return trackerCell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let cell = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackersCollectionReusableView.trackerCollectionReusableViewIdentifier,
            for: indexPath
        ) as? TrackersCollectionReusableView else {
            return UICollectionReusableView()
        }
        
        cell.setupCell(title: trackerStore.titleForSection(at: indexPath))
        
        return cell
    }
}
// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: (collectionView.bounds.width - 32 - 9) / 2, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = collectionView.frame.width
        return CGSize(width: width, height: 18)
    }
    
}
// MARK: - UICollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        
        guard let tracker = trackerStore.object(at: indexPath)
        else {
            return nil
        }
        
        let itemIdentifier = NSString(string: "\(indexPath.section):\(indexPath.row)")
        
        return UIContextMenuConfiguration(identifier: itemIdentifier, actionProvider: { actions in
            return UIMenu(children: [
                UIAction(title: NSLocalizedString("trackerActionPin.title", comment: "Title for the pin action")) { [weak self] _ in
                    self?.pinTracker(tracker)
                },
                UIAction(title: NSLocalizedString("trackerActionEdit.title", comment: "Title for edit action")) { [weak self] _ in
                    self?.editTracker(tracker)
                },
                UIAction(title: NSLocalizedString("trackerActionRemove.title", comment: "Title for remove action"), attributes: .destructive) { [weak self] _ in
                    self?.removeTracker(tracker)
                }
            ])
        })
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {

        guard let identifier = configuration.identifier as? String else {
            return nil
        }
        let components = identifier.components(separatedBy: ":")

        guard let first = components.first,
              let last = components.last,
              let section = Int(first),
              let row = Int(last) else {
            return nil
        }
        let indexPath = IndexPath(row: row, section: section)

        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackersCollectionViewCell,
              let preview = cell.preview
        else {
            return nil
        }

        return UITargetedPreview(view: preview)
    }
}
// MARK: - CreateHabbitViewControllerDelegate
extension TrackersViewController: CreateHabbitViewControllerDelegate {
    func addTracker(
        category: TrackerCategory,
        schedule: [TrackerSchedule],
        name: String,
        emoji: String,
        color: UIColor
    ) {
        let newTracker = Tracker(
            id: UUID(),
            name: name,
            color: color,
            emoji: emoji,
            schedule: schedule
        )
        
        guard let categoryEntity = trackerCategoryStore.entityFor(category: category) else {
            return
        }
        trackerStore.addTracker(newTracker, for: categoryEntity)
    }
    
    func updateTracker(tracker: Tracker, forCategory category: TrackerCategory) {
        guard let categoryEntity = trackerCategoryStore.entityFor(category: category) else {
            return
        }
        trackerStore.updateTracker(tracker, for: categoryEntity)
    }
}
// MARK: - TrackersCollectionViewCellDelegate
extension TrackersViewController: TrackersCollectionViewCellDelegate {
    func updateTrackerRecord(tracker: Tracker, isCompleted: Bool, cell: TrackersCollectionViewCell) {
        guard
            let indexPath = collectionView.indexPath(for: cell),
            let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: datePicker.date)),
            let trackerEntity = trackerStore.getEntityFor(tracker: tracker)
        else {
            return
        }
        if isCompleted {
            trackerRecordStore.check(tracker: trackerEntity, for: date)
        } else {
            trackerRecordStore.uncheck(tracker: trackerEntity, for: date)
        }
        
        completedTrackers = trackerRecordStore.getRecords()
        collectionView.reloadItems(at: [indexPath])
    }
}
// MARK: - TrackerStoreDelegate
extension TrackersViewController: TrackerStoreDelegate {
    func didUpdate(_ update: TrackerStoreUpdate) {
        collectionView.reloadData()
        togglePlaceholder()
    }
}
// MARK: - UISearchResultsUpdating
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        trackersByPredicate(searchController.searchBar.text ?? "")
    }
}
// MARK: - Private routines & layout
private extension TrackersViewController {

    private func configureNavBar() {
        let addHabbitButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(createTracker)
        )
        addHabbitButton.tintColor = UIColor(named: "Black")
        
        navigationItem.setLeftBarButton(addHabbitButton, animated: true)
        
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(filterByDate), for: .valueChanged)
        // Start from Monday
        datePicker.calendar.firstWeekday = 2
        
        let barItem = UIBarButtonItem(customView: datePicker)
        
        navigationItem.setRightBarButton(barItem, animated: true)
    }
    
    private func configureSearch() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("trackers.searchPlaceholder", comment: "Text for the placeholder on the trackers page")
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
    }
    
    private func configureCollection() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundView = placeholderView
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            placeholderView.widthAnchor.constraint(equalTo: collectionView.widthAnchor),
            placeholderView.heightAnchor.constraint(equalTo: collectionView.heightAnchor)
        ])
    }
    
    func togglePlaceholder(search: Bool = false) {
        let isSearching = trackerStore.searchPredicate != "" && trackerStore.searchPredicate != nil
        let placeholderText = isSearching ? NSLocalizedString("trackers.placeholderNotFound", comment: "Text for the placeholder if nothing was found") : NSLocalizedString("trackers.placeholderViewText", comment: "Text for the empty trackers list")
        let placeholderImage = isSearching ? UIImage(named: "EmptySearch") : UIImage(named: "TrackersPlaceholder")
        placeholderView.updateText(placeholderText)
        placeholderView.updateImage(placeholderImage)
        if trackerStore.numberOfSections == 0 {
            collectionView.backgroundView?.isHidden = false
        } else {
            collectionView.backgroundView?.isHidden = true
        }
    }
    
    func trackersForSelectedDate() {
        currentDate = datePicker.date
        
        guard let currentDate = currentDate else {
            return
        }
        
        trackerStore.selectedDate = currentDate
        
        collectionView.reloadData()
        togglePlaceholder()
    }
    
    func trackersByPredicate(_ predicate: String) {
        trackerStore.searchPredicate = predicate.lowercased()
        collectionView.reloadData()
        togglePlaceholder()
    }
    
    func calculateCompletion(id: UUID) -> Int {
        return completedTrackers.reduce(0) { partialResult, record in
            if record.tracker.id == id {
                return partialResult + 1
            }
            return partialResult
        }
    }
    
    func isTrackerCompletedToday(tracker: Tracker) -> Bool {
        guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: datePicker.date)) else {
            return false
        }
        return completedTrackers.contains { $0.date.compare(date) == .orderedSame && $0.tracker.id == tracker.id }
    }
    
    func pinTracker(_ tracker: Tracker) {
        
    }
    
    func editTracker(_ tracker: Tracker) {
        let createHabbitViewController = CreateHabbitViewController(trackerCategoryStore: trackerCategoryStore)
        createHabbitViewController.tracker = tracker
        createHabbitViewController.title = NSLocalizedString("editHabbitView.title", comment: "The title for the edit a habbit view")
        createHabbitViewController.completedDays = calculateCompletion(id: tracker.id)
        createHabbitViewController.delegate = self
        createHabbitViewController.cells = [
            0: ["textField"],
            1: ["category","shedule"],
            2: ["emoji"],
            3: ["colors"]
        ]

        
        let navigationController = UINavigationController()
        navigationController.viewControllers = [createHabbitViewController]

        present(navigationController, animated: true)
    }
    
    func removeTracker(_ tracker: Tracker) {
        let alert = UIAlertController(
            title: NSLocalizedString("trackers.removalConfirmation", comment: "Tracker removal confirmation message"),
            message: nil,
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("trackers.removalConfirmation.confirm", comment: "Tracker removal confirm button title"),
                                      style: .destructive) { [weak self] _ in
            self?.trackerStore.removeTracker(tracker)
        })
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("trackers.removalConfirmation.cancel", comment: "Tracker removal cancel button title"),
            style: .cancel
        ))
        
        self.present(alert, animated: true, completion: nil)
    }
}
