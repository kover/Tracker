//
//  ScheduleTableViewCell.swift
//  Tracker
//
//  Created by Konstantin Penzin on 11.11.2023.
//

import UIKit

//MARK: - Protocols
protocol ScheduleTableViewCellDelegate: AnyObject {
    func addSchedule(dayName: TrackerSchedule)
    func removeSchedule(dayName: TrackerSchedule)
}

class ScheduleTableViewCell: UITableViewCell {
    
    static let scheduleTableViewCellIdentifier = "scheduleTableViewCell"

    weak var delegate: ScheduleTableViewCellDelegate?
    
    private var schedule: TrackerSchedule?
    
    private lazy var scheduleNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(named: "Black")
        
        return label
    }()
    
    private lazy var selectionToggleSwitch: UISwitch = {
        let switcherView = UISwitch(frame: .zero)
        switcherView.translatesAutoresizingMaskIntoConstraints = false
        
        switcherView.setOn(false, animated: true)
        switcherView.onTintColor = UIColor(named: "Blue")
        switcherView.addTarget(self, action: #selector(toggleSwitch), for: .valueChanged)
        
        return switcherView
    }()
    
    //MARK: - Cell configuration
    func setupCell(schedule: TrackerSchedule, switchIsActive: Bool) {
        scheduleNameLabel.text = schedule.dayName
        selectionToggleSwitch.isOn = switchIsActive
        self.schedule = schedule
        
        contentView.backgroundColor = UIColor(named: "Background")
        
        contentView.addSubview(scheduleNameLabel)
        contentView.addSubview(selectionToggleSwitch)
        
        NSLayoutConstraint.activate([
            scheduleNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            scheduleNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            scheduleNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: selectionToggleSwitch.leadingAnchor),
            
            selectionToggleSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            selectionToggleSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}

//MARK: - Private routines
private extension ScheduleTableViewCell {
    
    @objc func toggleSwitch(_ sender : UISwitch) {
        guard let schedule = schedule,
              let delegate = delegate else {
            return
        }
        
        if sender.isOn {
            delegate.addSchedule(dayName: schedule)
        } else {
            delegate.removeSchedule(dayName: schedule)
        }
    }
}

