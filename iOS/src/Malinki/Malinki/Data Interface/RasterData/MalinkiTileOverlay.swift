//
//  MalinkiTileOverlay.swift
//  Malinki
//
//  Created by Christoph Jung on 06.09.21.
//

import Foundation
import MapKit

public class MalinkiTileOverlay: MKTileOverlay {
    
    var alpha: CGFloat = 1.0
    
    init(urlTemplate: String?, alpha: CGFloat = 1.0) {
        self.alpha = alpha
        super.init(urlTemplate: urlTemplate)
    }
}
