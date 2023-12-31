//
//  ColorsTableViewCell.swift
//  Tracker
//
//  Created by Konstantin Penzin on 10.11.2023.
//

import UIKit

protocol ColorsTableViewCellDelegate: AnyObject {
    func updateColor(with color: UIColor?)
}

final class ColorsTableViewCell: UITableViewCell {
    
    static let colorsTableViewCellIdentifier = "colorsTableViewCell"

    var delegate: ColorsTableViewCellDelegate?
    
    private let colors = [UIColor(named: "Selection1"),  UIColor(named: "Selection2"),  UIColor(named: "Selection3"),
                          UIColor(named: "Selection4"),  UIColor(named: "Selection5"),  UIColor(named: "Selection6"),
                          UIColor(named: "Selection7"),  UIColor(named: "Selection8"),  UIColor(named: "Selection9"),
                          UIColor(named: "Selection10"), UIColor(named: "Selection11"), UIColor(named: "Selection12"),
                          UIColor(named: "Selection13"), UIColor(named: "Selection14"), UIColor(named: "Selection15"),
                          UIColor(named: "Selection16"), UIColor(named: "Selection17"), UIColor(named: "Selection18")
    ]
    
    var selectedColor: UIColor?
    
    // MARK: - Layout items
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        
        label.text = NSLocalizedString("createTrackerColorSection.title", comment: "Color table section title for the create habbit screen")
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = UIColor(named: "Black")
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var colorsCollectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.itemSize = CGSize(width: 52, height: 52)
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: ColorCollectionViewCell.colorCollectionViewCellIdentifier)
        return collectionView
    }()
    
    //MARK: - Cell configuration
    func setupCell(selectedColor: UIColor?) {
        selectionStyle = .none
        
        self.selectedColor = selectedColor
        
        setupSubviews()
        setupLayout()
    }
}

//MARK: - UICollectionViewDataSource
extension ColorsTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionViewCell.colorCollectionViewCellIdentifier, for: indexPath) as? ColorCollectionViewCell
        guard let cell = cell, let color = colors[indexPath.row] else { return UICollectionViewCell() }
        
        cell.setupCell(color: color)
                
        if let selectedColor = selectedColor,
           let currentColor = colors[indexPath.row],
           selectedColor == currentColor {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
            setCellBorder(cell: cell, color: selectedColor)
        }

        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension ColorsTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedColor = colors[indexPath.row]
        
        let cell = collectionView.cellForItem(at: indexPath)
        setCellBorder(cell: cell, color: selectedColor)
    
        delegate?.updateColor(with: selectedColor)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderWidth = 0
    }
}

//MARK: - Private routines & layout
private extension ColorsTableViewCell {
    
    func setupSubviews() {
        contentView.backgroundColor = UIColor(named: "MainBackground")
        contentView.addSubview(titleLabel)
        contentView.addSubview(colorsCollectionView)
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 18),
            
            colorsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorsCollectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            colorsCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    func setCellBorder(cell: UICollectionViewCell?, color: UIColor?) {
        guard let cell = cell,
              let color = color else {
            return
        }
        
        cell.layer.borderWidth = 3
        cell.layer.cornerRadius = 8
        cell.layer.borderColor = color.withAlphaComponent(0.3).cgColor
    }
}
