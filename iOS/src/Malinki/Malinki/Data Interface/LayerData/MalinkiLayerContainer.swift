//
//  MalinkiLayers.swift
//  Malinki
//
//  Created by Christoph Jung on 28.10.21.
//

import Foundation
import MapKit

/// An observable class containing map layers as a published array.
final class MalinkiLayerContainer: ObservableObject {
    
    @Published var rasterLayers: [MalinkiLayer]
    @Published var mapThemes: [MalinkiTheme]
    var currentRasterLayers: [String: String] = [:]
    var currentMapRegion: MKCoordinateRegion?
    var allowRedraw: Bool = true
    
    init(layers: [MalinkiLayer], themes: [MalinkiTheme]) {
        self.rasterLayers = layers
        self.mapThemes = themes
    }
    
}
