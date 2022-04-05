//
//  MalinkiVectorGeometry.swift
//  Malinki
//
//  Created by Christoph Jung on 17.11.21.
//

import Foundation
import MapKit

/// This function stores spatial data in MapKit types of any geometry type.
public class MalinkiVectorGeometry {
    
    enum GeometryType {
        case point
        case linestring
        case polygon
        case multilinestring
        case multipolygon
        case non
    }
    
    let type: GeometryType
    var mapThemeID: Int
    var layerID: Int
    var point: MKPointAnnotation = MKPointAnnotation()
    var linestring: MKPolyline = MKPolyline()
    var multiLinestring: MKMultiPolyline = MKMultiPolyline()
    var polygon: MKPolygon = MKPolygon()
    var multiPolygon: MKMultiPolygon = MKMultiPolygon()
    
    init(mapThemeID: Int, layerID: Int, geometry: MKShape) {
        self.mapThemeID = mapThemeID
        self.layerID = layerID
        
        //get the geometry type and the geometry itself
        if geometry is MKPointAnnotation {
            self.type = GeometryType.point
            self.point = (geometry as? MKPointAnnotation)!
        } else if geometry is MKPolygon {
            self.type = GeometryType.polygon
            self.polygon = (geometry as? MKPolygon)!
        } else if geometry is MKMultiPolygon {
            self.type = GeometryType.multipolygon
            self.multiPolygon = (geometry as? MKMultiPolygon)!
        } else if geometry is MKPolyline {
            self.type = GeometryType.linestring
            self.linestring = (geometry as? MKPolyline)!
        } else if geometry is MKMultiPolyline {
            self.type = GeometryType.multilinestring
            self.multiLinestring = (geometry as? MKMultiPolyline)!
        } else {
            self.type = GeometryType.non
            print("geometry error or no geometry")
        }
    }
    
}
