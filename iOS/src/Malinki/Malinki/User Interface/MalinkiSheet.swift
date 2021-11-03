//
//  MalinkiState.swift
//  Malinki
//
//  Created by Christoph Jung on 02.11.21.
//

import Foundation
import Combine

class MalinkiSheet: ObservableObject {
    @Published var isShowing: Bool = false
    @Published var state: MalinkiSheetState? = nil {
        didSet {
            self.isShowing = (state != nil)
        }
    }
}

enum MalinkiSheetState {
    case basemaps
    case layers
    case details
}
