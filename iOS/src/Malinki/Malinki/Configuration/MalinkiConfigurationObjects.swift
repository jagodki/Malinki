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
}

struct MalinkiConfigurationTheme: Decodable {
    var test: String
}

struct MalinkiConfigurationMapData: Decodable {
    var id: Int
    var internalName: String
    var externalNames: MalinkiConfigurationBasemapExternalName
    var type: MalinkiConfigurationBasemapType
    var imageName: String
    var onStartUp: Bool
}

struct MalinkiConfigurationBasemapType: Decodable {
    var name: String
    var url: String
}

struct MalinkiConfigurationBasemapExternalName: Decodable {
    var en: String
    var de: String
    var fr: String
    var sv: String
    var pl: String
}
