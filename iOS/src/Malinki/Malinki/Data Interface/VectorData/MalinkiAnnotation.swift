//
//  MalinkiAnnotation.swift
//  Malinki
//
//  Created by Christoph Jung on 11.11.21.
//

import Foundation
import MapKit
import Combine

/// A class representing an annotation.
/// The class is extended by additional attributes to query the configuration.
class MalinkiAnnotation: NSObject, MKAnnotation, ObservableObject {
    
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    var themeID: Int
    var layerID: Int
    var featureID: Int
    
    init(title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D, themeID: Int, layerID: Int, featureID: Int) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.themeID = themeID
        self.layerID = layerID
        self.featureID = featureID
    }
    
}
