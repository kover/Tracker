//
//  ViewController.swift
//  Tracker
//
//  Created by Konstantin Penzin on 29.08.2023.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Data structures
    private var currentDate: Date?
    
    // MARK: - Stores
    private let trackerCategoryStore: TrackerCategoryStoreProtocol
    private let viewModel: TrackersViewModel
    private let analyticsService: AnalyticsServiceProtocol
    private var selectedFilter: Filter = .allTrackers
    
    init(trackerCategoryStore: TrackerCategoryStoreProtocol, viewModel: TrackersViewModel, analyticsService: AnalyticsServiceProtocol) {
        self.trackerCategoryStore = trackerCategoryStore
        self.viewModel = viewModel
        self.analyticsService = analyticsService
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
    
    private lazy var filterButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setTitle(NSLocalizedString("trackers.filtersButton.title", comment: "Title for the filters button"), for: .normal)
        button.backgroundColor = UIColor(named: "Blue")
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17.0, weight: .regular)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(showFilters), for: .touchUpInside)
        
        return button
    }()
    
    private let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "MainBackground")
        
        configureNavBar()
        configureSearch()
        configureCollection()
        configureFilters()
        
        trackersForSelectedDate()
        bind()
        
        analyticsService.report(event: .open, params: [ AnalyticsParameter.screen.rawValue : AnalyticsScreens.main.rawValue ])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        analyticsService.report(event: .close, params: [ AnalyticsParameter.screen.rawValue : AnalyticsScreens.main.rawValue ])
    }
    
    @objc func createTracker() {
        analyticsService.report(event: .click, params: [ AnalyticsParameter.screen.rawValue : AnalyticsScreens.main.rawValue, AnalyticsParameter.item.rawValue : AnalyticsItems.addTracker.rawValue ])
        let createTrackerViewController = CreateTrackerViewController(trackerCategoryStore: trackerCategoryStore)
        createTrackerViewController.delegate = self
        let navigationController = UINavigationController()
        navigationController.viewControllers = [createTrackerViewController]
        present(navigationController, animated: true)
    }
    
    @objc func filterByDate() {
        trackersForSelectedDate()
    }
    
    @objc
    func showFilters() {
        analyticsService.report(event: .click, params: [ AnalyticsParameter.screen.rawValue : AnalyticsScreens.main.rawValue, AnalyticsParameter.item.rawValue : AnalyticsItems.filter.rawValue ])
        
        let filtersViewController = FiltersViewController()
        filtersViewController.delegate = self
        filtersViewController.selectedFilter = selectedFilter
        
        let navigationController = UINavigationController()
        navigationController.viewControllers = [filtersViewController]
        present(navigationController, animated: true)
    }
}
// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItemsInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let trackerCell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersCollectionViewCell.trackersCollectionViewCellIdentifier, 
                                                                   for: indexPath) as? TrackersCollectionViewCell
        else {
            return TrackersCollectionViewCell()
        }
        
        let item = viewModel.item(at: indexPath.row, in: indexPath.section)
        trackerCell.delegate = self
        trackerCell.setupCell(
            for: item,
            runFor: calculateCompletion(id: item.id),
            done: isTrackerCompletedToday(tracker: item),
            at: datePicker.date
        )
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
        
        cell.setupCell(title: viewModel.titleForSection(indexPath.section))
        
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
        
        let tracker = viewModel.item(at: indexPath.row, in: indexPath.section)
        
        let itemIdentifier = NSString(string: "\(indexPath.section):\(indexPath.row)")
        
        return UIContextMenuConfiguration(identifier: itemIdentifier, actionProvider: { actions in
            return UIMenu(children: [
                UIAction(
                    title: tracker.pinned
                    ? NSLocalizedString("trackerActionUnpin.title", comment: "Title for the unpin action")
                    : NSLocalizedString("trackerActionPin.title", comment: "Title for the pin action")) { [weak self] _ in
                    self?.togglePinForTracker(tracker)
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
            schedule: schedule,
            pinned: false
        )
        
        viewModel.addTracker(newTracker, into: category)
    }
    
    func updateTracker(tracker: Tracker, forCategory category: TrackerCategory) {
        viewModel.updateTracker(tracker, for: category)
    }
}
// MARK: - TrackersCollectionViewCellDelegate
extension TrackersViewController: TrackersCollectionViewCellDelegate {
    func updateTrackerRecord(tracker: Tracker, isCompleted: Bool, cell: TrackersCollectionViewCell) {
        analyticsService.report(event: .click, params: [ AnalyticsParameter.screen.rawValue : AnalyticsScreens.main.rawValue, AnalyticsParameter.item.rawValue : AnalyticsItems.record.rawValue ])
        viewModel.updateRecordFor(tracker: tracker, at: datePicker.date, withCompletion: isCompleted)
    }
}

// MARK: - UISearchResultsUpdating
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        trackersByPredicate(searchController.searchBar.text ?? "")
    }
}

// MARK: - FiltersViewControllerDelegate
extension TrackersViewController: FiltersViewControllerDelegate {
    func selectFilter(_ filter: Filter) {
        selectedFilter = filter
        viewModel.quickFilter = filter
        switch filter {
        case .allTrackers:
            trackersForSelectedDate()
        case .todayTrackers:
            datePicker.date = Date()
            trackersForSelectedDate()
        case .completedTrackers, .uncompletedTrackers:
            return
        }
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
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = UIColor(named: "MainBackground")
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
    
    private func configureFilters() {
        view.addSubview(filterButton)
        
        NSLayoutConstraint.activate([
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -17),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114)
        ])
    }
    
    func togglePlaceholder(search: Bool = false) {
        let isSearching = viewModel.searchPredicate != "" || viewModel.quickFilter != nil && viewModel.quickFilter != .allTrackers
        let placeholderText = isSearching ? NSLocalizedString("trackers.placeholderNotFound", comment: "Text for the placeholder if nothing was found") : NSLocalizedString("trackers.placeholderViewText", comment: "Text for the empty trackers list")
        let placeholderImage = isSearching ? UIImage(named: "EmptySearch") : UIImage(named: "TrackersPlaceholder")
        placeholderView.updateText(placeholderText)
        placeholderView.updateImage(placeholderImage)
        if viewModel.numberOfSections == 0 {
            collectionView.backgroundView?.isHidden = false
        } else {
            collectionView.backgroundView?.isHidden = true
        }
        
        if !isSearching && viewModel.numberOfSections == 0 {
            filterButton.isHidden = true
        } else {
            filterButton.isHidden = false
        }
    }
    
    func trackersForSelectedDate() {
        currentDate = datePicker.date
        
        guard let currentDate = currentDate else {
            return
        }
        
        viewModel.selectedDate = currentDate
        togglePlaceholder()
    }
    
    func trackersByPredicate(_ predicate: String) {
        viewModel.searchPredicate = predicate.lowercased()
        togglePlaceholder()
    }
    
    func calculateCompletion(id: UUID) -> Int {
        return viewModel.completedTrackers.reduce(0) { partialResult, record in
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
        return viewModel.completedTrackers.contains { $0.date.compare(date) == .orderedSame && $0.tracker.id == tracker.id }
    }
    
    func togglePinForTracker(_ tracker: Tracker) {
        guard let category = viewModel.categoryFor(tracker: tracker) else {
            return
        }
        let newTracker = Tracker(
            id: tracker.id,
            name: tracker.name,
            color: tracker.color,
            emoji: tracker.emoji,
            schedule: tracker.schedule,
            pinned: !tracker.pinned
        )
        
        viewModel.updateTracker(newTracker, for: category)
    }
    
    func editTracker(_ tracker: Tracker) {
        analyticsService.report(event: .click, params: [ AnalyticsParameter.screen.rawValue : AnalyticsScreens.main.rawValue, AnalyticsParameter.item.rawValue : AnalyticsItems.edit.rawValue ])
        
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
        analyticsService.report(event: .click, params: [ AnalyticsParameter.screen.rawValue : AnalyticsScreens.main.rawValue, AnalyticsParameter.item.rawValue : AnalyticsItems.remove.rawValue ])
        
        let alert = UIAlertController(
            title: NSLocalizedString("trackers.removalConfirmation", comment: "Tracker removal confirmation message"),
            message: nil,
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("trackers.removalConfirmation.confirm", comment: "Tracker removal confirm button title"),
                                      style: .destructive) { [weak self] _ in
            self?.viewModel.removeTracker(tracker)
        })
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("trackers.removalConfirmation.cancel", comment: "Tracker removal cancel button title"),
            style: .cancel
        ))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func bind() {
        viewModel.$visibleCategories.bind { [weak self] _ in
            self?.collectionView.reloadData()
            self?.togglePlaceholder()
        }
    }
}
