//
//  MalinkiVectorData.swift
//  Malinki
//
//  Created by Christoph Jung on 17.11.21.
//

import Foundation
import MapKit
import CoreGraphics

@available(iOS 15.0.0, *)
class MalinkiVectorData {
    
    private var featureData: [String: String] = [:]
    
    enum MalinkiVectorDataError: Error {
        case invalidURLString
    }
    
    private var configuration: MalinkiConfigurationProvider = MalinkiConfigurationProvider.sharedInstance
    private var coordinateConverter: MalinkiCoordinatesConverter = MalinkiCoordinatesConverter()
    
    func getAnnotationFeatures(for layerID: Int, in mapThemeID: Int) -> [MalinkiAnnotation] {
        //get config data
        let vectorDataConfig = self.configuration.getVectorLayer(id: layerID, theme: mapThemeID)
        let vectorTypes = vectorDataConfig?.vectorTypes
        
        //init an empty result array
        var annotations: [MalinkiAnnotation] = []
        
        if let local = vectorTypes?.localFile {
            do {
                //get the path of the local file
                if let bundleURL = Bundle.main.url(forResource: local, withExtension: "geojson") {
                    
                    //try to read the data
                    let jsonData = try Data(contentsOf: bundleURL)
                    
                    //parse the json-file
                    let features = self.decodeGeoJSON(from: jsonData)
                    
                    for feature in features {
                        //get the properties as a dictionary
                        if let properties = feature.properties {
                            
                            //get a dictionary from the json data
                            let featureData = try? JSONSerialization.jsonObject(with: properties) as? [String: Any]
                            
                            //get the feature data
                            guard let title = featureData?[vectorDataConfig?.attributes.title ?? ""] as? String else { continue }
                            guard let id = featureData?[vectorDataConfig?.attributes.id ?? ""] as? Int else { continue }
                            
                            //get the point geometry
                            guard let point = feature.geometry.first as? MKPointAnnotation else { continue }
                            
                            //create a new annotation
                            annotations.append(MalinkiAnnotation(title: title, subtitle: self.configuration.getExternalVectorName(id: layerID, theme: mapThemeID), coordinate: point.coordinate, themeID: mapThemeID, layerID: layerID, featureID: id))
                        }
                    }
                } else {
                    print("ERROR: cannot find GeoJSON file: " + local)
                }
            } catch let error {
                print("ERROR: unable to read local GeoJSON-file: \(error)")
            }
        } else if let remote = vectorTypes?.remoteFile {
            annotations = []
        } else if let wfs = vectorTypes?.wfs {
            annotations = []
        }
        
        return annotations
    }
    
    //    func loadWFSData(from urlAsString: String) -> [MKGeoJSONFeature] {
    //        //create the result var
    //        var features: [MKGeoJSONFeature] = []
    //
    //        if let url = URL(string: urlAsString) {
    //
    //            //query the data
    //            URLSession.shared.dataTask(with: url) { data, response, error in
    //
    //                //check data
    //                if let data = data {
    //                    do {
    //                        //decode GeoJSON
    //                        features = try MKGeoJSONDecoder().decode(data).compactMap({$0 as? MKGeoJSONFeature})
    //                    } catch let error {
    //                        //catch errors
    //                        print("ERROR: unable to request data from WFS: \(error)")
    //                    }
    //                }
    //            }.resume()
    //        }
    //        return features
    //    }
    
    private func decodeGeoJSON(from data: Data) -> [MKGeoJSONFeature] {
        //create the result var
        var features: [MKGeoJSONFeature] = []
        
        do {
            //decode GeoJSON
            features = try MKGeoJSONDecoder().decode(data).compactMap({$0 as? MKGeoJSONFeature})
        } catch let error {
            //catch errors
            print("ERROR: unable to decode GeoJSON: \(error)")
        }
        
        return features
    }
    
    func getFeatureData(featureID: Int, mapThemeID: Int, annotation: MKAnnotation?, span: MKCoordinateSpan) -> [String: String] {
        //get the layer data from the config file
        let featureLayer = self.configuration.getVectorLayer(id: featureID, theme: mapThemeID)
        let featureInfo = featureLayer?.featureInfo
        
        if let wfs = featureInfo?.wfs {
            print("wfs")
        } else if let wms = featureInfo?.wms {
            self.getFeatureInfo(for: annotation, with: span, config: wms)
            
        } else if let localFile = featureInfo?.localFile {
            print("local")
        } else if let remoteFile = featureInfo?.remoteFile {
            print("remote")
        }
        
        return self.featureData
    }
    
    private func getFeatureInfo(for annotation: MKAnnotation?, with span: MKCoordinateSpan, config: MalinkiConfigurationVectorFeatureInfoWMS) {
        //get coordinates
        let coord = annotation?.coordinate
        
        //get delta longitude
        let deltaLon = span.longitudeDelta
        
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
            x0 = self.coordinateConverter.mercatorXofLongitude(lon: x0)
            x1 = self.coordinateConverter.mercatorXofLongitude(lon: x1)
            y0 = self.coordinateConverter.mercatorYofLatitude(lat: y0)
            y1 = self.coordinateConverter.mercatorYofLatitude(lat: y1)
            
            //get height in correct ratio, if coordinates are in webmercator
            height = height * (y1 - y0) / (x1 - x0)
        }
        
        //get tap position in points
        let i = Int(width / 2) + 1
        let j = Int(height / 2) + 1
        
        //create request
        let bbox: String = "\(x0),\(y0),\(x1),\(y1)"
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
                    
                    //get geojson object
                    let geojson = self.decodeGeoJSON(from: data)
                    
                    //iterate over features
                    for feature in geojson {
                        //get the properties as a dictionary
                        if let properties = feature.properties {
                            
                            //get a dictionary from the json data and append the feature data
                            let property = try? JSONSerialization.jsonObject(with: properties) as? [String: Any]
                            for (key, value) in property ?? ["": ""] {
                                self.appendFeatureData(key: key, value: String(describing: value))
                            }
                        }
                    }
                } else if config.infoFormat == "plain/text" {
                    self.setFeatureData(dict: ["test": "test"])
                }
                
            } catch {
                self.setFeatureData(dict: ["Error": "not able to get data from webservice"])
            }
        }
    }
    
    private func fetchData(from urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw MalinkiVectorDataError.invalidURLString
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
    
    private func setFeatureData(dict: [String: String]) {
        self.featureData = dict
    }
    
    private func appendFeatureData(key: String, value: String) {
        self.featureData[key] = value
    }
}
