//
//  MalinkiFeatureDataContainer.swift
//  Malinki
//
//  Created by Christoph Jung on 21.12.21.
//

import Foundation
import MapKit
import SwiftUI
import SWXMLHash

@available(iOS 15.0, *)
@MainActor
/// This class is a container for feature data, including geometries and attribute data, that should be displayed in a map view.
public class MalinkiFeatureDataContainer: MalinkiVectorData, ObservableObject {
    
    @Published public var featureData: [MalinkiFeatureData] = []
    @Published public var geometries: [MalinkiVectorGeometry] = []
    public var selectedAnnotation: MalinkiAnnotation? = nil
    public var span: MKCoordinateSpan? = nil
    private var gmlGeometries: [XMLIndexer] = []
    
    /// This function clears all instant vars.
    public func clearAll() {
        self.featureData = []
        self.geometries = []
        self.selectedAnnotation = nil
        self.span = nil
    }
    
    /// This function is the main entry point for querying feature data, no matter of the data source.
    public func getFeatureData() {
        //clear the current data
        self.featureData = []
        
        //different behaviour for user annotations
        if self.selectedAnnotation?.isUserAnnotation ?? false {
            //get all feature layers of the map theme
            let featureLayers = MalinkiConfigurationProvider.sharedInstance.getAllVectorLayers(for: self.selectedAnnotation?.themeID ?? -99)
            
            //check the count of feature layers
            if featureLayers.count == 0 {
                self.addFeature(name: self.selectedAnnotation?.title ?? "", data: [String(localized: "Result"): String(localized: "No data to query")])
            } else {
                //iterate over all layers and start the data query
                for layer in featureLayers {
                    self.getFeatureData(for: layer.featureInfo)
                }
            }
            
        } else {
            //get the layer data from the config file
            let featureLayer = MalinkiConfigurationProvider.sharedInstance.getVectorLayer(id: self.selectedAnnotation?.layerID ?? 0, theme: self.selectedAnnotation?.themeID ?? 0)
            let featureInfo = featureLayer?.featureInfo
            
            //get the feature data for this layer
            self.getFeatureData(for: featureInfo)
        }
    }
    
    /// This function starts the data query.
    /// - Parameter featureInfo: an config object with all necesary data to query the data
    private func getFeatureData(for featureInfo: MalinkiConfigurationVectorFeatureInfo?) {
        
       if let wfs = featureInfo?.wfs {
            self.getFeature(config: wfs)
        } else if let wms = featureInfo?.wms {
            self.getFeatureInfo(config: wms)
        } else if let localFile = featureInfo?.localFile {
            self.getLocalFeatureData(from: localFile)
        } else if let remoteFile = featureInfo?.remoteFile {
            self.getRemoteFeatureData(from: remoteFile)
        }
        
    }
    
    /// This function queries data from a GeoJSON file on a remote storage using http. The data will be stored in a published instance var.
    /// - Parameter urlAsString: the url of the remote file
    private func getRemoteFeatureData(from urlAsString: String) {
        Task {
            //fetch data
            let data = try await self.fetchData(from: urlAsString)
            
            //decode the data
            let json = self.decodeGeoJSON(from: data)
            
            //get features from json string
            await self.getFeatureData(name: self.selectedAnnotation?.title ?? "", from: json, filterField: MalinkiConfigurationProvider.sharedInstance.getVectorLayer(id: self.selectedAnnotation?.layerID ?? -99, theme: self.selectedAnnotation?.themeID ?? -99)?.attributes.id, filterValue: self.selectedAnnotation?.featureID)
        }
    }
    
    /// This function queries data from a GeoJSON file on the local device. The data will be stored in a published instance var.
    /// - Parameter path: the path to the file excluding the file extension
    private func getLocalFeatureData(from path: String) {
        Task {
            //get the data of the geojson file
            let data = self.getLocalData(from: path)
            
            //decode the data
            let json = self.decodeGeoJSON(from: data)
            
            //get features from json string
            await self.getFeatureData(name: self.selectedAnnotation?.title ?? "", from: json, filterField: MalinkiConfigurationProvider.sharedInstance.getVectorLayer(id: self.selectedAnnotation?.layerID ?? -99, theme: self.selectedAnnotation?.themeID ?? -99)?.attributes.id, filterValue: self.selectedAnnotation?.featureID)
        }
    }
    
    /// This function queries data from a WMS using GetFeatureInfo-request. The data will be stored in a published instance var.
    /// - Parameter config: the wms config
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
            let coordinateConverter = MalinkiCoordinatesConverter.sharedInstance
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
                    self.addFeature(name: selectedAnnotation?.title ?? "", data: [String(localized: "Data"): text])
                }
                
            } catch {
                self.addFeature(name: selectedAnnotation?.title ?? "", data: [String(localized: "Error"): String(localized: "not able to get data from webservice")])
            }
        }
    }
    
    /// This function adds a single feature to a published instance var.
    /// - Parameters:
    ///   - name: the name of the feature
    ///   - data: the attribute data stored in a dictionary
    private func addFeature(name: String, data: [String: String]) {
        self.featureData.append(MalinkiFeatureData(data: data, name: name))
    }
    
    /// This function filters given features and stores them in a published instance var.
    /// - Parameters:
    ///   - name: the name of the feature
    ///   - geojsonFeatures: the previously queried GeoJSON features
    ///   - filterField: the name of the field to filter on
    ///   - filterValue: the value of the filter
    private func getFeatureData(name: String, from geojsonFeatures: [MKGeoJSONFeature], filterField: String? = nil, filterValue: String? = nil) async {
        //pass an information to the user, if the query returned no data
        if geojsonFeatures.count == 0 {
            self.addFeature(name: name, data: [String(localized: "Result"): String(localized: "No Data")])
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
                    if let fieldName = filterField, let fieldValue = filterValue, let propertyValues = property {
                        continueLoop = self.createStringValue(from: propertyValues[fieldName] as Any) != fieldValue
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
    
    /// This function queries data from a WFS using a GetFeatures-request. The data will be stored in a published instance var.
    /// - Parameter config: the wfs config
    private func getFeature(config: MalinkiConfigurationWFS) {
        Task {
            if let annotation = self.selectedAnnotation {
                //get the config of the current vector layer
                let vectorDataConfig = MalinkiConfigurationProvider.sharedInstance.getVectorLayer(id: annotation.layerID, theme: annotation.themeID)
                
                //create request
                let wfsRequest = self.createWFSGetFeatureRequest(from: config)
                
                //create the filter parameter
                let filter = "<fes:Filter xmlns:fes=\"http://www.opengis.net/fes/2.0\" xmlns:gml=\"http://www.opengis.net/gml/3.2\"><fes:And><fes:PropertyIsEqualTo><fes:PropertyName>\(MalinkiConfigurationProvider.sharedInstance.getVectorLayer(id: annotation.layerID, theme: annotation.themeID)?.attributes.id ?? "")</fes:PropertyName><fes:Literal>\(annotation.featureID)</fes:Literal></fes:PropertyIsEqualTo></fes:And></fes:Filter>"
                
                //query data from WFS
                let data = try await self.fetchData(from: "\(wfsRequest)&FILTER=\(filter)")
                
                //parse the server response
                let gml = self.decodeGML(from: data)
                
                //get the geometry name
                let geomName = vectorDataConfig?.attributes.geometry ?? ""
                
                //check for features in the response
                let members = gml["wfs:FeatureCollection"]["wfs:member"].all
                if members.count == 0 {
                    self.addFeature(name: annotation.title ?? "", data: [String(localized: "Result"): String(localized: "No Data")])
                } else {
                    for member in members {
                        //init an array to store the attribute data
                        var properties: [String: String] = [:]
                        
                        for child in member.children {
                            
                            for gmlData in child.children {
                                //get the name of the current node
                                let nodeName = gmlData.element?.name ?? ""
                                
                                //get the attribute data
                                if nodeName != "gml:boundedBy" && nodeName != geomName {
                                    properties[nodeName] = gmlData.element?.text
                                }
                            }
                            
                            //empty exisiting gml geometries
                            self.gmlGeometries = []
                            
                            //search for polygons
                            let geomNode = child[geomName]
                            self.getPolgyonFromGML(geomNode: geomNode)
                            
                            //start search for linestring if necessary, i.e. the previous search for polygons was not successfull
                            if self.gmlGeometries.count == 0 {
                                self.getLinestringFromGML(geomNode: geomNode)
                                
                                //extract linestring
                                let polylineArray = self.gmlGeometries.map({ linestring -> MKPolyline in
                                    //get locations from the posList
                                    let locationArray = self.getLocationsFromPosList(xmlElement: linestring["gml:posList"].element)
                                    
                                    //create a MKPolyline
                                    return MKPolyline(coordinates: locationArray, count: locationArray.count)
                                })
                                
                                //add the geometry to the class var
                                self.geometries.append(MalinkiVectorGeometry(mapThemeID: annotation.themeID, layerID: annotation.layerID, geometry: MKMultiPolyline(polylineArray)))
                            } else {
                                //extract polygon
                                var polygonArray: [MKPolygon] = []
                                
                                
                                for polygon in self.gmlGeometries {
                                    //get the boundary of the poylgon
                                    let boundary = self.getLocationsFromPosList(xmlElement: polygon["gml:exterior"]["gml:LinearRing"]["gml:posList"].element)
                                    
                                    //get all inner rings
                                    let innerPolygons = polygon["gml:interior"].all.map({interior -> MKPolygon in
                                        let islandLocationArray = self.getLocationsFromPosList(xmlElement: interior["gml:LinearRing"]["gml:posList"].element)
                                        return MKPolygon(coordinates: islandLocationArray, count: islandLocationArray.count)
                                    })
                                    
                                    //create a new polygon
                                    polygonArray.append(MKPolygon(coordinates: boundary, count: boundary.count, interiorPolygons: innerPolygons))
                                }
                                
                                //add the geometry to the class var
                                self.geometries.append(MalinkiVectorGeometry(mapThemeID: annotation.themeID, layerID: annotation.layerID, geometry: MKMultiPolygon(polygonArray)))
                            }
                        }
                        
                        //insert the attribute data
                        self.addFeature(name: annotation.title ?? "", data: properties)
                    }
                }
            }
        }
        
    }
    
    /// This function extracts the spatial information from the GML-element posList.
    /// - Parameter xmlElement: the posList xml element
    /// - Returns: an array of locations
    private func getLocationsFromPosList(xmlElement: XMLElement?) -> [CLLocationCoordinate2D] {
        //init result var
        var locationArray: [CLLocationCoordinate2D] = []
        
        guard let posList = xmlElement else {
            return locationArray
        }
        
        let coords = posList.text.split(separator: " ")
        var counter = 1
        
        //create locations from the posList
        while counter < coords.count {
            locationArray.append(CLLocationCoordinate2D(latitude: Double(coords[counter]) ?? -99.99, longitude: Double(coords[counter - 1]) ?? -99.99))
            counter += 2
        }
        
        return locationArray
    }
    
    /// This function searches the xml elements gml:Polygon in the given xml indexer. This function follows dynamic programming.
    /// - Parameter geomNode: the geometry GML node
    private func getPolgyonFromGML(geomNode: XMLIndexer) {
        for child in geomNode.children {
            
            if child.element?.name == "gml:Polygon" {
                self.gmlGeometries.append(child)
            } else {
                self.getPolgyonFromGML(geomNode: child)
            }
        }
    }
    /// This function searches the xml elements gml:LineString in the given xml indexer. This function follows dynamic programming.
    /// - Parameter geomNode: the geometry GML node
    private func getLinestringFromGML(geomNode: XMLIndexer) {
        for child in geomNode.children {
            
            if child.element?.name == "gml:LineString" {
                self.gmlGeometries.append(child)
            } else {
                self.getLinestringFromGML(geomNode: child)
            }
        }
    }
    
}
