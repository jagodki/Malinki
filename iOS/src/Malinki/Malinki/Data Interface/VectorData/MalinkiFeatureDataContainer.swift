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
    private let configProvider: MalinkiConfigurationProvider = MalinkiConfigurationProvider.sharedInstance
    
    /// This function clears all instant vars.
    public func clearAll() {
        self.featureData = []
        self.geometries = []
        self.selectedAnnotation = nil
        self.span = nil
    }
    
    /// This function is the main entry point for querying feature data, no matter of the data source.
    /// - Parameter toggledRasterLayerIDs: an array of IDs for all toggled, i.e. visible, raster layers
    public func getFeatureData(for toggledRasterLayerIDs: [Int] = []) {
        //clear the current data
        self.featureData = []
        
        //different behaviour for user annotations
        if self.selectedAnnotation?.isUserAnnotation ?? false {
            //get all feature layers of the visible raster layers of the map theme
            let featureLayers = self.configProvider.getAllVectorLayers(for: self.selectedAnnotation?.themeID ?? -99).filter({toggledRasterLayerIDs.contains($0.correspondingRasterLayer ?? -99) || $0.correspondingRasterLayer == nil})
            
            //check the count of feature layers
            if featureLayers.count == 0 {
                self.addFeature(name: self.selectedAnnotation?.title ?? "", themeID: selectedAnnotation?.themeID ?? -99, vectorLayerID: self.selectedAnnotation?.layerID ?? -99, data: [String(localized: "Result"): String(localized: "No data to query")])
            } else {
                //iterate over all layers and start the data query
                for layer in featureLayers {
                    self.getFeatureData(for: layer.featureInfo, with: layer.id)
                }
            }
            
        } else {
            //get the layer data from the config file
            if let featureLayer = self.configProvider.getVectorLayer(id: self.selectedAnnotation?.layerID ?? 0, theme: self.selectedAnnotation?.themeID ?? 0) {
                //get the feature data for this layer
                self.getFeatureData(for: featureLayer.featureInfo, with: featureLayer.id)
            }
        }
    }
    
    /// This function starts the data query.
    /// - Parameter featureInfo: an config object with all necesary data to query the data
    private func getFeatureData(for featureInfo: MalinkiConfigurationVectorFeatureInfo?, with id: Int) {
        
        if let wfs = featureInfo?.wfs {
            self.getFeature(config: wfs, layerID: id)
        } else if let wms = featureInfo?.wms {
            self.getFeatureInfo(config: wms, layerID: id)
        } else if let localFile = featureInfo?.localFile {
            self.getLocalFeatureData(from: localFile, layerID: id)
        } else if let remoteFile = featureInfo?.remoteFile {
            self.getRemoteFeatureData(from: remoteFile, layerID: id)
        }
        
    }
    
    /// This function queries data from a GeoJSON file on a remote storage using http. The data will be stored in a published instance var.
    /// - Parameters:
    ///   - urlAsString: the url of the remote file
    ///   - layerID: the id of the vector layer
    private func getRemoteFeatureData(from urlAsString: String, layerID: Int) {
        Task {
            //fetch data
            let data = try await self.fetchData(from: urlAsString)
            
            //decode the data
            let json = self.decodeGeoJSON(from: data)
            
            //get features from json string
            await self.getFeatureData(name: self.selectedAnnotation?.title ?? "", from: json, filterField: self.configProvider.getVectorLayer(id: layerID, theme: self.selectedAnnotation?.themeID ?? -99)?.attributes.id ?? "", filterValue: self.selectedAnnotation?.featureID ?? "", layerID: layerID)
        }
    }
    
    /// This function queries data from a GeoJSON file on the local device. The data will be stored in a published instance var.
    /// - Parameters:
    ///   - path: the path to the file excluding the file extension
    ///   - layerID: the id of the vector layer
    private func getLocalFeatureData(from path: String, layerID: Int) {
        Task {
            //get the data of the geojson file
            let data = self.getLocalData(from: path)
            
            //decode the data
            let json = self.decodeGeoJSON(from: data)
            
            //get features from json string
            await self.getFeatureData(name: self.selectedAnnotation?.title ?? "", from: json, filterField: self.configProvider.getVectorLayer(id: layerID, theme: self.selectedAnnotation?.themeID ?? -99)?.attributes.id ?? "", filterValue: self.selectedAnnotation?.featureID ?? "", layerID: layerID)
        }
    }
    
    /// This function queries data from a WMS using GetFeatureInfo-request. The data will be stored in a published instance var.
    /// - Parameters:
    ///   - config: the wms config
    ///   - layerID: tthe ID of the vector layer
    private func getFeatureInfo(config: MalinkiConfigurationVectorFeatureInfoWMS, layerID: Int) {
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
        let request: String = (MalinkiSimpleDataConverter.sharedInstance.replaceTimePlaceholders(for: config.baseURL) +
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
                if config.infoFormat == "application/json" || config.infoFormat == "application/geojson" {
                    
                    //get geojson object and its data
                    await self.getFeatureData(name: selectedAnnotation?.title ?? "", from: self.decodeGeoJSON(from: data), layerID: layerID)
                    
                } else if config.infoFormat == "text/plain" {
                    let text = String(data: data, encoding: .utf8) ?? ""
                    self.addFeature(name: selectedAnnotation?.title ?? "", themeID: selectedAnnotation?.themeID ?? -99, vectorLayerID: layerID, data: [String(localized: "Data"): text])
                }
                
            } catch {
                self.addFeature(name: selectedAnnotation?.title ?? "", themeID: selectedAnnotation?.themeID ?? -99, vectorLayerID: layerID, data: [String(localized: "Error"): String(localized: "not able to get data from webservice")])
            }
        }
    }
    
    /// This function adds a single feature to a published instance var.
    /// - Parameters:
    ///   - name: the name of the feature
    ///   - themeID: the ID of the corresponding theme
    ///   - name: the ID of the corresponding vector layer
    ///   - data: the attribute data stored in a dictionary
    private func addFeature(name: String, themeID: Int, vectorLayerID: Int, data: [String: String]) {
        self.featureData.append(MalinkiFeatureData(data: data, name: name, themeID: themeID, vectorLayerID: vectorLayerID))
    }
    
    /// This function stores all given objects in published instance vars.
    /// - Parameters:
    ///   - name: the name of the feature
    ///   - geojsonFeatures: the previously queried GeoJSON features
    ///   - layerID: the id of the vector layer
    private func getFeatureData(name: String, from geojsonFeatures: [MKGeoJSONFeature], layerID: Int) async {
        //pass an information to the user, if the query returned no data
        if geojsonFeatures.count == 0 {
            self.addFeature(name: name, themeID: self.selectedAnnotation?.themeID ?? -99, vectorLayerID: layerID, data: [String(localized: "Result"): String(localized: "No Data")])
        } else {
            for feature in geojsonFeatures {
                //get the properties as a dictionary
                if let properties = feature.properties {
                    var attributes: [String: String] = [:]
                    
                    //get a dictionary from the json data
                    let property = try? JSONSerialization.jsonObject(with: properties) as? [String: Any]
                    
                    //parsing all properties of the current feature
                    for (key, value) in property ?? ["": ""] {
                        attributes[key] = String(describing: value)
                    }
                    
                    //add the feature to the feature data object
                    self.addFeature(name: name, themeID: self.selectedAnnotation?.themeID ?? -99, vectorLayerID: layerID, data: attributes)
                    
                    //look for a valid geometry
                    if let geometry = feature.geometry.first {
                        //store the geometry
                        self.geometries.append(MalinkiVectorGeometry(mapThemeID: self.selectedAnnotation?.themeID ?? -99, layerID: layerID, geometry: geometry))
                    }
                }
            }
        }
    }
    
    /// This function filters given features and stores them in a published instance var.
    /// - Parameters:
    ///   - name: the name of the feature
    ///   - geojsonFeatures: the previously queried GeoJSON features
    ///   - filterField: the name of the field to filter on
    ///   - filterValue: the value of the filter
    ///   - layerID: the id of the vector layer
    private func getFeatureData(name: String, from geojsonFeatures: [MKGeoJSONFeature], filterField: String, filterValue: String, layerID: Int) async {
        //pass an information to the user, if the query returned no data
        if geojsonFeatures.count == 0 {
            self.addFeature(name: name, themeID: self.selectedAnnotation?.themeID ?? -99, vectorLayerID: layerID, data: [String(localized: "Result"): String(localized: "No Data")])
        } else {
            //iterate over features
            for feature in geojsonFeatures {
                //look for a valid geometry
                if let geometry = feature.geometry.first {
                    
                    //get the properties as a dictionary
                    if let properties = feature.properties {
                        var attributes: [String: String] = [:]
                        
                        //get a dictionary from the json data
                        let property = try? JSONSerialization.jsonObject(with: properties) as? [String: Any]
                        
                        //investigate the feature regarding a possible given filter
                        //only appropriate for pre configured annotations
                        if !(self.selectedAnnotation?.isUserAnnotation ?? false) {
                            var continueLoop = false
                            if let propertyValues = property {
                                continueLoop = self.createStringValue(from: propertyValues[filterField] as Any) != filterValue
                            }
                            if continueLoop {
                                continue
                            }
                        } else {
                            //create a spatial filter, i.e. does the annotation interact with the geometry of the current feature
                            let vectorGeometry = MalinkiVectorGeometry(mapThemeID: self.selectedAnnotation?.themeID ?? -99, layerID: layerID, geometry: geometry)
                            if !vectorGeometry.isInteracting(with: self.selectedAnnotation?.coordinate ?? CLLocationCoordinate2D(latitude: -999.99, longitude: -999.99)) {
                                continue
                            }
                        }
                        
                        //parsing all properties of the current feature
                        for (key, value) in property ?? ["": ""] {
                            attributes[key] = String(describing: value)
                        }
                        
                        //add the feature to the feature data object
                        self.addFeature(name: name, themeID: self.selectedAnnotation?.themeID ?? -99, vectorLayerID: layerID, data: attributes)
                    } else {
                        //skip the feature if properties cannot be extracted
                        continue
                    }
                    
                    //store the geometry
                    self.geometries.append(MalinkiVectorGeometry(mapThemeID: self.selectedAnnotation?.themeID ?? -99, layerID: layerID, geometry: geometry))
                }
            }
            
            //check if no matching features were found
            if self.featureData.count == 0 {
                self.addFeature(name: name, themeID: self.selectedAnnotation?.themeID ?? -99, vectorLayerID: layerID, data: [String(localized: "Result"): String(localized: "No Data")])
            }
        }
    }
    
    /// This function queries data from a WFS using a GetFeatures-request. The data will be stored in a published instance var.
    /// - Parameters:
    ///   - config: the wfs config
    ///   - layerID: the ID of the vector layer
    private func getFeature(config: MalinkiConfigurationWFS, layerID: Int) {
        Task {
            if let annotation = self.selectedAnnotation {
                //get the config of the current vector layer
                let vectorDataConfig = self.configProvider.getVectorLayer(id: annotation.layerID, theme: annotation.themeID)
                
                //create request
                var wfsRequest = self.createWFSGetFeatureRequest(from: config)
                
                if self.selectedAnnotation?.isUserAnnotation ?? false {
                    //create a bbox around the user annotation
                    let precision = 0.00001
                    if let lon = self.selectedAnnotation?.coordinate.longitude, let lat = self.selectedAnnotation?.coordinate.latitude {
                        let bbox = "\(lat - precision),\(lon - precision),\(lat + precision),\(lon + precision)"
                        wfsRequest += "&BBOX=\(bbox),urn:ogc:def:crs:EPSG:4326"
                    }
                    
                } else {
                    //create the filter parameter for configured annotations
                    let filter = "<fes:Filter xmlns:fes=\"http://www.opengis.net/fes/2.0\" xmlns:gml=\"http://www.opengis.net/gml/3.2\"><fes:And><fes:PropertyIsEqualTo><fes:PropertyName>\(self.configProvider.getVectorLayer(id: annotation.layerID, theme: annotation.themeID)?.attributes.id ?? "")</fes:PropertyName><fes:Literal>\(annotation.featureID)</fes:Literal></fes:PropertyIsEqualTo></fes:And></fes:Filter>"
                    
                    wfsRequest += "&FILTER=\(filter)"
                }
                //                print(wfsRequest)
                //query data from WFS
                let data = try await self.fetchData(from: wfsRequest)
                
                //parse the server response
                let gml = self.decodeGML(from: data)
                
                //get the geometry name
                let geomName = vectorDataConfig?.attributes.geometry ?? ""
                
                //check for features in the response
                let members = gml["wfs:FeatureCollection"]["wfs:member"].all
                if members.count == 0 {
                    self.addFeature(name: annotation.title ?? "", themeID: annotation.themeID, vectorLayerID: layerID, data: [String(localized: "Result"): String(localized: "No Data")])
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
                        self.addFeature(name: annotation.title ?? "", themeID: annotation.themeID, vectorLayerID: layerID, data: properties)
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
