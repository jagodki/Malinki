//
//  MalinkiLayers.swift
//  Malinki
//
//  Created by Christoph Jung on 28.10.21.
//

import Foundation

/// An observable class containing map layers as a published array.
final class MalinkiLayerContainer: ObservableObject {
    
    @Published var rasterLayers: [MalinkiRasterLayer]
    @Published var mapThemes: [MalinkiTheme]
    
    init(layers: [MalinkiRasterLayer], themes: [MalinkiTheme]) {
        self.rasterLayers = layers
        self.mapThemes = themes
    }
    
}
