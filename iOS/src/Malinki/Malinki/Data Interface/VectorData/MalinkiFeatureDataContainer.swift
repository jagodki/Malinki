//
//  MalinkiFeatureDataContainer.swift
//  Malinki
//
//  Created by Christoph Jung on 21.12.21.
//

import Foundation
import MapKit
import SwiftUI

@available(iOS 15.0, *)
@MainActor
public class MalinkiFeatureDataContainer: MalinkiVectorData, ObservableObject {
    
    @Published public var featureData: [MalinkiFeatureData] = []
    @Published public var geometries: [MalinkiVectorGeometry] = []
    public var selectedAnnotation: MalinkiAnnotation? = nil
    public var span: MKCoordinateSpan? = nil
    
    public func clearAll() {
        self.featureData = []
        self.geometries = []
        self.selectedAnnotation = nil
        self.span = nil
    }
    
    public func getFeatureData() {
        //clear the current data
        self.featureData = []
        
        //get the layer data from the config file
        let featureLayer = MalinkiConfigurationProvider.sharedInstance.getVectorLayer(id: self.selectedAnnotation?.layerID ?? 0, theme: self.selectedAnnotation?.themeID ?? 0)
        let featureInfo = featureLayer?.featureInfo
        
        if let wfs = featureInfo?.wfs {
            print("wfs")
        } else if let wms = featureInfo?.wms {
            self.getFeatureInfo(config: wms)
        } else if let localFile = featureInfo?.localFile {
            self.getLocalFeatureData(from: localFile)
        } else if let remoteFile = featureInfo?.remoteFile {
            self.getRemoteFeatureData(from: remoteFile)
        }
        
    }
    
    private func getRemoteFeatureData(from urlAsString: String) {
        Task {
            //fetch data
            let data = try await self.fetchData(from: urlAsString)
            
            //decode the data
            let json = self.decodeGeoJSON(from: data)
            
            //get features from json string
            await self.getFeatureData(name: selectedAnnotation?.title ?? "", from: json, filterField: MalinkiConfigurationProvider.sharedInstance.getVectorLayer(id: self.selectedAnnotation?.layerID ?? -99, theme: self.selectedAnnotation?.themeID ?? -99)?.attributes.id, filterValue: self.selectedAnnotation?.featureID)
        }
    }
    
    private func getLocalFeatureData(from path: String) {
        Task {
            //get the data of the geojson file
            let data = self.getLocalData(from: path)
            
            //decode the data
            let json = self.decodeGeoJSON(from: data)
            
            //get features from json string
            await self.getFeatureData(name: selectedAnnotation?.title ?? "", from: json, filterField: MalinkiConfigurationProvider.sharedInstance.getVectorLayer(id: self.selectedAnnotation?.layerID ?? -99, theme: self.selectedAnnotation?.themeID ?? -99)?.attributes.id, filterValue: self.selectedAnnotation?.featureID)
        }
    }
    
    private func getFeatureInfo(config: MalinkiConfigurationVectorFeatureInfoWMS) {
        //get coordinates
        let coord = self.selectedAnnotation?.coordinate
        
        //get delta longitude
        let deltaLon = self.span?.longitudeDelta ?? 1.0
        
        //get screen width
        let screenWidth = UIScreen.main.bounds.width
        
        //get ration of lon and width
        let lonPerPoint = deltaLon / screenWidth
        
        //width of the image
        let width = 100.0
        var height = 100.0
        
        //BBOX is a square in EPSG:4326
        //get x-values of BBOX in EPSG:4326
        var x0 = (coord?.longitude ?? 0.0) - width / 2 * lonPerPoint
        var x1 = (coord?.longitude ?? 0.0) + width / 2 * lonPerPoint
        
        //get y-values of BBOX in EPSG:4326
        var y0 = (coord?.latitude ?? 0.0) - height / 2 * lonPerPoint
        var y1 = (coord?.latitude ?? 0.0) + height / 2 * lonPerPoint
        
        if config.crs == "EPSG:3857" {
            let coordinateConverter = MalinkiCoordinatesConverter()
            x0 = coordinateConverter.mercatorXofLongitude(lon: x0)
            x1 = coordinateConverter.mercatorXofLongitude(lon: x1)
            y0 = coordinateConverter.mercatorYofLatitude(lat: y0)
            y1 = coordinateConverter.mercatorYofLatitude(lat: y1)
            
            //get height in correct ratio, if coordinates are in webmercator
            height = height * (y1 - y0) / (x1 - x0)
        }
        
        //get tap position in points
        let i = Int(width / 2) + 1
        let j = Int(height / 2) + 1
        
        //create the bbox
        //change x and y for EPSG:4326 because of its definition (north, east, up)
        var bbox: String = "\(x0),\(y0),\(x1),\(y1)"
        if config.crs == "EPSG:4326" {
            bbox = "\(y0),\(x0),\(y1),\(x1)"
        }
        
        //create request
        let fc: String = String(config.featureCount)
        let request: String = (config.baseURL +
                               "SERVICE=WMS&REQUEST=GetFeatureInfo" +
                               "&VERSION=" + config.version +
                               "&BBOX=" + bbox +
                               "&CRS=" + config.crs +
                               "&WIDTH=" + String(Int(width) + 1) +
                               "&HEIGHT=" + String(Int(height) + 1) +
                               "&LAYERS=" + config.layers +
                               "&STYLES=" + config.styles +
                               "&FORMAT=" + config.format +
                               "&QUERY_LAYERS=" + config.queryLayers +
                               "&INFO_FORMAT=" + config.infoFormat +
                               "&I=" + String(i) +
                               "&J=" + String(j) +
                               "&FEATURE_COUNT=" + fc)
        
        //get data and parse it, depending on the info format
        Task {
            do {
                let data = try await self.fetchData(from: request)
                
                //parse data depending on info format
                if config.infoFormat == "application/json" {
                    
                    //get geojson object and its data
                    await self.getFeatureData(name: selectedAnnotation?.title ?? "", from: self.decodeGeoJSON(from: data))
                    
                } else if config.infoFormat == "text/plain" {
                    let text = String(data: data, encoding: .utf8) ?? ""
                    self.addFeature(name: selectedAnnotation?.title ?? "", data: ["Data": text])
                }
                
            } catch {
                self.addFeature(name: selectedAnnotation?.title ?? "", data: ["Error": "not able to get data from webservice"])
            }
        }
    }
    
    private func addFeature(name: String, data: [String: String]) {
        self.featureData.append(MalinkiFeatureData(data: data, name: name))
    }
    
    private func getFeatureData(name: String, from geojsonFeatures: [MKGeoJSONFeature], filterField: String? = nil, filterValue: Int? = nil) async {
        //pass an information to the user, if the query returned no data
        if geojsonFeatures.count == 0 {
            self.addFeature(name: name, data: ["Result": "No Data"])
        } else {
            //iterate over features
            for feature in geojsonFeatures {
                //get the properties as a dictionary
                if let properties = feature.properties {
                    var attributes: [String: String] = [:]

                    //get a dictionary from the json data
                    let property = try? JSONSerialization.jsonObject(with: properties) as? [String: Any]
                    
                    //investigate the feature regarding a possible given filter
                    var continueLoop = false
                    if let fieldName = filterField, let fieldValue = filterValue {
                        continueLoop = property?[fieldName] as! Int != fieldValue
                    }
                    if continueLoop {
                        continue
                    }
                    
                    //parsing all properties of the current feature
                    for (key, value) in property ?? ["": ""] {
                        attributes[key] = String(describing: value)
                    }

                    //add the feature to the feature data object
                    self.addFeature(name: name, data: attributes)
                }
                
                //get the geometry
                if let geometry = feature.geometry.first {
                    self.geometries.append(MalinkiVectorGeometry(mapThemeID: self.selectedAnnotation?.themeID ?? -99, layerID: self.selectedAnnotation?.layerID ?? -99, geometry: geometry))
                }
            }
        }
    }
}
