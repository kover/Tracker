//
//  ListCategoriesViewController.swift
//  Tracker
//
//  Created by Konstantin Penzin on 10.11.2023.
//

import UIKit

protocol SelectCategoryDelegate: AnyObject {
    func updateCategory(category: TrackerCategory)
}

final class ListCategoriesViewController: UIViewController {

    weak var delegate: SelectCategoryDelegate?
    
    private let viewModel: ListCategoriesViewModel
        
    init(viewModel: ListCategoriesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout items
    private lazy var placeholderImageView: UIImageView = {
        let image = UIImage(named: "TrackersPlaceholder")
        
        let imageView = UIImageView(image: image)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = NSLocalizedString("emptyCategoriesPlaceholder.text", comment: "Text for the placeholder if no categories defined")
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(named: "Black")
        label.textAlignment = .center
        label.numberOfLines = 2
        
        return label
    }()
    
    private lazy var addCateroryButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setTitle(NSLocalizedString("addCategoryButton.title", comment: "Title for the add category button on the categories list and create category screens"), for: .normal)
        button.addTarget(self, action: #selector(addCategory), for: .touchUpInside)
        button.backgroundColor = UIColor(named: "Black")
        button.setTitleColor(UIColor(named: "InvertedBlack"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        
        return button
    }()
    
    private lazy var categoryTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.rowHeight = 75
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor(named: "MainBackground")
        
        return tableView
    }()
    
    //MARK: - Lifecycle hooks
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubviews()
        setupLayout()
        bind()
    }
}

//MARK: - CreateCategoryDelegate
extension ListCategoriesViewController: CreateCategoryDelegate {
    func createCategory(category: String) {
        viewModel.createCategory(category)
        togglePlaceholderVisibility()
    }
}

//MARK: - UITableViewDataSource
extension ListCategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let category = viewModel.categoryAt(indexPath.row) else {
            return UITableViewCell()
        }
        let header = category.title
        
        guard let cell = categoryTableView.dequeueReusableCell(
            withIdentifier: CategoryTableViewCell.categoryTableViewCellIdentifier,
            for: indexPath
        ) as? CategoryTableViewCell else {
            return UITableViewCell()
        }
        
        
        cell.setupCell(text: header, isSelected: viewModel.isSelected(category: category))
        
        return cell
    }
    
}

//MARK: - UITableViewDelegate
extension ListCategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let delegate = delegate,
        let category = viewModel.categoryAt(indexPath.row) else {
            tableView.deselectRow(at: indexPath, animated: false)
            return
        }
        delegate.updateCategory(category: category)
        tableView.deselectRow(at: indexPath, animated: false)
        dismiss(animated: true)
    }
}

//MARK: - Private routines & layout
private extension ListCategoriesViewController {
    func setupSubviews() {
        view.backgroundColor = UIColor(named: "MainBackground")
        
        navigationItem.title = NSLocalizedString("categoriesList.title", comment: "Title for the categories list screen")

        togglePlaceholderVisibility()
        categoryTableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.categoryTableViewCellIdentifier)
        
        view.addSubview(categoryTableView)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        view.addSubview(addCateroryButton)
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            categoryTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoryTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            categoryTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            categoryTableView.bottomAnchor.constraint(equalTo: addCateroryButton.topAnchor),
            
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            placeholderImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: placeholderImageView.centerXAnchor),
            
            addCateroryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCateroryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCateroryButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            addCateroryButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func togglePlaceholderVisibility() {
        if viewModel.shouldHidePlaceholder {
            categoryTableView.isHidden = false
            placeholderLabel.isHidden = true
            placeholderImageView.isHidden = true
        } else {
            categoryTableView.isHidden = true
            placeholderLabel.isHidden = false
            placeholderImageView.isHidden = false
        }
    }
    
    @objc func addCategory() {
        let createCategoryViewController = CreateCategoryViewController()
        createCategoryViewController.delegate = self
        let navigatonViewController = UINavigationController(rootViewController: createCategoryViewController)
        present(navigatonViewController, animated: true)
    }
    
    func bind() {
        viewModel.$categories.bind {[weak self] _ in
            self?.categoryTableView.reloadData()
        }
    }
}
