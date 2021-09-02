//
//  MalinkiConfigurationObjects.swift
//  Malinki
//
//  Created by Christoph Jung on 15.08.21.
//

import Foundation

//MARK: - Root Level
struct MalinkiConfiguration: Decodable {
    var mapThemes: [MalinkiConfigurationTheme]
    var basemaps: [MalinkiConfigurationMapData]
    var onStartUp: MalinkiConfigurationStartUp
}

struct MalinkiConfigurationTheme: Decodable {
    var id: Int
    var internalName: String
    var externalNames: MalinkiConfigurationBasemapExternalName
    var iconName: String
    var layers: MalinkiConfigurationMapLayers
}

//MARK: - Map Data
struct MalinkiConfigurationMapData: Decodable {
    var id: Int
    var internalName: String
    var externalNames: MalinkiConfigurationBasemapExternalName
    var rasterTypes: MalinkiConfigurationRasterType
    var imageName: String
}

struct MalinkiConfigurationMapLayers: Decodable {
    var vectorLayers: String
    var rasterLayers: [MalinkiConfigurationMapData]
}

//MARK: - Raster Types
struct MalinkiConfigurationRasterType: Decodable {
    var tms: MalinkiConfigurationTMS?
    var wms: MalinkiConfigurationWMS?
    var wmts: String?
    var apple: Bool
}

struct MalinkiConfigurationTMS: Decodable {
    var url: String
    var invertedYAxis: Bool
}

struct MalinkiConfigurationWMS: Decodable {
    var baseURL: String
    var crs: String
    var layers: String
    var styles: String
    var format: String
    var version: String
    var width: String
    var height: String
    var opacity: Double
}

//MARK: - External Representations
struct MalinkiConfigurationBasemapExternalName: Decodable {
    var en: String
    var de: String
    var fr: String
    var sv: String
    var pl: String
}

//MARK: - Additional Configuration at Root Level
struct MalinkiConfigurationStartUp: Decodable {
    var theme: Int
    var basemap: Int
}
