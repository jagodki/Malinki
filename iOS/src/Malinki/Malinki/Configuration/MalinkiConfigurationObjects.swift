//
//  MalinkiConfigurationObjects.swift
//  Malinki
//
//  Created by Christoph Jung on 15.08.21.
//

import Foundation

struct MalinkiConfiguration: Decodable {
    var mapThemes: [MalinkiConfigurationTheme]
    var basemaps: [MalinkiConfigurationMapData]
    var onStartUp: MalinkiConfigurationStartUp
}

struct MalinkiConfigurationTheme: Decodable {
    var test: String
}

struct MalinkiConfigurationMapData: Decodable {
    var id: Int
    var internalName: String
    var externalNames: MalinkiConfigurationBasemapExternalName
    var rasterTypes: MalinkiConfigurationRasterType
    var imageName: String
}

struct MalinkiConfigurationRasterType: Decodable {
    var tms: MalinkiConfigurationTMS?
    var wms: String?
    var wmts: String?
    var apple: Bool
}

struct MalinkiConfigurationTMS: Decodable {
    var url: String
}

struct MalinkiConfigurationBasemapExternalName: Decodable {
    var en: String
    var de: String
    var fr: String
    var sv: String
    var pl: String
}

struct MalinkiConfigurationStartUp: Decodable {
    var theme: Int
    var basemap: Int
}
