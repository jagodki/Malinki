//
//  MalinkiBookmarksObjects.swift
//  Malinki
//
//  Created by Christoph Jung on 03.05.22.
//

import Foundation

//MARK: - Root Level
struct MalinkiBookmarksRoot: Codable {
    var bookmarks: [MalinkiBookmarksObject]
}

//MARK: - bookmark object
struct MalinkiBookmarksObject: Codable {
    var id: Int
    var name: String
    var colour: String
    var theme_id: Int
    var layer_ids: [Int]
}

//MARK: - map component of bookmarks
struct MalinkiBookmarksMap: Codable {
    var centre: MalinkiBookmarksMapCentre
    var span: MalinkiBookmarksMapSpan
}

struct MalinkiBookmarksMapCentre: Codable {
    var latitude: Double
    var longitude: Double
}

struct MalinkiBookmarksMapSpan: Codable {
    var delta_latitude: Double
    var delta_longitude: Double
}
