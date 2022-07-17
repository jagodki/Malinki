//
//  MalinkiFeatureData.swift
//  Malinki
//
//  Created by Christoph Jung on 14.12.21.
//

import Foundation

/// A class describing the attribute data of a feature.
final public class MalinkiFeatureData: Identifiable {
    
    public var data: [String: String]
    public var name: String
    public let uuid: UUID
    public let themeID: Int
    public let vectorLayerID: Int
    
    /// The initiator of this class.
    /// - Parameters:
    ///   - data: a dictionary with the attribute data
    ///   - name: the name of the feature
    ///   - themeID: the ID of the corresponding theme
    ///   - name: the ID of the corresponding vector layer
    init(data: [String: String], name: String, themeID: Int, vectorLayerID: Int) {
        self.data = data
        self.name = name
        self.uuid = UUID()
        self.themeID = themeID
        self.vectorLayerID = vectorLayerID
    }
}
