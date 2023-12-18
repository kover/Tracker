//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Konstantin Penzin on 15.09.2023.
//

import UIKit

final class StatisticsViewController: UIViewController {
    
    private let trackerRecordStore: TrackerRecordStoreProtocol
    
    init(recordStore: TrackerRecordStoreProtocol) {
        self.trackerRecordStore = recordStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Layout items
    private var placeholderView: TrackersPlaceholderView = {
        let placeholder = TrackersPlaceholderView(placeholderText: NSLocalizedString("statistics.noStatistics", comment: "Empty statistics label"), frame: .zero)
        placeholder.updateImage(UIImage(named: "EmptyStatistics"))
        
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        
        return placeholder
    }()
    
    private lazy var completedTrackersView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var completedTrackersResultLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textAlignment = .left
        label.textColor = UIColor(named: "Black")
        
        return label
    }()
    
    private lazy var completedTrackersTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let localizedFormatString = NSLocalizedString("statistics.trackersCompleted", comment: "")
        label.text = String(format: localizedFormatString, 0)
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(named: "Black")
        label.textAlignment = .left
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubviews()
        setupLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateRecords()
        setupGradient()
    }
    
    //MARK: - Public functions
    func updateRecords() {
        let completedTrackers = trackerRecordStore.getRecords()
        completedTrackersResultLabel.text = String(completedTrackers.count)
        let localizedFormatString = NSLocalizedString("statistics.trackersCompleted", comment: "")
        completedTrackersTitleLabel.text = String(format: localizedFormatString, completedTrackers.count)
        
        let isHidden = completedTrackers.count > 0
        placeholderView.isHidden = isHidden
        completedTrackersView.isHidden = !isHidden
    }
}

//MARK: - Private routines
private extension StatisticsViewController {
    func setupSubviews() {
        view.backgroundColor = UIColor(named: "MainBackground")
        
        view.addSubview(placeholderView)
        
        view.addSubview(completedTrackersView)
        completedTrackersView.addSubview(completedTrackersResultLabel)
        completedTrackersView.addSubview(completedTrackersTitleLabel)

    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            completedTrackersView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 77),
            completedTrackersView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            completedTrackersView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            completedTrackersView.heightAnchor.constraint(equalToConstant: 90),
            
            completedTrackersResultLabel.topAnchor.constraint(equalTo: completedTrackersView.topAnchor, constant: 12),
            completedTrackersResultLabel.leadingAnchor.constraint(equalTo: completedTrackersView.leadingAnchor, constant: 12),
            completedTrackersResultLabel.trailingAnchor.constraint(equalTo: completedTrackersView.trailingAnchor, constant: -12),
            completedTrackersResultLabel.heightAnchor.constraint(equalToConstant: 41),
            
            completedTrackersTitleLabel.bottomAnchor.constraint(equalTo: completedTrackersView.bottomAnchor, constant: -12),
            completedTrackersTitleLabel.leadingAnchor.constraint(equalTo: completedTrackersView.leadingAnchor, constant: 12),
            completedTrackersTitleLabel.trailingAnchor.constraint(equalTo: completedTrackersView.trailingAnchor, constant: -12),
            completedTrackersTitleLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    func setupGradient() {
        let border = CAGradientLayer()
        border.frame = completedTrackersView.bounds
        border.colors = [UIColor.red.cgColor, UIColor.green.cgColor, UIColor.blue.cgColor]
        border.startPoint = CGPoint(x: 0, y: 0.5)
        border.endPoint = CGPoint(x: 1, y: 0.5)
        
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(roundedRect: completedTrackersView.bounds, cornerRadius: 16).cgPath
        mask.fillColor = UIColor.clear.cgColor
        mask.strokeColor = UIColor.white.cgColor
        mask.lineWidth = 1
        
        border.mask = mask
        
        completedTrackersView.layer.addSublayer(border)
    }
}
