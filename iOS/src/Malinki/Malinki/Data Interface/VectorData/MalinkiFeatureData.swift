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
    
    /// The initiator of this class.
    /// - Parameters:
    ///   - data: a dictionary with the attribute data
    ///   - name: the name of the feature
    init(data: [String: String], name: String) {
        self.data = data
        self.name = name
        self.uuid = UUID()
    }
}
