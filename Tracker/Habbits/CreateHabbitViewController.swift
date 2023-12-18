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
    func updateTracker(tracker: Tracker, forCategory category: TrackerCategory)
}

final class CreateHabbitViewController: UIViewController {
    
    var tracker: Tracker?
    var completedDays: Int?
    
    private var category: TrackerCategory?
    private var schedule: [TrackerSchedule]?
    private var name: String?
    private var emoji: String?
    private var color: UIColor?
    
    weak var delegate: CreateHabbitViewControllerDelegate?
    var cells: Dictionary<Int, [String]>?
    
    private let trackerCategoryStore: TrackerCategoryStoreProtocol
    
    init(trackerCategoryStore: TrackerCategoryStoreProtocol) {
        self.trackerCategoryStore = trackerCategoryStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout items
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 75
        tableView.backgroundColor = UIColor(named: "MainBackground")
        tableView.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        
        return tableView
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        
        if tracker != nil {
            button.setTitle(NSLocalizedString("saveButton.title", comment: "The title for the save button on create habbit view"), for: .normal)
            button.addTarget(self, action: #selector(save), for: .touchUpInside)
        } else {
            button.setTitle(NSLocalizedString("createButton.title", comment: "The title for the create button on create habbit view"), for: .normal)
            button.addTarget(self, action: #selector(create), for: .touchUpInside)
        }
        
        button.setTitleColor(UIColor(named: "InvertedBlack"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(named: "Gray")
        button.isEnabled = false
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        
        button.setTitle(NSLocalizedString("cancelButton.title", comment: "The title for the cancel button on create habbit view"), for: .normal)
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
    
    private lazy var daysCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let localizedFormatString = NSLocalizedString("daysTracked", comment: "")
        label.text = String(format: localizedFormatString, completedDays ?? 0)
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = UIColor(named: "Black")
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        fillSheduleIfRequired()
        setupEdit()
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
    
    @objc func save() {
        if
            let id = tracker?.id,
            let category = category,
            let schedule = schedule,
            let name = name,
            let color = color,
            let emoji = emoji,
            let delegate = delegate,
            let pinned = tracker?.pinned
        {
            
            let updatedTracker = Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule, pinned: pinned)
            delegate.updateTracker(tracker: updatedTracker, forCategory: category)
            
            guard let window = UIApplication.shared.windows.first,
                  let rootViewController = window.rootViewController else {
                assertionFailure("Invalid configuration")
                return
            }
            rootViewController.dismiss(animated: true)
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
            cell.setupCell(name: name)
            
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
                text = NSLocalizedString("categorySection.name", comment: "Name for the category section on create habbit screen")
                description = category?.title
            } else {
                text = NSLocalizedString("scheduleSection.name", comment: "Name for the schedule section on create habbit screen")
                description = scheduleToString() ?? ""
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
            cell.setupCell(selectedEmoji: emoji)
            
            return cell
        } else {
            
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ColorsTableViewCell.colorsTableViewCellIdentifier,
                for: indexPath
            ) as? ColorsTableViewCell else {
                return UITableViewCell()
            }
            
            cell.delegate = self
            cell.setupCell(selectedColor: color)
            
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
    func setupEdit() {
        guard let tracker = tracker,
              let category = trackerCategoryStore.categoryForTracker(tracker)
        else {
            return
        }
        name = tracker.name
        schedule = tracker.schedule
        color = tracker.color
        emoji = tracker.emoji
        self.category = category

        updateCreateButton()
    }
    
    func setupSubviews() {
        if tracker != nil {
            view.addSubview(daysCountLabel)
        }
        view.addSubview(tableView)
        view.addSubview(cancelButton)
        view.addSubview(createButton)
    }
    
    func setupLayout() {
        let isEditingTracker = tracker != nil
        
        if isEditingTracker {
            NSLayoutConstraint.activate([
                daysCountLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                daysCountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        }
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: isEditingTracker ? daysCountLabel.bottomAnchor : view.topAnchor, constant: 24),
            
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
        view.backgroundColor = UIColor(named: "MainBackground")
        
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
            let viewModel = ListCategoriesViewModel(categoryStore: trackerCategoryStore)
            viewModel.selectedCategory = category
            viewController = ListCategoriesViewController(viewModel: viewModel)
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
            stringResult = NSLocalizedString("schedule.everyDay", comment: "String to be used when all items on the schedule screen are selected")
        } else {
            let filter = arr.map { $0.shortDayName }
            stringResult = filter.joined(separator: ", ")
        }
        return stringResult
    }
}
