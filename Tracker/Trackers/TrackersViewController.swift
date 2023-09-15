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
        
        return collectionView
    }()
    
    // MARK: - Data structures
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var visibleCategories: [TrackerCategory] = [TrackerCategory(title: "Hello", trackers: [Tracker(id: 1, name: "Test tracker with very very very very very very long name", color: .red, emoji: "😀", schedule: [.Friday]), Tracker(id: 2, name: "Test tracker", color: .red, emoji: "🍏", schedule: [.Friday])])]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        configureNavBar()
        configureSearch()
        configureCollection()
        showPlaceholder()
    }

    private func configureNavBar() {
        let addHabbitButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(createTracker)
        )
        addHabbitButton.tintColor = UIColor(named: "Black")
        
        navigationItem.setLeftBarButton(addHabbitButton, animated: true)
        
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        
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
            collectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func showPlaceholder() {
        let placeholder = TrackersPlaceholderView(placeholderText: "Что будем отслеживать?", frame: .zero)
        
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(placeholder)
        
        NSLayoutConstraint.activate([
            placeholder.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholder.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc func createTracker() {
        let createTrackerViewController = CreateTrackerViewController()
        let navigationController = UINavigationController()
        navigationController.viewControllers = [createTrackerViewController]
        present(navigationController, animated: true)
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
        
        trackerCell.configureCell(emoji: item.emoji, title: item.name, counter: 1, completed: false, color: item.color)
        return trackerCell
    }
}
// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: (collectionView.bounds.width - 32 - 9) / 2, height: 192)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
}

