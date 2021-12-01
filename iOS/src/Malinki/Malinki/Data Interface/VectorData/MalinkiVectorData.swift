//
//  MalinkiVectorData.swift
//  Malinki
//
//  Created by Christoph Jung on 17.11.21.
//

import Foundation
import MapKit

struct MalinkiVectorData {
    
    private var configuration: MalinkiConfigurationProvider = MalinkiConfigurationProvider.sharedInstance
    
    func getAnnotationFeatures(for layerID: Int, in mapThemeID: Int) -> [MalinkiAnnotation] {
        /*
         - get layer from config
         - check type
         - extract annotations
         */
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
                            guard let id = featureData?[vectorDataConfig?.attributes.id ?? ""] as? String else { continue }
                            
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
    
    func decodeGeoJSON(from data: Data) -> [MKGeoJSONFeature] {
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
}
