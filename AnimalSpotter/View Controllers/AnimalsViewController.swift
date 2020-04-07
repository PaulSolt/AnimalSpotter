//
//  AnimalsViewController.swift
//  AnimalSpotter
//
//  Created by Scott Gardner on 4/4/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

final class AnimalsViewController: UIViewController {
    enum CellIdentifier: String {
        case animalCell = "AnimalCell"
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private lazy var viewModel = AnimalsViewModel()
    private lazy var dataSource = makeDataSource()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Actions
    
    @IBAction func getAnimalNames(_ sender: UIBarButtonItem) {
        
    }
}

// MARK: - UITableViewDiffableDataSource

extension AnimalsViewController {
    enum Section {
        case main
    }
    
    private func makeDataSource() -> UITableViewDiffableDataSource<Section, String> {
        UITableViewDiffableDataSource(tableView: tableView) { tableView, indexPath, name in
            let cell = tableView
                .dequeueReusableCell(withIdentifier: CellIdentifier.animalCell.rawValue,
                                     for: indexPath)
            
            cell.textLabel?.text = name
            return cell
        }
    }
    
    private func update() {
        activityIndicator.stopAnimating()
        var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.animalNames)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
