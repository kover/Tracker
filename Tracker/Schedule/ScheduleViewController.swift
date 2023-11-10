//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Konstantin Penzin on 11.11.2023.
//

import UIKit

protocol SelectScheduleDelegate: AnyObject {
    func selectSchedule(schedule: [TrackerSchedule])
}

class ScheduleViewController: UIViewController {

    weak var delegate: SelectScheduleDelegate?
    var schedule: [TrackerSchedule]?
    private var everyday = TrackerSchedule.allCases
    private var selectedDays: [TrackerSchedule] = []

    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setTitle("Готово", for: .normal)
        button.addTarget(self, action: #selector(done), for: .touchUpInside)
        button.backgroundColor = UIColor(named: "Black")
        button.setTitleColor(UIColor(named: "White"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        
        return button
    }()

    private lazy var sheduleTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.rowHeight = 75
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor(named: "White")
        tableView.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Расписание"
        
        view.backgroundColor = UIColor(named: "White")
        
        if let schedule = schedule {
            selectedDays = schedule
        }
        
        sheduleTableView.register(ScheduleTableViewCell.self, forCellReuseIdentifier: ScheduleTableViewCell.scheduleTableViewCellIdentifier)
        
        view.addSubview(doneButton)
        view.addSubview(sheduleTableView)
        
        NSLayoutConstraint.activate([
            sheduleTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sheduleTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sheduleTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            sheduleTableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

//MARK: - UITableViewDataSource
extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TrackerSchedule.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = sheduleTableView.dequeueReusableCell(
            withIdentifier: ScheduleTableViewCell.scheduleTableViewCellIdentifier,
            for: indexPath
        ) as? ScheduleTableViewCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        let schedule = everyday[indexPath.row]
        let isSelected = selectedDays.contains(schedule) ? true : false
        cell.setupCell(schedule: schedule, switchIsActive: isSelected)
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - ScheduleTableViewCellDelegate
extension ScheduleViewController: ScheduleTableViewCellDelegate {
    func addSchedule(dayName: TrackerSchedule) {
        selectedDays.append(dayName)
    }
    
    func removeSchedule(dayName: TrackerSchedule) {
        guard let index = selectedDays.firstIndex(of: dayName) else { return }
        selectedDays.remove(at: index)
    }
}

//MARK: - Private routines
private extension ScheduleViewController {
    @objc func done() {
        guard let delegate = delegate else { return }
        delegate.selectSchedule(schedule: selectedDays)
        dismiss(animated: true)
    }
}
