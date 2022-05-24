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
    var id: String
    var name: String
    var colour: String?
    var theme_id: Int
    var layer_ids: [Int]
    var show_annotations: Bool
    var map: MalinkiBookmarksMap
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
