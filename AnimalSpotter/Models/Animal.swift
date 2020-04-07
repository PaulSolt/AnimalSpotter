//
//  Animal.swift
//  AnimalSpotter
//
//  Created by Scott Gardner on 4/4/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

struct Animal: Decodable, Hashable {
    let id: Int
    let name: String
    let timeSeen: Date
    let latitude: Double
    let longitude: Double
    let description: String
    let imageURL: String
}
