//
//  MalinkiState.swift
//  Malinki
//
//  Created by Christoph Jung on 02.11.21.
//

import Foundation
import Combine

/// A class to store the state of a sheet.
class MalinkiSheet: ObservableObject {
    @Published var isShowing: Bool = false
    @Published var state: MalinkiSheetState? = nil {
        didSet {
            self.isShowing = (state != nil)
        }
    }
}

/// An enum with all states a sheet can have.
enum MalinkiSheetState {
    case basemaps
    case layers
    case details
    case search
}
