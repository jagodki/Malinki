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
public class MalinkiAnnotation: NSObject, MKAnnotation, ObservableObject {
    
    public var title: String?
    public var subtitle: String?
    public var coordinate: CLLocationCoordinate2D
    public var themeID: Int
    public var layerID: Int
    public var featureID: String
    
    init(title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D, themeID: Int, layerID: Int, featureID: String) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.themeID = themeID
        self.layerID = layerID
        self.featureID = featureID
    }
    
}
