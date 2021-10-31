//
//  MalinkiLayers.swift
//  Malinki
//
//  Created by Christoph Jung on 28.10.21.
//

import Foundation

final class MalinkiLayers: ObservableObject {
    
    @Published var layers: [MalinkiMapLayer]
    
    init(layers: [MalinkiMapLayer]) {
        self.layers = layers
    }
    
}
