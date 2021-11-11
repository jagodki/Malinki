//
//  MalinkiTileOverlay.swift
//  Malinki
//
//  Created by Christoph Jung on 23.08.21.
//

import Foundation
import MapKit

/// A class for loading a WMS as a MKTileOverlay.
public class MalinkiWMSOverlay: MalinkiTileOverlay {
    
    private var url: String
    private var useMercator: Bool
    private let wmsVersion: String
    
    /// The initialiser of this class
    /// - Parameters:
    ///   - url: the base URL of the service without any parameters
    ///   - useMercator: true if service should be queried as web mercator, i.e. EPSG:3857
    ///   - wmsVersion: the version of the service
    ///   - alpha: the opacity of the received image for displaying
    init(url: String, useMercator: Bool, wmsVersion: String, alpha: CGFloat = 1.0) {
        self.url = url
        self.useMercator = useMercator
        self.wmsVersion = wmsVersion
        super.init(urlTemplate: url, alpha: alpha)
    }
    
    private func longitudeOfColumn(column: Int, zoom: Int) -> Double {
        let x = Double(column)
        let z = Double(zoom)
        return x / pow(2.0, z) * 360.0 - 180
    }
    
    private func latitudeOfRow(row: Int, zoom: Int) -> Double {
        let y = Double(row)
        let z = Double(zoom)
        let n = Double.pi - 2.0 * Double.pi * y / pow(2.0, z)
        return 180.0 / Double.pi * atan(0.5 * (exp(n) - exp(-n)))
    }
    
    private func mercatorXofLongitude(lon: Double) -> Double {
        return lon * 20037508.34 / 180
    }

    private func mercatorYofLatitude(lat: Double) -> Double {
        var y = log(tan((90 + lat) * Double.pi / 360)) / (Double.pi / 180)
        y = y * 20037508.34 / 180
        return y
    }
    
    private func tileZ(zoomScale: MKZoomScale) -> Int {
        let numTilesAt1_0 = MKMapSize.world.width / 256.0
        let zoomLevelAt1_0 = log2(Float(numTilesAt1_0))
        let zoomLevel = max(0, zoomLevelAt1_0 + floor(log2f(Float(zoomScale)) + 0.5))
        return Int(zoomLevel)
    }
    
    public override func url(forTilePath path: MKTileOverlayPath) -> URL {
        
        //get latitude and longitude in EPSG:4326
        //BE AWARE: in EPSG:4326 the x-value represents the latitude and the y-value represents the longitude
        var yMin = longitudeOfColumn(column: path.x, zoom: path.z)
        var yMax = longitudeOfColumn(column: path.x+1, zoom: path.z)
        var xMin = latitudeOfRow(row: path.y+1, zoom: path.z)
        var xMax = latitudeOfRow(row: path.y, zoom: path.z)
        
        //if EPSG:3857 is used
        if self.useMercator {
            //caching of the precalculated values
            let lonMin = yMin
            let lonMax = yMax
            let latMin = xMin
            let latMax = xMax
            
            //x and y will be flipped, because of the order of coordinates in EPSG: 3857:
            //x = easting, y = northing
            xMin = mercatorXofLongitude(lon: lonMin)
            xMax = mercatorXofLongitude(lon: lonMax)
            yMin = mercatorYofLatitude(lat: latMin)
            yMax = mercatorYofLatitude(lat: latMax)
        }
        
        let resolvedUrl = "\(self.url)" + "&BBOX=\(xMin),\(yMin),\(xMax),\(yMax)"
        
        return URL(string: resolvedUrl)!
    }
    
}
