//
//  MalinkiUserAnnotationsObjects.swift
//  Malinki
//
//  Created by Christoph Jung on 23.06.22.
//

import Foundation

struct MalinkiUserAnnotationsRoot: Codable {
    var user_annotations: [MalinkiUserAnnotation]
}

struct MalinkiUserAnnotation: Codable {
    var id: String
    var name: String
    var theme_ids: [Int]
    var position: MalinkiUserAnnotationsPosition
}

struct MalinkiUserAnnotationsPosition: Codable {
    var longitude: Double
    var latitude: Double
}
