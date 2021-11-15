//
//  MalinkiAnnotation.swift
//  Malinki
//
//  Created by Christoph Jung on 11.11.21.
//

import Foundation
import MapKit
import Combine

class MalinkiAnnotation: NSObject, MKAnnotation, ObservableObject {
    
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
    
}
