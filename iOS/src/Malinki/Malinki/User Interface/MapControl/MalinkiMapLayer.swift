//
//  MalinkiMapLayer.swift
//  Malinki
//
//  Created by Christoph Jung on 09.08.21.
//

import SwiftUI

/// A structure to descripe a map layer.
struct MalinkiMapLayer {
    
    let id: Int
    let name: String
    let image: Image
    var isToggled: Bool = true
    
    /// The initialiser of this structure.
    /// - Parameters:
    ///   - id: the ID of the map layer
    ///   - name: the external name of the map layer
    ///   - imageName: the image name of the map layer
    init(id: Int, name: String, imageName: String) {
        self.id = id
        self.name = name
        self.image = Image(systemName: imageName)
    }
}
