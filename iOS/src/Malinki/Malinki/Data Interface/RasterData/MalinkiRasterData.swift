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
    
    /// This function returns an object of MKTileOverlay for displaying raster data in an MKMapView.
    /// This function should be used to access the data of the current configuration object, if the property isAppleMaps is false.
    /// - Returns: an object of the type MKTIleOverlay
    func getOverlay() -> MKTileOverlay {
        let rasterTypes = self.mapDataConfiguration.rasterTypes
        var overlay: MKTileOverlay
        
        if let tms = rasterTypes.tms {
            overlay = MalinkiTileOverlay(urlTemplate: tms.url, alpha: CGFloat(self.mapDataConfiguration.opacity))
            overlay.isGeometryFlipped = tms.invertedYAxis
        } else if let wms = rasterTypes.wms {
            let url = (wms.baseURL +
                        "SERVICE=WMS&REQUEST=GetMap&TRANSPARENT=True" +
                        "&VERSION=" + wms.version +
                        "&CRS=" + wms.crs +
                        "&FORMAT=" + wms.format +
                        "&LAYERS=" + wms.layers +
                        "&STYLES=" + wms.styles +
                        "&HEIGHT=" + wms.height +
                        "&WIDTH=" + wms.width)
            overlay = MalinkiWMSOverlay(url: url, useMercator: wms.crs == "EPSG:3857", wmsVersion: wms.version, alpha: CGFloat(self.mapDataConfiguration.opacity))
        } else if let wmts = rasterTypes.wmts {
            let url = (wmts.baseURL +
                        "SERVICE=WMTS&REQUEST=GetTile" +
                        "&VERSION=" + wmts.version +
                        "&FORMAT=" + wmts.format +
                        "&LAYER=" + wmts.layer +
                        "&STYLE=" + wmts.style +
                        "&TILEMATRIXSET=" + wmts.tileMatrixSet)
            overlay = MalinkiWMTSOverlay(url: url, alpha: CGFloat(self.mapDataConfiguration.opacity))
        } else {
            overlay = MKTileOverlay()
        }
        
        return overlay
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
