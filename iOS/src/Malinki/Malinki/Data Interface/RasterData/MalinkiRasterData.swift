//
//  MalinkiRasterData.swift
//  Malinki
//
//  Created by Christoph Jung on 23.08.21.
//

import Foundation
import MapKit

/// A structure to provide raster data, i.e. prerendered maps.
struct MalinkiRasterData {
    
    private var mapDataConfiguration: MalinkiConfigurationMapData
    
    /// The initialiser of this class.
    /// - Parameter mapDataConfiguration: a configuration object for map data
    init(from mapDataConfiguration: MalinkiConfigurationMapData) {
        self.mapDataConfiguration = mapDataConfiguration
    }
    
    /// This property returns true, if the current configuration object provides a map from apple, otherwise false.
    var isAppleMaps: Bool {
        return self.mapDataConfiguration.rasterTypes.apple
    }
    
    private var subDirName: String {
        return "\(String(self.mapDataConfiguration.id))-\(self.mapDataConfiguration.internalName.replacingOccurrences(of: " ", with: "_"))"
    }
    
    /// This function returns an object of MKTileOverlay for displaying raster data in an MKMapView.
    /// This function should be used to access the data of the current configuration object, if the property isAppleMaps is false.
    /// - Returns: an object of the type MKTIleOverlay
    func getOverlay() -> MKTileOverlay {
        let rasterTypes = self.mapDataConfiguration.rasterTypes
        var overlay: MKTileOverlay
        
        if let tms = rasterTypes.tms {
            overlay = MalinkiTileOverlay(urlTemplate: self.replaceTimePlaceholders(for: tms.url), alpha: CGFloat(self.mapDataConfiguration.opacity), subDirName: self.subDirName)
            overlay.isGeometryFlipped = tms.invertedYAxis
        } else if let wms = rasterTypes.wms {
            let url = (self.replaceTimePlaceholders(for: wms.baseURL) +
                        "SERVICE=WMS&REQUEST=GetMap&TRANSPARENT=True" +
                        "&VERSION=" + wms.version +
                        "&CRS=" + wms.crs +
                        "&FORMAT=" + wms.format +
                        "&LAYERS=" + wms.layers +
                        "&STYLES=" + wms.styles +
                        "&HEIGHT=" + wms.height +
                        "&WIDTH=" + wms.width)
            overlay = MalinkiWMSOverlay(url: url, useMercator: wms.crs == "EPSG:3857", wmsVersion: wms.version, alpha: CGFloat(self.mapDataConfiguration.opacity), subDirName: self.subDirName)
        } else if let wmts = rasterTypes.wmts {
            let url = (wmts.baseURL +
                        "SERVICE=WMTS&REQUEST=GetTile" +
                        "&VERSION=" + wmts.version +
                        "&FORMAT=" + wmts.format +
                        "&LAYER=" + wmts.layer +
                        "&STYLE=" + wmts.style +
                        "&TILEMATRIXSET=" + wmts.tileMatrixSet)
            overlay = MalinkiWMTSOverlay(url: url, alpha: CGFloat(self.mapDataConfiguration.opacity), subDirName: self.subDirName)
        } else {
            overlay = MKTileOverlay()
        }
        
        //constraints on zoom level
        overlay.minimumZ = self.mapDataConfiguration.zConstraints.min
        overlay.maximumZ = self.mapDataConfiguration.zConstraints.max
        
        return overlay
    }
    
    /// This function replaces placeholders for time with the current timestamp.
    /// - Parameter text: the text containing placeholders
    /// - Returns: a text without placeholders
    private func replaceTimePlaceholders(for text: String) -> String {
        //get the current timestamp and its components
        let timestamp = Calendar(identifier: .gregorian).dateComponents([.year, .month, .day, .hour, .minute, .second], from: .now)
        let year = String(timestamp.year ?? 2000)
        let month = String(timestamp.month ?? 1)
        let day = String(timestamp.day ?? 1)
        let hours = String(timestamp.hour ?? 0)
        let minutes = String(timestamp.minute ?? 0)
        let seconds = String(timestamp.second ?? 0)
        
        //replace placeholders
        let textWithYear = text.replacingOccurrences(of: "{YYYY}", with: year)
        let textWithMonth = textWithYear.replacingOccurrences(of: "{MM}", with: month.count == 1 ? "0\(month)" : month)
        let textWithDay = textWithMonth.replacingOccurrences(of: "{DD}", with: day.count == 1 ? "0\(day)" : day)
        let textWithHours = textWithDay.replacingOccurrences(of: "{hh}", with: hours.count == 1 ? "0\(hours)" : hours)
        let textWithMinutes = textWithHours.replacingOccurrences(of: "{mm}", with: minutes.count == 1 ? "0\(minutes)" : minutes)
        let textWithSeconds = textWithMinutes.replacingOccurrences(of: "{ss}", with: seconds.count == 1 ? "0\(seconds)" : seconds)
        
        return textWithSeconds
    }
    
    /// This function returns the type of a map from apple.
    /// This function should be used to access the data of the current configuration object, if the property isAppleMaps is true.
    /// - Returns: the type of an MKMap
    func getAppleMapType() -> MKMapType {
        let appleMapsType = self.mapDataConfiguration.internalName
        let mapType: MKMapType
        
        switch appleMapsType {
        case "apple_roads":
            mapType = MKMapType.standard
        case "apple_aerial":
            mapType = MKMapType.satellite
        case "apple_hybrid":
            mapType = MKMapType.hybrid
        default:
            mapType = MKMapType.mutedStandard
        }
        
        return mapType
    }
    
}
