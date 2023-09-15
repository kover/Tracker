//
//  CreateHabbitViewController.swift
//  Tracker
//
//  Created by Konstantin Penzin on 07.11.2023.
//

import UIKit

class CreateHabbitViewController: UIViewController {
    
    let eventType: EventType!
    
    init(eventType: EventType = .Habbit) {
        self.eventType = eventType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var nameTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.placeholder = "Введите название трекера"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clearButtonMode = .whileEditing
    
        return textField
    }()
    
    private var categoryView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.isScrollEnabled = false
        tableView.allowsSelection = false
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.backgroundColor = UIColor(named: "Background")
        tableView.separatorInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white    
        
        setupViews()

    }
    
    private func setupViews() {

        let nameTextFieldWrapper = UIView(frame: .zero)
        nameTextFieldWrapper.backgroundColor = UIColor(named: "Background")
        nameTextFieldWrapper.translatesAutoresizingMaskIntoConstraints = false
        nameTextFieldWrapper.layer.cornerRadius = 16
        nameTextFieldWrapper.layer.masksToBounds = true

        view.addSubview(nameTextFieldWrapper)
        nameTextFieldWrapper.addSubview(nameTextField)
        
        categoryView.dataSource = self
        categoryView.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(tableTap(_:)))
        categoryView.addGestureRecognizer(tap)
        view.addSubview(categoryView)
        
        NSLayoutConstraint.activate([
            nameTextFieldWrapper.heightAnchor.constraint(equalToConstant: 75),
            nameTextFieldWrapper.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            nameTextFieldWrapper.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameTextFieldWrapper.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            nameTextField.centerYAnchor.constraint(equalTo: nameTextFieldWrapper.centerYAnchor),
            nameTextField.leadingAnchor.constraint(equalTo: nameTextFieldWrapper.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: nameTextFieldWrapper.trailingAnchor, constant: -41),
            categoryView.topAnchor.constraint(equalTo: nameTextFieldWrapper.bottomAnchor, constant: 24),
            categoryView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryView.heightAnchor.constraint(equalToConstant: 150),
        ])
    }
    
    @objc func tableTap(_ sender: UIGestureRecognizer) {
        let indexPath = categoryView.indexPathForRow(at: sender.location(in: categoryView))
        guard let indexPath = indexPath else {
            return
        }
        print(indexPath)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension CreateHabbitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventType == .Habbit ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SelectorTableViewCell(style: .default, reuseIdentifier: nil)
        cell.accessoryType = .disclosureIndicator
        cell.selectorLabel.text = indexPath.row == 0 ? "Категория" : "Расписание"
        cell.backgroundColor = .clear
        
        return cell
    }
}
extension CreateHabbitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
}
