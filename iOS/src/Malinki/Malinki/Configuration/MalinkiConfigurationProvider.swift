//
//  MalinkiConfigurationLoader.swift
//  Malinki
//
//  Created by Christoph Jung on 15.08.21.
//

import Foundation

/// A class for loading the main configuration file
class MalinkiConfigurationProvider {
    
    /// The singleton of this class
    static let sharedInstance = MalinkiConfigurationProvider()
    private let configFileName = "Configuration"
    private var configData: MalinkiConfiguration? = nil

    /// The initialiser of this structure.
    private init() {
        guard let configURL = Bundle.main.url(forResource: self.configFileName, withExtension: "json") else {
            print("not able to find the configuration file")
            return
        }

        do {
            let decoder = JSONDecoder()
            self.configData = try decoder.decode(MalinkiConfiguration.self, from: Data(contentsOf: configURL))
        } catch  {
            print("Error decoding the configuration!")
            print(error)
        }

    }
    
    /// This function returns an array of all configured basemaps.
    /// - Returns: an array of all available basemaps
    func getBasemaps() -> [MalinkiConfigurationMapData] {
        return self.configData?.basemaps ?? []
    }
    
    /// This function returns a configured basemap for a given ID.
    /// - Parameter id: an integer representing the ID of a basemap
    /// - Returns: the configured basemap with the same ID as the given parameter
    func getBasemap(for id: Int) -> MalinkiConfigurationMapData? {
        return self.configData?.basemaps.filter({$0.id == id}).first
    }
    
    /// This function returns the ID of the after app launch toggled basemap.
    /// - Returns: the ID of the after app launch visible basemap
    func getIDOfBasemapOnStartUp() -> Int {
        return self.configData?.onStartUp.basemap ?? 0
    }
    
    /// This function returns an array of all configured map themes.
    /// - Returns: an array of all available map themes
    func getMapThemes() -> [MalinkiConfigurationTheme] {
        return self.configData?.mapThemes ?? []
    }
    
    /// This function returns a configured map theme for a given ID.
    /// - Parameter id: an integer representing the ID of a map theme
    /// - Returns: the configured map theme with the same ID as the given parameter
    func getMapTheme(for id: Int) -> MalinkiConfigurationTheme? {
        return self.configData?.mapThemes.filter({$0.id == id}).first
    }
    
    /// This function returns the ID of the after app launch toggled map theme.
    /// - Returns: the ID of the after app launch visible map theme
    func getIDOfMapThemeOnStartUp() -> Int {
        return self.configData?.onStartUp.theme ?? 0
    }
    
    /// This function returns the opacity of a raster layer.
    /// - Parameters:
    ///   - layerID: the ID of the raster layer
    ///   - mapThemeID: the ID of the map theme containing the raster layer
    /// - Returns: the opacity of the specific layer or 1.0, if no layer could be found with the given parameters
    func getOpacityForRasterLayer(with layerID: Int, from mapThemeID: Int) -> Double {
        return self.configData?.mapThemes.filter({$0.id == mapThemeID}).first?.layers.rasterLayers.filter({$0.id == layerID}).first?.opacity ?? 1.0
    }
    
    /// This function returns all raster layers of a given map theme.
    /// - Parameter mapTheme: the ID of a map theme
    /// - Returns: an array of all raster layers of the given map theme
    func getRasterLayers(of mapTheme: Int) -> [MalinkiConfigurationMapData] {
        return self.configData?.mapThemes.filter({$0.id == mapTheme}).first?.layers.rasterLayers ?? []
    }
    
    /// This function returns all raster layers.
    /// - Returns: an array of all raster layers
    func getAllRasterLayers() -> [MalinkiConfigurationMapData] {
        return self.configData?.mapThemes.map({$0.layers.rasterLayers}).flatMap({$0}).sorted(by: {$0.id > $1.id}) ?? []
    }
    
    /// This function returns all raster layers of the map theme that is active on start up.
    /// - Returns:an array of all raster layers of the map theme that is active on start up
    func getRasterLayersOnStartUp() -> [MalinkiConfigurationMapData] {
        return self.getRasterLayers(of: self.getIDOfMapThemeOnStartUp())
    }
    
    /// This function returns an array of all layers of the given map theme.
    /// - Parameter mapTheme: the id of the map theme
    /// - Returns: an array of MalinkiMapLayer with all layers of the given map theme
    func getMapLayers(of mapTheme: Int) -> [MalinkiLayer] {
        var mapLayers: [MalinkiLayer] = []
        mapLayers.append(contentsOf: self.getRasterLayers(of: mapTheme).map({MalinkiLayer(id: $0.id, name: self.getExternalLayerName(themeID: mapTheme, layerID: $0.id), imageName: $0.imageName, themeID: mapTheme)}))
        return mapLayers
    }
    
    /// This function returns a dictionary of all layers.
    /// The ID of the map themes are the keys, the correspdoning map layers as an array are the values.
    /// - Returns: a dictionary containing all layers and their corresponding map themes
    func getAllMapLayersDictionary() -> [Int: [MalinkiLayer]] {
        var mapLayers: [Int: [MalinkiLayer]] = [:]
        mapLayers = self.getMapThemes().map({$0.id}).reduce(into: [:], {result, next in result[next] = self.getMapLayers(of: next)})
        return mapLayers
    }
    
    /// This function returns all raster layers, sorted by their ID.
    /// - Returns: an array of all layers
    func getAllMapLayersArray() -> [MalinkiLayer] {
        let layers = self.getAllMapLayersDictionary().map({$0.value})
        return layers.flatMap({$0}).sorted(by: {$0.id > $1.id})
    }
    
    /// This function returns the IDs of all raster layers of a given map theme.
    /// - Parameter mapTheme: the ID of the map theme
    /// - Returns: an array of IDs
    func getSortedRasterLayerIDs(of mapTheme: Int) -> [Int] {
        return self.configData?.mapThemes.filter({$0.id == mapTheme}).first?.layers.rasterLayers.map({$0.id}).sorted(by: {$0 < $1}) ?? []
    }
    
    /// This function returns a specific raster layer.
    /// - Parameters:
    ///   - layerID: the ID of the needed layer
    ///   - mapTheme: the ID of the corresponding map theme
    /// - Returns: an object of MalinkiConfigurationMapData
    func getRasterLayer(with layerID: Int, of mapTheme: Int) -> MalinkiConfigurationMapData? {
        return self.configData?.mapThemes.filter({$0.id == mapTheme}).first?.layers.rasterLayers.filter({$0.id == layerID}).first
    }
    
    func getAllMapThemes() -> [MalinkiTheme] {
        return self.configData?.mapThemes.map({MalinkiTheme(themeID: $0.id)}) ?? []
    }
    
    func getVectorLayer(id: Int, theme: Int) -> MalinkiConfigurationVectorData? {
        return self.getMapTheme(for: theme)?.layers.vectorLayers.filter({$0.id == id}).first
    }
    
    func getExternalVectorName(id: Int, theme: Int) -> String {
        return self.getVectorLayer(id: id, theme: theme)?.externalNames.en ?? ""
    }
    
    func getAllVectorLayers(for mapTheme: Int) -> [MalinkiConfigurationVectorData] {
        return self.getMapTheme(for: mapTheme)?.layers.vectorLayers ?? []
    }
    
    func getExternalThemeName(id: Int) -> String {
        return self.getMapTheme(for: id)?.externalNames.en ?? ""
    }
    
    func getExternalLayerName(themeID: Int, layerID: Int) -> String {
        return self.getRasterLayer(with: layerID, of: themeID)?.externalNames.en ?? ""
    }
    
}
