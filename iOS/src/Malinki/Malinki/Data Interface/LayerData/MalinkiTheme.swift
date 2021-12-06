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
    
    let themeID: Int
    @Published var annotationsAreToggled: Bool = true
    
    init(themeID: Int) {
        self.themeID = themeID
    }
    
}
