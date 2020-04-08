//
//  AnimalDetailViewController.swift
//  AnimalSpotter
//
//  Created by Scott Gardner on 4/4/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class AnimalDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    static let identifier: String = String(describing: AnimalDetailViewController.self)
    
    @IBOutlet weak var timeSeenLabel: UILabel!
    @IBOutlet weak var coordinatesLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var animalImageView: UIImageView!
    
    var animalName: String?
    
    private lazy var viewModel = AnimalDetailViewModel()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animalImageView.layer.cornerRadius = animalImageView.bounds.width / 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let animalName = animalName else { return }
        
        viewModel.getAnimal(with: animalName) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .successfulWithAnimal(let animal):
                self.updateViews(with: animal)
            case .successfulWithImage(let image):
                self.animalImageView.image = image
            case .failure(let message):
                let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
    
    private func updateViews(with animal: Animal) {
        title = animal.name
        timeSeenLabel.text = dateFormatter.string(from: animal.timeSeen)
        coordinatesLabel.text = "lat: \(animal.latitude), long: \(animal.longitude)"
        descriptionLabel.text = animal.description
    }
}
