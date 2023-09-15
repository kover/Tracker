//
//  TrackersCollectionViewCell.swift
//  Tracker
//
//  Created by Konstantin Penzin on 16.09.2023.
//

import UIKit

class TrackersCollectionViewCell: UICollectionViewCell {
    static let trackersCollectionViewCellIdentifier = "TrackersCollectionViewCell"
    
    private let colorView: UIView = {
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
    
        
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let emoji = UILabel()
        emoji.font = .systemFont(ofSize: 13)
        
        emoji.translatesAutoresizingMaskIntoConstraints = false
        
        return emoji
    }()
    
    private let titleLabel: UILabel = {
        let title = UILabel()
        title.font = .systemFont(ofSize: 12)
        title.textColor = UIColor(named: "White")
        title.numberOfLines = 2
        
        title.translatesAutoresizingMaskIntoConstraints = false
        
        return title
    }()
    
    private let quantityLabel: UILabel = {
        let quantity = UILabel()
        quantity.font = .systemFont(ofSize: 12)
        
        quantity.translatesAutoresizingMaskIntoConstraints = false
        
        return quantity
    }()
    
    private let checkTrackerButton: UIView = {
        let button = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 34, height: 34)))
        button.backgroundColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonLabel = UILabel()
        buttonLabel.font = .systemFont(ofSize: 12)
        buttonLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
        ])
        
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let emojiHolder = createEmojiHolder()
        colorView.addSubview(emojiHolder)
        colorView.addSubview(titleLabel)
        
        contentView.addSubview(colorView)
        
        NSLayoutConstraint.activate([
            colorView.heightAnchor.constraint(equalToConstant: 90),
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emojiHolder.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 12),
            emojiHolder.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
            emojiHolder.widthAnchor.constraint(equalToConstant: 24),
            emojiHolder.heightAnchor.constraint(equalToConstant: 24),
            titleLabel.topAnchor.constraint(greaterThanOrEqualTo: emojiHolder.bottomAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: colorView.bottomAnchor, constant: -12),
            titleLabel.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -12)
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configureCell(emoji: String, title: String, counter: UInt, completed: Bool, color: UIColor) {
        colorView.backgroundColor = color
        titleLabel.text = title
        emojiLabel.text = emoji
        
    }
    
    private func createEmojiHolder() -> UIView {
        let emoji = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 24, height: 24)))
        emoji.layer.cornerRadius = 12
        emoji.layer.masksToBounds = true
        emoji.backgroundColor = UIColor(named: "Background")
        emoji.translatesAutoresizingMaskIntoConstraints = false
            
        emoji.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: emoji.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emoji.centerYAnchor)
        ])
            
        return emoji
    }
    
    private func createQuantityManagementView() -> UIView {
        let quantityManagementView = UIView(frame: .zero)
        
        quantityManagementView.translatesAutoresizingMaskIntoConstraints = false
        
        return quantityManagementView
    }
}
