//
//  AnimalsViewModel.swift
//  AnimalSpotter
//
//  Created by Scott Gardner on 4/4/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

final class AnimalsViewModel {
    enum GetAnimalNamesResult {
        case success
        case failure(String)
    }
    
    var animalNames = [String]()
    var shouldPresentLoginViewController: Bool {
        APIController.bearer == nil
    }
    
    private let apiController: APIController
    
    init(apiController: APIController = APIController()) {
        self.apiController = apiController
    }
    
    func getAnimalNames(completion: @escaping (GetAnimalNamesResult) -> Void) {
        apiController.getAnimalNames { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let animalNames):
                    self.animalNames = animalNames
                    completion(.success)
                case .failure(_):
                    completion(.failure("Unable to fetch animal names."))
                }
            }
        }
    }
}
