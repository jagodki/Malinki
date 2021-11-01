//
//  MalinkiSheetNavigator.swift
//  Malinki
//
//  Created by Christoph Jung on 31.10.21.
//

import Foundation
import SwiftUI
import Combine

class MalinkiSheetState<State>: ObservableObject {
    
    @Published var isShowing: Bool = false
    @Published var state: State? {
        didSet {
            self.isShowing = (state != nil)
        }
    }
}
