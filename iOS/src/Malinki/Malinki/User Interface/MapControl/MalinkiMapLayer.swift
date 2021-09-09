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
    @State var isToggled: Bool = true
    
    init(id: Int, name: String, imageName: String) {
        self.id = id
        self.name = name
        self.image = Image(systemName: imageName)
    }
}
