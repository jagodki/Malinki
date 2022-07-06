//
//  MalinkiAnnotationView.swift
//  Malinki
//
//  Created by Christoph Jung on 15.11.21.
//

import Foundation
import MapKit
import SwiftUI


/// A class representing an annotation view.
/// The styling of the view will be taken from the underlying annotation.
class MalinkiAnnotationView: MKMarkerAnnotationView {
    
    override var annotation: MKAnnotation? {
        willSet {
            
            if (newValue as? MalinkiAnnotation) == nil {
                return
            } else {
                self.clusteringIdentifier = (newValue as? MalinkiAnnotation)?.subtitle
                
                let style = MalinkiConfigurationProvider.sharedInstance.getVectorLayer(id: (newValue as? MalinkiAnnotation)?.layerID ?? 0, theme: (newValue as? MalinkiAnnotation)?.themeID ?? 0)?.style.annotationStyle
                
                self.markerTintColor = UIColor(Color(style?.colour ?? "AccentColor"))
                self.glyphImage = UIImage(systemName: style?.glyph ?? "mappin.and.ellipse")
            }
        }
    }
}
