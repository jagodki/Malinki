//
//  MalinkiAnnotationView.swift
//  Malinki
//
//  Created by Christoph Jung on 15.11.21.
//

import Foundation
import MapKit

class MalinkiAnnotationView: MKMarkerAnnotationView {
    
    override var annotation: MKAnnotation? {
        willSet {
            if (newValue as? MalinkiAnnotation) == nil {
                return
            }
        }
    }
}
