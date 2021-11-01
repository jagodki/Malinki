//
//  MalinkiLayers.swift
//  Malinki
//
//  Created by Christoph Jung on 28.10.21.
//

import Foundation

final class MalinkiLayerContainer: ObservableObject {
    
    @Published var rasterLayers: [MalinkiLayer]
    
    init(layers: [MalinkiLayer]) {
        self.rasterLayers = layers
    }
    
}
