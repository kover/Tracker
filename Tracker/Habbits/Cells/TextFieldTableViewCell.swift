//
//  TextFieldTableViewCell.swift
//  Tracker
//
//  Created by Konstantin Penzin on 10.11.2023.
//

import UIKit

protocol TextFieldTableViewCellDelegate: AnyObject {
    func setHabbitName(with name: String?)
}

final class TextFieldTableViewCell: UITableViewCell {
    static let textFieldTableViewCellIdentifier = "textFieldTableViewCell"
    
    weak var delegate: TextFieldTableViewCellDelegate?
    
    // MARK: - Layout items
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        textField.placeholder = "Введите название трекера"
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.returnKeyType = UIReturnKeyType.done
        textField.clearButtonMode = .whileEditing
        
        textField.delegate = self
        
        return textField
    }()
    
    //MARK: - Cell configuration
    func setupCell() {
        selectionStyle = .none
        
        setupSubviews()
        setupLayout()
    }
}

// MARK: - UITextFieldDelegate
extension TextFieldTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 38
        let currentString: NSString? = textField.text as? NSString
        
        guard let currentString = currentString else {
            return true
        }
        
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        
        let isAcceptableLength = newString.length <= maxLength
        
        if isAcceptableLength {
            delegate?.setHabbitName(with: newString as String)
        }
        
        return isAcceptableLength
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}

// MARK: - Layout configuration
private extension TextFieldTableViewCell {
    func setupSubviews() {
        contentView.backgroundColor = UIColor(named: "Background")
        contentView.addSubview(nameTextField)
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: contentView.topAnchor),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nameTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
