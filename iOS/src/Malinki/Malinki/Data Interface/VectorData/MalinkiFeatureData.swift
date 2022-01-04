//
//  MalinkiFeatureData.swift
//  Malinki
//
//  Created by Christoph Jung on 14.12.21.
//

import Foundation

final public class MalinkiFeatureData: Identifiable {
    
    public var data: [String: String]
    public var name: String
    public let uuid: UUID
    
    init(data: [String: String], name: String) {
        self.data = data
        self.name = name
        self.uuid = UUID()
    }
}
