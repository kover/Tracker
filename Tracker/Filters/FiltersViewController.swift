//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Konstantin Penzin on 17.12.2023.
//

import UIKit

protocol FiltersViewControllerDelegate: AnyObject {
    func selectFilter(_ filter: Filter)
}

final class FiltersViewController: UIViewController {

    weak var delegate: FiltersViewControllerDelegate?
    var selectedFilter: Filter?
    
    //MARK: - Layout items
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.register(FiltersTableViewCell.self, forCellReuseIdentifier: FiltersTableViewCell.filtersTableViewCellIdentifier)
        tableView.backgroundColor = UIColor(named: "MainBackground")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelection = false
        tableView.rowHeight = 75
        
        return tableView
    }()
    
    //MARK: - Private variables
    private let allFilters = Filter.allCases
    
    //MARK: - Lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("filters.title", comment: "The title for the filters view")
        view.backgroundColor = UIColor(named: "MainBackground")
        
        setupSubviews()
        setupLayout()
    }
}

//MARK: - UITableViewDataSource
extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        allFilters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FiltersTableViewCell.filtersTableViewCellIdentifier,
            for: indexPath
        ) as? FiltersTableViewCell else {
            return UITableViewCell()
        }
        
        let filter = allFilters[indexPath.row]
        
        cell.setupCell(name: filter.localizedString, checkMark: selectedFilter == filter)
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let _ = tableView.cellForRow(at: indexPath) as? FiltersTableViewCell {
            delegate?.selectFilter(allFilters[indexPath.row])
            dismiss(animated: true) }
    }
}

//MARK: - Privtae routines
private extension FiltersViewController {
    func setupSubviews() {
        view.addSubview(tableView)
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
