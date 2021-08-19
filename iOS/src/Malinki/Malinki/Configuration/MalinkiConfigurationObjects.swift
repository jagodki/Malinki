//
//  MalinkiConfigurationObjects.swift
//  Malinki
//
//  Created by Christoph Jung on 15.08.21.
//

import Foundation

struct MalinkiConfiguration: Decodable {
    var mapThemes: [MalinkiConfigurationTheme]
    var basemaps: [MalinkiConfigurationBasemap]
}

struct MalinkiConfigurationTheme: Decodable {
    var test: String
}

struct MalinkiConfigurationBasemap: Decodable {
    var id: Int
    var internalName: String
    var externalNames: MalinkiConfigurationExternalName
    var url: String
    var imageName: String
    var onStartUp: Bool
}

struct MalinkiConfigurationExternalName: Decodable {
    var en: String
    var de: String
    var fr: String
    var sv: String
    var pl: String
}
