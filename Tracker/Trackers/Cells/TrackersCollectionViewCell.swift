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

final class TrackersCollectionViewCell: UICollectionViewCell {
    static let trackersCollectionViewCellIdentifier = "TrackersCollectionViewCell"
    
    weak var delegate: TrackersCollectionViewCellDelegate?
    
    private var isCompleted: Bool = false
    private var trackerId: UUID?
    private var selectedDate: Date?
    private var tracker: Tracker?
    
    private(set) var preview: UIView?
    
    // MARK: - Layout items
    private let colorView: UIView = {
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
    
        return view
    }()
    
    private let emojiWrapper: UIView = {
        let emoji = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 24, height: 24)))
        emoji.layer.cornerRadius = 12
        emoji.layer.masksToBounds = true
        emoji.backgroundColor = UIColor(named: "Background")
        emoji.translatesAutoresizingMaskIntoConstraints = false
            
        return emoji
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
    
    private lazy var pinImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        
        image.image = UIImage(named: "Pin")
        image.isHidden = false
        
        return image
    }()
    
    // MARK: - Lifecycle hooks
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubviews()
        setupLayout()
        
        preview = colorView
        
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
        let localizedFormatString = NSLocalizedString("daysTracked", comment: "")
        quantityLabel.text = String(format: localizedFormatString, counter)
        isCompleted = completed
        self.selectedDate = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: selectedDate))
        pinImageView.isHidden = !tracker.pinned
        
        updateCheckTrackerButton()
    }
        
    private func createQuantityManagementView() -> UIView {
        let quantityManagementView = UIView(frame: .zero)
        
        quantityManagementView.translatesAutoresizingMaskIntoConstraints = false
        
        return quantityManagementView
    }
}
// MARK: - Private routines & layoute
private extension TrackersCollectionViewCell {
    func setupSubviews() {
        emojiWrapper.addSubview(emojiLabel)
        colorView.addSubview(emojiWrapper)
        colorView.addSubview(titleLabel)
        colorView.addSubview(pinImageView)
        
        contentView.addSubview(colorView)
        contentView.addSubview(checkTrackerButton)
        contentView.addSubview(quantityLabel)
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            colorView.heightAnchor.constraint(equalToConstant: 90),
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiWrapper.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiWrapper.centerYAnchor),
            
            pinImageView.heightAnchor.constraint(equalToConstant: 24),
            pinImageView.widthAnchor.constraint(equalToConstant: 24),
            pinImageView.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 12),
            pinImageView.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -4),
            
            emojiWrapper.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 12),
            emojiWrapper.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
            emojiWrapper.widthAnchor.constraint(equalToConstant: 24),
            emojiWrapper.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(greaterThanOrEqualTo: emojiWrapper.bottomAnchor, constant: 8),
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
    }
    
    @objc private func checkButtonTap() {
        guard 
            let tracker = tracker,
            let selectedDate = selectedDate,
            let currentDate = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: Date()))
        else {
            return
        }
        
        if selectedDate > currentDate {
            return
        }
        
        isCompleted = !isCompleted
        updateCheckTrackerButton()
        delegate?.updateTrackerRecord(tracker: tracker, isCompleted: isCompleted, cell: self)
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
