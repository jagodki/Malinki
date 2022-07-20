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
    var mapConstraints: MalinkiConfigurationMapConstraints
    var cacheName: String
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
    var zConstraints: MalinkiConfigurationMapDataZConstraints
    var imageName: String
    var opacity: Double
}

struct MalinkiConfigurationMapDataZConstraints: Decodable {
    var min: Int
    var max: Int
}

struct MalinkiConfigurationMapLayers: Decodable {
    var vectorLayers: [MalinkiConfigurationVectorData]
    var rasterLayers: [MalinkiConfigurationMapData]
}

//MARK: - Vector Layers
struct MalinkiConfigurationVectorData: Decodable {
    var id: Int
    var internalName: String
    var externalNames: MalinkiConfigurationBasemapExternalName
    var correspondingRasterLayer: Int?
    var vectorTypes: MalinkiConfigurationVectorTypes
    var attributes: MalinkiConfigurationVectorAttributes
    var featureInfo: MalinkiConfigurationVectorFeatureInfo?
    var style: MalinkiConfigurationVectorStyle
}

struct MalinkiConfigurationVectorTypes: Decodable {
    var localFile: String?
    var remoteFile: String?
    var wfs: MalinkiConfigurationWFS?
}

struct MalinkiConfigurationVectorAttributes: Decodable {
    var id: String
    var title: String
    var geometry: String?
}

struct MalinkiConfigurationVectorFeatureInfo: Decodable {
    var wms: MalinkiConfigurationVectorFeatureInfoWMS?
    var wfs: MalinkiConfigurationWFS?
    var localFile: String?
    var remoteFile: String?
}

struct MalinkiConfigurationVectorFeatureInfoWMS: Decodable {
    var baseURL: String
    var version: String
    var crs: String
    var layers: String
    var styles: String
    var format: String
    var queryLayers: String
    var infoFormat: String
    var featureCount: Int
    var fields: [MalinkiConfigurationVectorFields]
}

struct MalinkiConfigurationVectorFields: Decodable {
    var name: String
    var externalNames: MalinkiConfigurationBasemapExternalName
}

struct MalinkiConfigurationVectorStyle: Decodable {
    var annotationStyle: MalinkiConfigurationVectorAnnotationStyle?
    var featureStyle: MalinkiConfigurationVectorFeatureStyle?
}

struct MalinkiConfigurationVectorAnnotationStyle: Decodable {
    var colour: String
    var glyph: String
}

struct MalinkiConfigurationVectorFeatureStyle: Decodable {
    var outline: MalinkiConfigurationVectorStyleOutline
    var fill: MalinkiConfigurationVectorStyleFill?
}

struct MalinkiConfigurationVectorStyleOutline: Decodable {
    var colour: String
    var width: Double
}

struct MalinkiConfigurationVectorStyleFill: Decodable {
    var colour: String
    var opacity: Double
}

//MARK: - Vector Types
struct MalinkiConfigurationWFS: Decodable {
    var baseURL: String
    var crs: String
    var typename: String
    var typenames: String
    var version: String
    var additionalParameters: String?
}

//MARK: - Raster Types
struct MalinkiConfigurationRasterType: Decodable {
    var tms: MalinkiConfigurationTMS?
    var wms: MalinkiConfigurationWMS?
    var wmts: MalinkiConfigurationWMTS?
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
}

struct MalinkiConfigurationWMTS: Decodable {
    var baseURL: String
    var layer: String
    var style: String
    var format: String
    var version: String
    var tileMatrixSet: String
}

//MARK: - External Representations
struct MalinkiConfigurationBasemapExternalName: Decodable {
    var en: String
    var de: String
    var fr: String
    var sv: String
    var pl: String
}

//MARK: - Configurations for app start
struct MalinkiConfigurationStartUp: Decodable {
    var theme: Int
    var basemap: Int
    var initialMapPosition: MalinkiConfigurationInitialMap
}

struct MalinkiConfigurationInitialMap: Decodable {
    var longitude: Double
    var latitude: Double
    var longitudinalMeters: Double
    var latitudinalMeters: Double
}

//MARK: - Map Constraints
struct MalinkiConfigurationMapConstraints: Decodable {
    var scale: MalinkiConfigurationMapScaleConstraints
    var region: MalinkiConfigurationRegionConstraints?
}

struct MalinkiConfigurationMapScaleConstraints: Decodable {
    var min: Double
    var max: Double
}

struct MalinkiConfigurationRegionConstraints: Decodable {
    var center: MalinkiConfigurationRegionCenterConstraints
    var latitudinalMeters: Double
    var longitudinalMeters: Double
}

struct MalinkiConfigurationRegionCenterConstraints: Decodable {
    var latitude: Double
    var longitude: Double
}
