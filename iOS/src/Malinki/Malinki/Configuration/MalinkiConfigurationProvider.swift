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
        mapLayers.append(contentsOf: self.getRasterLayers(of: mapTheme).map({MalinkiLayer(id: $0.id, name: self.getExternalRasterLayerName(themeID: mapTheme, layerID: $0.id), imageName: $0.imageName, themeID: mapTheme)}))
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
    
    /// This function returns all themes from the config.
    /// - Returns: an array containing all map themes
    func getAllMapThemes() -> [MalinkiTheme] {
        return self.configData?.mapThemes.map({MalinkiTheme(themeID: $0.id)}) ?? []
    }
    
    /// This function returns the configuration of a vector layer.
    /// - Parameters:
    ///   - id: the ID of the vector layer
    ///   - theme: the ID of the correpsonding map theme
    /// - Returns: a configuration object for the given vector layer
    func getVectorLayer(id: Int, theme: Int) -> MalinkiConfigurationVectorData? {
        return self.getMapTheme(for: theme)?.layers.vectorLayers.filter({$0.id == id}).first
    }
    
    /// This function returns the external name of a given vector layer.
    /// - Parameters:
    ///   - id: the ID of the vector layer
    ///   - theme: the ID of the correpsonding map theme
    /// - Returns: a String with the external name of the layer
    func getExternalVectorName(id: Int, theme: Int) -> String {
        return self.getExternalNameForDeviceLanguage(externalNames: self.getVectorLayer(id: id, theme: theme)?.externalNames ?? MalinkiConfigurationExternalNames(en: "", de: "", fr: "", sv: "", pl: ""))
    }
    
    /// This function returns the external name depending on the device language
    /// - Parameter externalNames: the external names
    /// - Returns: a string of the external name for the current device language (or english as default)
    private func getExternalNameForDeviceLanguage(externalNames: MalinkiConfigurationExternalNames) -> String {
        var externalName: String = ""
        
        switch Locale.current.languageCode {
        case "en":
            externalName = externalNames.en
            break
        case "de":
            externalName = externalNames.de
            break
        case "fr":
            externalName = externalNames.fr
            break
        case "pl":
            externalName = externalNames.pl
            break
        case "sv":
            externalName = externalNames.sv
            break
        default:
            externalName = externalNames.en
            break
        }
        
        return externalName
    }
    
    /// This function returns all vector layers of a given map theme.
    /// - Parameter mapTheme: the ID of the map theme
    /// - Returns: an array of vector configuration objects
    func getAllVectorLayers(for mapTheme: Int) -> [MalinkiConfigurationVectorData] {
        return self.getMapTheme(for: mapTheme)?.layers.vectorLayers ?? []
    }
    
    /// This function returns the external name of a given map theme.
    /// - Parameter id: the ID of the map theme
    /// - Returns: a String with the external name of the theme
    func getExternalThemeName(id: Int) -> String {
        return self.getExternalNameForDeviceLanguage(externalNames: self.getMapTheme(for: id)?.externalNames ?? MalinkiConfigurationExternalNames(en: "", de: "", fr: "", sv: "", pl: ""))
    }
    
    /// This function returns the external name of a given raster layer.
    /// - Parameters:
    ///   - themeID: the ID of the map theme
    ///   - layerID: the ID of the raster layer
    /// - Returns: a String with the external name of the layer
    func getExternalRasterLayerName(themeID: Int, layerID: Int) -> String {
        return self.getExternalNameForDeviceLanguage(externalNames: self.getRasterLayer(with: layerID, of: themeID)?.externalNames ?? MalinkiConfigurationExternalNames(en: "", de: "", fr: "", sv: "", pl: ""))
    }
    
    /// This function returns the name of the cache.
    /// - Returns: a String containing the cache name
    func getCacheName() -> String {
        return self.configData?.cacheName ?? "TILE_CACHE"
    }
    
    /// This function returns a config object for the initial map position at app start.
    /// - Returns: the initial map position containing center, width and height
    func getInitialMapPosition() -> MalinkiConfigurationInitialMap {
        return self.configData?.onStartUp.initialMapPosition ?? MalinkiConfigurationInitialMap(longitude: 0.0, latitude: 0.0, longitudinalMeters: 1000000000.0, latitudinalMeters: 1000000000.0)
    }
    
    /// This function returns the configuration for the map constraints.
    /// - Returns: a config object containing the map constraints
    func getMapConstraints() -> MalinkiConfigurationMapConstraints {
        return self.configData?.mapConstraints ?? MalinkiConfigurationMapConstraints(scale: MalinkiConfigurationMapScaleConstraints(min: 1.0, max: 1000000000000000000.0))
    }
    
    /// Returns the information, whether in app purchases are enabled or not.
    /// - Returns: true if in app purchases are enabled
    func inAppPurchasesAreEnabled() -> Bool {
        return ((self.configData?.inAppPurchases) != nil)
    }
    
    /// This function returns the in app purches configuration.
    /// - Returns: an object containing the configuration for in app purchases
    func getInAppPurchasesConfig() -> MalinkiConfigurationInAppPurchases {
        return self.configData?.inAppPurchases ?? MalinkiConfigurationInAppPurchases(mapToolsProductID: "")
    }
    
    /// This function tells, whether the configuration file contains a support text for in-app purchases or not.
    /// - Returns: true if a support text is provided in the configuration
    func hasSupportText() -> Bool {
        return ((self.configData?.inAppPurchases?.supportText) != nil)
    }
    
    /// This function returns the support text in the current language of the device.
    /// - Returns: the support text in the current device language or in english, if device language is not supported by the app
    func getSupportText() -> String {
        var localSupportText: String = ""
        
        switch Locale.current.languageCode {
        case "en":
            localSupportText = self.configData?.inAppPurchases?.supportText?.en ?? ""
        case "de":
            localSupportText = self.configData?.inAppPurchases?.supportText?.de ?? ""
        case "fr":
            localSupportText = self.configData?.inAppPurchases?.supportText?.fr ?? ""
        case "pl":
            localSupportText = self.configData?.inAppPurchases?.supportText?.pl ?? ""
        case "sv":
            localSupportText = self.configData?.inAppPurchases?.supportText?.sv ?? ""
        default:
            localSupportText = self.configData?.inAppPurchases?.supportText?.en ?? ""
        }
        
        return localSupportText
    }
    
    /// This function returns an object containing information for getting the legend graphic.
    /// - Parameters:
    ///   - layerID: the ID of the layer
    ///   - mapTheme: the ID of the map theme
    /// - Returns: an object of type MalinkiConfigurationMapLegendeGraphic
    func getLegendGraphic(for layerID: Int, in mapTheme: Int) -> MalinkiConfigurationMapLegendeGraphic {
        return self.getRasterLayer(with: layerID, of: mapTheme)?.legendGraphic ?? MalinkiConfigurationMapLegendeGraphic()
    }
    
}
