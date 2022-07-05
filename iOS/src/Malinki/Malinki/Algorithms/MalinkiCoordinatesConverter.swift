//
//  MalinkiTMSConverter.swift
//  Malinki
//
//  Created by Christoph Jung on 12.12.21.
//

import Foundation
import MapKit

/// A struct containing functions for converting coordinates.
struct MalinkiCoordinatesConverter {
    
    private let radius: Double = 6378137.0; /* in meters on the equator */
    static let sharedInstance = MalinkiCoordinatesConverter()
    
    func longitudeOfColumn(column: Int, zoom: Int) -> Double {
        let x = Double(column)
        let z = Double(zoom)
        return x / pow(2.0, z) * 360.0 - 180
    }
    
    func latitudeOfRow(row: Int, zoom: Int) -> Double {
        let y = Double(row)
        let z = Double(zoom)
        let n = Double.pi - 2.0 * Double.pi * y / pow(2.0, z)
        return 180.0 / Double.pi * atan(0.5 * (exp(n) - exp(-n)))
    }
    
    func mercatorXofLongitude(lon: Double) -> Double {
        return lon * 20037508.34 / 180
    }

    func mercatorYofLatitude(lat: Double) -> Double {
        var y = log(tan((90 + lat) * Double.pi / 360)) / (Double.pi / 180)
        y = y * 20037508.34 / 180
        return y
    }
    
    func tileZ(zoomScale: MKZoomScale) -> Int {
        let numTilesAt1_0 = MKMapSize.world.width / 256.0
        let zoomLevelAt1_0 = log2(Float(numTilesAt1_0))
        let zoomLevel = max(0, zoomLevelAt1_0 + floor(log2f(Float(zoomScale)) + 0.5))
        return Int(zoomLevel)
    }
    
    func tileZ(rotation: Double, span: MKCoordinateSpan) -> Int {
        var angleCamera = rotation
        let screenFrame = UIScreen.main.bounds
        
        if angleCamera > 270 {
            angleCamera = 360 - angleCamera
        } else if angleCamera > 90 {
            angleCamera = Swift.abs(angleCamera - 80)
        }
        
        let angleRad = Double.pi * angleCamera / 180 // map rotation in radians
        let width = Double(screenFrame.width)
        let height = Double(screenFrame.height)
        let heightOffset : Double = 20
        
        let spanStraight = width * span.longitudeDelta / (width * cos(angleRad) + (height - heightOffset) * sin(angleRad))
        return Int(log2(360 * ((width / 128) / spanStraight)))
    }
    
    func latitudeOverSheet(for latitude: Double, with latitudeDelta: Double) -> Double {
        return latitude - latitudeDelta / 4
    }
    
    func latitudeUnderSheet(for latitude: Double, with latitudeDelta: Double) -> Double {
        return latitude + latitudeDelta / 4
    }
    
}

extension FloatingPoint {
    var degreesToRadians: Self { self * .pi / 180 }
    var radiansToDegrees: Self { self * 180 / .pi }
}
