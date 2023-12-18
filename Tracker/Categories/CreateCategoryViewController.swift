//
//  CreateCategoryViewController.swift
//  Tracker
//
//  Created by Konstantin Penzin on 11.11.2023.
//

import UIKit

protocol CreateCategoryDelegate: AnyObject {
    func createCategory(category: String)
}

final class CreateCategoryViewController: UIViewController {
    
    weak var delegate: CreateCategoryDelegate?
    
    // MARK: - Layout items
    private lazy var nameCategoryTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.size.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.placeholder = NSLocalizedString("newCategoryNamePlaceholder.text", comment: "Placeholder text for the category name input")
        textField.backgroundColor = UIColor(named: "Background")
        textField.layer.cornerRadius = 16
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        
        return textField
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setTitle(NSLocalizedString("addCategoryButton.title", comment: "Title for the add category button on the categories list and create category screens"), for: .normal)
        button.addTarget(self, action: #selector(done), for: .touchUpInside)
        button.backgroundColor = UIColor(named: "Gray")
        button.setTitleColor(UIColor(named: "InvertedBlack"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.isEnabled = false
        
        return button
    }()
    
    //MARK: - Lyfecycle hooks
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = NSLocalizedString("newCategoryView.title", comment: "Title for the create category screen")
        
        view.backgroundColor = UIColor(named: "MainBackground")
        
        setupSubviews()
        setupLayout()
    }
}

//MARK: - UITextFieldDelegate
extension CreateCategoryViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let currentString: NSString? = textField.text as? NSString
        guard let currentString = currentString else { return true }
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
       
        let count = (newString as String).count
        if count > 0 {
            doneButton.isEnabled = true
            doneButton.backgroundColor = UIColor(named: "Black")
        } else {
            doneButton.isEnabled = false
            doneButton.backgroundColor = UIColor(named: "Gray")
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - Private routines & layout
private extension CreateCategoryViewController {
    
    func setupSubviews() {
        view.addSubview(nameCategoryTextField)
        view.addSubview(doneButton)
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            nameCategoryTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameCategoryTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameCategoryTextField.heightAnchor.constraint(equalToConstant: 75),
            nameCategoryTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
        
    @objc func done(){
        guard let text = nameCategoryTextField.text,
              let delegate = delegate else {
            return
        }
        delegate.createCategory(category: text)
        
        dismiss(animated: true)
    }
}
