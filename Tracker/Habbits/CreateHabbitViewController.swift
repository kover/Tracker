//
//  CreateHabbitViewController.swift
//  Tracker
//
//  Created by Konstantin Penzin on 07.11.2023.
//

import UIKit

protocol CreateHabbitViewControllerDelegate: AnyObject {
    func addTracker(
        category: TrackerCategory,
        schedule: [TrackerSchedule],
        name: String,
        emoji: String,
        color: UIColor
    )
}

final class CreateHabbitViewController: UIViewController {
    
    private var category: TrackerCategory?
    private var schedule: [TrackerSchedule]?
    private var name: String?
    private var emoji: String?
    private var color: UIColor?
    
    weak var delegate: CreateHabbitViewControllerDelegate?
    var cells: Dictionary<Int, [String]>?
    
    // MARK: - Layout items
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 75
        tableView.backgroundColor = UIColor(named: "White")
        tableView.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        
        return tableView
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(UIColor(named: "White"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(named: "Gray")
        button.isEnabled = false
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(create), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(UIColor(named: "Red"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor.clear
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(named: "Red")?.cgColor
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        fillSheduleIfRequired()

    }

    @objc func create() {
        if
            let category = category,
            let schedule = schedule,
            let name = name,
            let color = color,
            let emoji = emoji,
            let delegate = delegate {
            
            delegate.addTracker(category: category, schedule: schedule, name: name, emoji: emoji, color: color)
            
            guard let window = UIApplication.shared.windows.first,
                  let rootViewController = window.rootViewController else {
                assertionFailure("Invalid Configuration")
                return
            }
            rootViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func cancel() {
        dismiss(animated: true)
    }

}
//MARK: - UITableViewDelegate
extension CreateHabbitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectCell(indexPath: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
// MARK: - UITableViewDataSource
extension CreateHabbitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let cells = cells,
              let section = cells[section] else {
            return 0
        }
        return section.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let cells = cells else {
            return 0
        }
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: TextFieldTableViewCell.textFieldTableViewCellIdentifier,
                for: indexPath
            ) as? TextFieldTableViewCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.setupCell()
            
            return cell
        } else if indexPath.section == 1 {
            var text = ""
            var description: String? = nil
            
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: HabbitSetupTableViewCell.habbitSetupTableViewCellIdentifier,
                for: indexPath
            ) as? HabbitSetupTableViewCell else {
                return UITableViewCell()
            }

            if indexPath.row == 0 {
                text = "Категория"
                description = category?.title
            } else {
                text = "Расписание"
                description = scheduleToString()
            }
            
            cell.setupCell(text: text, description: description)
            
            return cell
            
        } else if indexPath.section == 2 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: EmojiTableViewCell.emojiTableViewCellIdentifier,
                for: indexPath
            ) as? EmojiTableViewCell else {
                return UITableViewCell()
            }
                
            cell.delegate = self
            cell.setupCell()
            
            return cell
        } else {
            
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ColorsTableViewCell.colorsTableViewCellIdentifier,
                for: indexPath
            ) as? ColorsTableViewCell else {
                return UITableViewCell()
            }
            
            cell.delegate = self
            cell.setupCell()
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 || indexPath.section == 1 {
            return 75
        } else {
            return 198
        }
    }
}
//MARK: - SelectCategoryDelegate
extension CreateHabbitViewController: SelectCategoryDelegate {
    func updateCategory(category: TrackerCategory) {
        self.category = category
        updateCreateButton()
        tableView.reloadData()
    }
}

//MARK: - SelectScheduleDelegate
extension CreateHabbitViewController: SelectScheduleDelegate {
    func selectSchedule(schedule: [TrackerSchedule]) {
        self.schedule = schedule
        updateCreateButton()
        tableView.reloadData()
    }
}

//MARK: - TextFieldTableViewCellDelegate
extension CreateHabbitViewController: TextFieldTableViewCellDelegate {
    func setHabbitName(with name: String?) {
        if name == "" {
            self.name = nil
        } else {
            self.name = name
        }
        updateCreateButton()
    }
}

//MARK: - EmojiTableViewCellDelegate
extension CreateHabbitViewController: EmojiTableViewCellDelegate{
    func updateEmoji(with emoji: String?) {
        self.emoji = emoji
        updateCreateButton()
        tableView.reloadData()
    }
}

//MARK: - ColorsTableViewCellDelegate
extension CreateHabbitViewController: ColorsTableViewCellDelegate {
    func updateColor(with color: UIColor?) {
        self.color = color
        updateCreateButton()
        tableView.reloadData()
    }
}

//MARK: - Private declarations & layout
private extension CreateHabbitViewController {
    func setupSubviews() {
        view.addSubview(tableView)
        view.addSubview(cancelButton)
        view.addSubview(createButton)
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32),
            cancelButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -4),
            
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 4),
            createButton.bottomAnchor.constraint(equalTo: cancelButton.bottomAnchor)
        ])
    }
    
    func setupView() {
        view.backgroundColor = UIColor(named: "White")
        
        tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: TextFieldTableViewCell.textFieldTableViewCellIdentifier)
        tableView.register(HabbitSetupTableViewCell.self, forCellReuseIdentifier: HabbitSetupTableViewCell.habbitSetupTableViewCellIdentifier)
        tableView.register(EmojiTableViewCell.self, forCellReuseIdentifier: EmojiTableViewCell.emojiTableViewCellIdentifier)
        tableView.register(ColorsTableViewCell.self, forCellReuseIdentifier: ColorsTableViewCell.colorsTableViewCellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        setupSubviews()
        setupLayout()
    }
    
    func  fillSheduleIfRequired() {
        guard let cells = cells,
              let section = cells[1] else {
            return
        }
        
        if section.count == 1 {
            schedule = TrackerSchedule.allCases
        }
    }
    
    func selectCell(indexPath: IndexPath) {
        var viewController: UIViewController?
        if indexPath.section != 1 {
            return
        }
        
        if indexPath.row == 0 {
            viewController = ListCategoriesViewController()
        } else if indexPath.row == 1 {
            viewController = ScheduleViewController()
        }
        
        guard let viewController = viewController else {
            return
        }
        
        if let viewController = viewController as? ListCategoriesViewController {
            viewController.delegate = self
        } else if let viewController = viewController as? ScheduleViewController {
            viewController.delegate = self
            viewController.schedule = schedule
        } else {
            return
        }
            
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true)
    }
        
    func updateCreateButton() {
        if let category = category,
           let schedule = schedule,
           let name = name,
           let _ = color,
           let _ = emoji,
           let _ = delegate,
           category.title.count > 0,
           name.count > 0,
           schedule.count > 0
        {
            createButton.isEnabled = true
            createButton.backgroundColor = UIColor(named: "Black")
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = UIColor(named: "Gray")
        }
    }
    
    func scheduleToString() -> String? {
        guard let arr = schedule else { return nil }
        
        var stringResult = ""
        if arr.count == 7 {
            stringResult = "Каждый день"
        } else {
            let filter = arr.map { $0.shortDayName }
            stringResult = filter.joined(separator: ", ")
        }
        return stringResult
    }
}
