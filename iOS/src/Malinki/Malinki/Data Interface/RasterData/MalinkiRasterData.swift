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
            overlay = MalinkiTileOverlay(urlTemplate: MalinkiSimpleDataConverter.sharedInstance.replaceTimePlaceholders(for: tms.url), alpha: CGFloat(self.mapDataConfiguration.opacity), subDirName: self.subDirName)
            overlay.isGeometryFlipped = tms.invertedYAxis
        } else if let wms = rasterTypes.wms {
            let url = (MalinkiSimpleDataConverter.sharedInstance.replaceTimePlaceholders(for: wms.baseURL) +
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
    
    /// This function returns the configuration of a map from apple.
    /// This function should be used to access the data of the current configuration object, if the property isAppleMaps is true.
    /// - Returns: the configuration of an MKMap
    func getAppleMapConfiguration() -> MKMapConfiguration {
        let appleMapsType = self.mapDataConfiguration.internalName
        let mapConfig: MKMapConfiguration
        
        switch appleMapsType {
        case "apple_roads":
            let standardMapConfig = MKStandardMapConfiguration(elevationStyle: .realistic, emphasisStyle: .default)
            standardMapConfig.showsTraffic = false
            standardMapConfig.pointOfInterestFilter = .excludingAll
            mapConfig = standardMapConfig
        case "apple_aerial":
            mapConfig = MKImageryMapConfiguration(elevationStyle: .realistic)
        case "apple_hybrid":
            let hybridMapConfig = MKHybridMapConfiguration(elevationStyle: .realistic)
            hybridMapConfig.showsTraffic = false
            hybridMapConfig.pointOfInterestFilter = .excludingAll
            mapConfig = hybridMapConfig
        default:
            let standardMapConfig = MKStandardMapConfiguration(elevationStyle: .realistic, emphasisStyle: .muted)
            standardMapConfig.showsTraffic = false
            standardMapConfig.pointOfInterestFilter = .excludingAll
            mapConfig = standardMapConfig
        }
        
        return mapConfig
    }
    
}
