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
    private let tmsConverter: MalinkiTMSConverter = MalinkiTMSConverter()
    
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
    
    public override func url(forTilePath path: MKTileOverlayPath) -> URL {
        
        //get latitude and longitude in EPSG:4326
        //BE AWARE: in EPSG:4326 the x-value represents the latitude and the y-value represents the longitude
        var yMin = self.tmsConverter.longitudeOfColumn(column: path.x, zoom: path.z)
        var yMax = self.tmsConverter.longitudeOfColumn(column: path.x+1, zoom: path.z)
        var xMin = self.tmsConverter.latitudeOfRow(row: path.y+1, zoom: path.z)
        var xMax = self.tmsConverter.latitudeOfRow(row: path.y, zoom: path.z)
        
        //if EPSG:3857 is used
        if self.useMercator {
            //caching of the precalculated values
            let lonMin = yMin
            let lonMax = yMax
            let latMin = xMin
            let latMax = xMax
            
            //x and y will be flipped, because of the order of coordinates in EPSG: 3857:
            //x = easting, y = northing
            xMin = self.tmsConverter.mercatorXofLongitude(lon: lonMin)
            xMax = self.tmsConverter.mercatorXofLongitude(lon: lonMax)
            yMin = self.tmsConverter.mercatorYofLatitude(lat: latMin)
            yMax = self.tmsConverter.mercatorYofLatitude(lat: latMax)
        }
        
        let resolvedUrl = "\(self.url)" + "&BBOX=\(xMin),\(yMin),\(xMax),\(yMax)"
        
        return URL(string: resolvedUrl)!
    }
    
}
