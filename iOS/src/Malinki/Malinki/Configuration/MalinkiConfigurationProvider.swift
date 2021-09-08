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
    
}
