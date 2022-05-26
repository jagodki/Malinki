//
//  MalinkiMapRegion.swift
//  Malinki
//
//  Created by Christoph Jung on 26.05.22.
//

import Foundation
import SwiftUI
import MapKit

class MalinkiMapRegion: ObservableObject {
    
    @Published var mapRegion: MKCoordinateRegion
    
    init(mapRegion: MKCoordinateRegion) {
        self.mapRegion = mapRegion
    }
    
}
