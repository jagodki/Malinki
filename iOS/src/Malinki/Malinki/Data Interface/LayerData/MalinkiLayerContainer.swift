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
    var currentAnnotations: [String: String] = [:] //["mapTheme": String(...), "areAnnotationsToggled": String(...), "layers": ... + "-" + ...]
    
    private var _annotations: MalinkiAnnotationContainer = MalinkiAnnotationContainer()
    var annotations: MalinkiAnnotationContainer {
        get {
            return self._annotations
        }
    }
    
    /// The initialiser of this class.
    /// - Parameters:
    ///   - layers: an array of MalinkiLayer
    ///   - themes: an array of MalinkiTheme
    ///   - selectedMapThemeID: the ID of the currently selected map theme
    init(layers: [MalinkiLayer], themes: [MalinkiTheme], selectedMapThemeID: Int) {
        self.rasterLayers = layers
        self.mapThemes = themes
        self.selectedMapThemeID = selectedMapThemeID
    }
    
    /// Returns a dictionary with information about the current visible annotations.
    /// - Returns: a dictionary containing the current map theme, whether the annoations are toggled and all layers
    func getInformationAboutCurrentAnnotations() -> [String: String] {
        return ["mapTheme": String(self.selectedMapThemeID),
                "areAnnotationsToggled": String(self.areAnnotationsToggled()),
                "layers": self.getVisibleVectorLayers().map({String($0.id)}).joined(separator: "-")]
    }
    
    /// This function edits a dictionary containing information about the current layers represented by annotations.
    /// Also updates the information about new loaded annotations for fetching remote data.
    func setInformationAboutCurrentAnnotations() {
        self.currentAnnotations = self.getInformationAboutCurrentAnnotations()
        self._annotations.newAnnotationsLoaded = false
    }
    
    /// Returns a dictionary with information about the current visible raster layers.
    /// - Parameter baseMapID: the ID of the current basemap
    /// - Returns: a dictionary containing the current map theme, the basemap and all layers
    func getInformationAboutCurrentRasterlayers(baseMapID: Int) -> [String: String] {
        return ["mapTheme": String(self.selectedMapThemeID),
                "baseMap": String(baseMapID),
                "layers": self.getVisibleRasterLayerIDs().map({String($0)}).joined(separator: "-")]
    }
    
    /// Sets the information about the current raster layers.
    /// - Parameters:
    ///   - region: the MKCoordinateRegion of the current map scene
    ///   - baseMapID: the ID of the current basemap
    func setInformationAboutCurrentRasterlayers(for region: MKCoordinateRegion, baseMapID: Int) {
        self.currentRasterLayers = self.getInformationAboutCurrentRasterlayers(baseMapID: baseMapID)
        self.currentMapRegion = region
    }
    
    /// An information about the status of the annotations
    /// - Returns: returns true, if the annotations of the current map theme are toggled
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
        return self.getVectorLayers().filter({vectorLayer in
            //default to true for vector layers without corresponding raster layer
            var isVisible = true
            
            if let correspondingRasterLayer = vectorLayer.correspondingRasterLayer {
                isVisible = self.getVisibleRasterLayerIDs().contains(correspondingRasterLayer)
            }
            
            return isVisible
        })
    }
    
    /// This functions starts the query of the current annotations.
    func queryCurrentAnnotations() {
        self._annotations.getAnnotationFeatures(for: self.getVisibleVectorLayers().map({$0.id}), in: self.selectedMapThemeID)
    }
    
}
