//
//  MalinkiLayers.swift
//  Malinki
//
//  Created by Christoph Jung on 28.10.21.
//

import Foundation
import MapKit

/// An observable class containing map layers as a published array.
@available(iOS 15.0.0, *)
final class MalinkiLayerContainer: ObservableObject {
    
    @Published var rasterLayers: [MalinkiLayer] {
        didSet {
            self.queryCurrentAnnotations()
        }
    }
    @Published var mapThemes: [MalinkiTheme] {
        didSet {
            self.queryCurrentAnnotations()
        }
    }
    @Published var selectedMapThemeID: Int {
        didSet {
            self.queryCurrentAnnotations()
        }
    }
    var currentRasterLayers: [String: String] = [:]
    var currentMapRegion: MKCoordinateRegion?
    var allowRedraw: Bool = true
    var annotations: MalinkiAnnotationContainer = MalinkiAnnotationContainer()
    
    init(layers: [MalinkiLayer], themes: [MalinkiTheme], selectedMapThemeID: Int) {
        self.rasterLayers = layers
        self.mapThemes = themes
        self.selectedMapThemeID = selectedMapThemeID
    }
    
    func getInformationAboutCurrentAnnotations() -> [String: String] {
        return ["mapTheme": String(self.selectedMapThemeID),
                "areAnnotationsToggled": String(self.areAnnotationsToggled()),
                "layers": self.getVisibleVectorLayers().map({String($0.id)}).joined(separator: "-")]
    }
    
    /// This function edits a dictionary containing information about the current layers represented by annotations.
    func setInformationAboutCurrentAnnotations() {
        self.annotations.currentAnnotations = self.getInformationAboutCurrentAnnotations()
    }
    
    func getInformationAboutCurrentRasterlayers(baseMapID: Int) -> [String: String] {
        return ["mapTheme": String(self.selectedMapThemeID),
                "baseMap": String(baseMapID),
                "layers": self.getVisibleRasterLayerIDs().map({String($0)}).joined(separator: "-")]
    }
    
    func setInformationAboutCurrentRasterlayers(for region: MKCoordinateRegion, baseMapID: Int) {
        self.currentRasterLayers = self.getInformationAboutCurrentRasterlayers(baseMapID: baseMapID)
        self.currentMapRegion = region
    }
    
    func areAnnotationsToggled() -> Bool {
        return self.mapThemes.filter({$0.annotationsAreToggled && $0.themeID == self.selectedMapThemeID}).count != 0
    }
    
    /// Get all vector/annotation layers corresponding to the map theme.
    /// - Returns: an array of MalinkiConfigurationVectorData
    private func getVectorLayers() -> [MalinkiConfigurationVectorData] {
        return MalinkiConfigurationProvider.sharedInstance.getAllVectorLayers(for: self.selectedMapThemeID)
    }
    
    /// Get all visible raster layers.
    /// - Returns: an array of Integers
    private func getVisibleRasterLayerIDs() -> [Int] {
        return self.rasterLayers.filter({$0.isToggled && $0.themeID == self.selectedMapThemeID}).map({$0.id})
    }
    
    /// Get all visible vector/annotation layers (getVectorLayers() - getVisibleRasterLayerIDs()).
    /// - Returns: an array of MalinkiConfigurationVectorData
    func getVisibleVectorLayers() -> [MalinkiConfigurationVectorData] {
        return self.getVectorLayers().filter({self.getVisibleRasterLayerIDs().contains($0.correspondingRasterLayer)})
    }
    
    func queryCurrentAnnotations() {
        self.annotations.getAnnotationFeatures(for: self.getVisibleVectorLayers().map({$0.id}), in: self.selectedMapThemeID)
    }
    
}
