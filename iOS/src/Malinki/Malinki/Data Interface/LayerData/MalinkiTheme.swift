//
//  MalinkiTheme.swift
//  Malinki
//
//  Created by Christoph Jung on 24.11.21.
//

import Foundation
import SwiftUI

/// A class representing the toggle status of a theme for displaying annotations.
final class MalinkiTheme: ObservableObject {
    
    var themeID: Int
    @Published var hasAnnotations: Bool
    @Published var annotationsAreToggled: Bool = true
    
    init(themeID: Int) {
        self.themeID = themeID
        let annotations = MalinkiConfigurationProvider.sharedInstance.getMapTheme(for: themeID)?.layers.vectorLayers.filter({$0.featureInfo != nil})
        self.hasAnnotations = (annotations?.count != 0)
    }
    
}
