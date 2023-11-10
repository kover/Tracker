//
//  ViewController.swift
//  Tracker
//
//  Created by Konstantin Penzin on 29.08.2023.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    private let createTrackerSegueIdentifier = "CreateTrackerSegue"
    
    private var searchTextField: UISearchTextField = {
        let searchTextField = UISearchTextField(frame: .zero)
        searchTextField.placeholder = "Поиск"
        
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        
        return searchTextField
    }()
    
    private var collectionView: UICollectionView = {
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
        let placeholder = TrackersPlaceholderView(placeholderText: "Что будем отслеживать?", frame: .zero)
        
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        
        return placeholder
    }()
    
    private let datePicker = UIDatePicker()
    
    // MARK: - Data structures
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var visibleCategories: [TrackerCategory] = []
    private var currentDate: Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        configureNavBar()
        configureSearch()
        configureCollection()
        showPlaceholder()
    }
    
    @objc func createTracker() {
        let createTrackerViewController = CreateTrackerViewController()
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
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let trackerCell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersCollectionViewCell.trackersCollectionViewCellIdentifier, for: indexPath) as? TrackersCollectionViewCell else {
            return TrackersCollectionViewCell()
        }
        
        let item = visibleCategories[indexPath.section].trackers[indexPath.row]
        
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
        
        cell.setupCell(title: visibleCategories[indexPath.section].title)
        
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
// MARK: - TrackersViewControlelrDelegate implementation
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
        
        if categories.contains(where: { $0.title == category.title }) {
            categories = categories.map { $0.title == category.title ? TrackerCategory(title: $0.title, trackers: $0.trackers + [newTracker]) : $0 }
        } else {
            categories = categories + [TrackerCategory(title: category.title, trackers: [newTracker])]
        }
        
        trackersForSelectedDate()
    }
}
extension TrackersViewController: TrackersCollectionViewCellDelegate {
    func updateTrackerRecord(tracker: Tracker, isCompleted: Bool, cell: TrackersCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        if isCompleted {
            completedTrackers = completedTrackers + [TrackerRecord(tracker: tracker, date: Date())]
        } else {
            completedTrackers = completedTrackers.filter { $0.tracker.id != tracker.id }
        }
        
        collectionView.reloadItems(at: [indexPath])
    }
}
private extension TrackersViewController {
    private func showPlaceholder() {
        view.addSubview(placeholderView)
        
        NSLayoutConstraint.activate([
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

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
        
        let barItem = UIBarButtonItem(customView: datePicker)
        
        navigationItem.setRightBarButton(barItem, animated: true)
    }
    
    private func configureSearch() {
        view.addSubview(searchTextField)
        
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func configureCollection() {
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 24),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func togglePlaceholder(search: Bool = false) {        
        if visibleCategories.count == 0 {
            placeholderView.isHidden = false
        } else {
            placeholderView.isHidden = true
        }
    }
    
    func trackersForSelectedDate() {
        currentDate = datePicker.date
        
        guard let currentDate = currentDate else {
            return
        }
        
        let selectedDay = Calendar.current.component(.weekday, from: currentDate)
        
        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let datePickerFilter = tracker.schedule.contains {
                    $0.numberOfDay == selectedDay
                } == true
                
                return datePickerFilter
            }
            
            if trackers.isEmpty {
                return nil
            }
            
            return TrackerCategory(title: category.title, trackers: trackers)
        }
        
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
        let calendar = Calendar.current
        return completedTrackers.contains { calendar.compare($0.date, to: datePicker.date, toGranularity: .day) == .orderedSame && $0.tracker.id == tracker.id }
    }

}
