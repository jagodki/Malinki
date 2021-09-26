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
    ///   - useMercator: true if service should be queried as web mercator
    ///   - wmsVersion: the version of the service
    ///   - alpha: the opacity of the received image for displaying
    init(url: String, useMercator: Bool, wmsVersion: String, alpha: CGFloat = 1.0) {
        self.url = url
        self.useMercator = useMercator
        self.wmsVersion = wmsVersion
        super.init(urlTemplate: url, alpha: alpha)
    }
    
    private func xOfColumn(column: Int, zoom: Int) -> Double {
        let x = Double(column)
        let z = Double(zoom)
        return x / pow(2.0, z) * 360.0 - 180
    }
    
    private func yOfRow(row: Int, zoom: Int) -> Double {
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
        var left = xOfColumn(column: path.x, zoom: path.z)
        var right = xOfColumn(column: path.x+1, zoom: path.z)
        var bottom = yOfRow(row: path.y+1, zoom: path.z)
        var top = yOfRow(row: path.y, zoom: path.z)
        if(useMercator){
            left   = mercatorXofLongitude(lon: left) // minX
            right  = mercatorXofLongitude(lon: right) // maxX
            bottom = mercatorYofLatitude(lat: bottom) // minY
            top    = mercatorYofLatitude(lat: top) // maxY
        }

        var resolvedUrl = "\(self.url)"
        if(wmsVersion.contains("1.3")) {
            resolvedUrl += "&BBOX=\(bottom),\(left),\(top),\(right)"
        } else {
            resolvedUrl += "&BBOX=\(left),\(bottom),\(right),\(top)"
        }

        return URL(string: resolvedUrl)!
    }
    
}
