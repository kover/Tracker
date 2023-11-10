//
//  TrackersCollectionViewCell.swift
//  Tracker
//
//  Created by Konstantin Penzin on 16.09.2023.
//

import UIKit

protocol TrackersCollectionViewCellDelegate: AnyObject {
    func updateTrackerRecord(tracker: Tracker, isCompleted: Bool, cell: TrackersCollectionViewCell)
}

class TrackersCollectionViewCell: UICollectionViewCell {
    static let trackersCollectionViewCellIdentifier = "TrackersCollectionViewCell"
    
    weak var delegate: TrackersCollectionViewCellDelegate?
    
    private var isCompleted: Bool = false
    private var trackerId: UUID?
    private var selectedDate: Date?
    private var tracker: Tracker?
    
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
        quantity.text = "0 дней"
        
        return quantity
    }()
    
    private let checkTrackerButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 11))
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(named: "White")
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let emojiHolder = createEmojiHolder()
        colorView.addSubview(emojiHolder)
        colorView.addSubview(titleLabel)
        
        contentView.addSubview(colorView)
        
        contentView.addSubview(checkTrackerButton)
        
        contentView.addSubview(quantityLabel)
        
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
            titleLabel.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -12),
            
            checkTrackerButton.widthAnchor.constraint(equalToConstant: 34),
            checkTrackerButton.heightAnchor.constraint(equalToConstant: 34),
            checkTrackerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            checkTrackerButton.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 8),
            
            quantityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            quantityLabel.centerYAnchor.constraint(equalTo: checkTrackerButton.centerYAnchor),
            quantityLabel.trailingAnchor.constraint(lessThanOrEqualTo: checkTrackerButton.leadingAnchor, constant: -8)
        ])
        
        checkTrackerButton.addTarget(self, action: #selector(checkButtonTap), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(for tracker: Tracker, runFor counter: Int, done completed: Bool, at selectedDate: Date) {
        self.tracker = tracker
        colorView.backgroundColor = tracker.color
        checkTrackerButton.backgroundColor = tracker.color
        titleLabel.text = tracker.name
        emojiLabel.text = tracker.emoji
        quantityLabel.text = setQuantityLabel(count: counter)
        isCompleted = completed
        self.selectedDate = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: selectedDate))
        
        updateCheckTrackerButton()
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
// MARK: - Private routines
private extension TrackersCollectionViewCell {
    @objc private func checkButtonTap() {
        guard let tracker = tracker, let selectedDate = selectedDate else {
            return
        }
        
        let currentDate = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: Date()))
        
        if currentDate != selectedDate {
            return
        }
        
        isCompleted = !isCompleted
        updateCheckTrackerButton()
        delegate?.updateTrackerRecord(tracker: tracker, isCompleted: isCompleted, cell: self)
    }
    
    func setQuantityLabel(count: Int) -> String {
        var dayString: String!
        if "1".contains("\(count % 10)") {
            dayString = "день"
        }
        if "234".contains("\(count % 10)") {
            dayString = "дня"
        }
        if "567890".contains("\(count % 10)") {
            dayString = "дней"
        }
        if 11...14 ~= count % 100 {
            dayString = "дней"
        }
        return "\(count) " + dayString
    }
    
    func updateCheckTrackerButton() {
        if isCompleted {
            checkTrackerButton.alpha = 0.5
            checkTrackerButton.setImage(UIImage(
                systemName: "checkmark", 
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 11)
            ), for: .normal)
        } else {
            checkTrackerButton.alpha = 1
            checkTrackerButton.setImage(UIImage(
                systemName: "plus",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 11)
            ), for: .normal)
        }
    }
}
