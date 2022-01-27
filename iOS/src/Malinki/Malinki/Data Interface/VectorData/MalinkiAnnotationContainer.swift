//
//  MalinkiVectorAnnotation.swift
//  Malinki
//
//  Created by Christoph Jung on 03.01.22.
//

import Foundation
import MapKit

@available(iOS 15.0.0, *)
public class MalinkiAnnotationContainer: MalinkiVectorData, ObservableObject {
    
    var currentAnnotations: [String: String] = [:] //["mapTheme": String(...), "areAnnotationsToggled": String(...), "layers": ... + "-" + ...]
    var deselectAnnotations: Bool = false
    @Published var annotations: [Int: [MalinkiAnnotation]] = [:]
    
    func getAnnotationFeatures(for layerIDs: [Int], in mapThemeID: Int) {
        //init an empty result array
        self.annotations = [:]
        
        //iterate through all given layers
        for layerID in layerIDs {
            
            //get config data
            let configuration = MalinkiConfigurationProvider.sharedInstance
            let vectorDataConfig = configuration.getVectorLayer(id: layerID, theme: mapThemeID)
            let vectorTypes = vectorDataConfig?.vectorTypes
            
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
                                self.updateAnnotations(annotation: MalinkiAnnotation(title: title, subtitle: configuration.getExternalVectorName(id: layerID, theme: mapThemeID), coordinate: point.coordinate, themeID: mapThemeID, layerID: layerID, featureID: id), for: layerID)
                            }
                        }
                    } else {
                        print("ERROR: cannot find GeoJSON file: " + local)
                    }
                } catch let error {
                    print("ERROR: unable to read local GeoJSON-file: \(error)")
                }
            } else if let remote = vectorTypes?.remoteFile {
                Task {
                    //get the data from the remote source
                    let jsonData = try await self.fetchData(from: remote)
                    
                    //get the feature data from the GeoJSON
                    let features = self.decodeGeoJSON(from: jsonData)
                    
                    //get the annotations
                    self.setAnnotations(annotations: self.createAnnotations(features: features, layerID: layerID, mapThemeID: mapThemeID), for: layerID)
                }
            } else if let wfs = vectorTypes?.wfs {
                
            }
        }
    }
    
    private func createAnnotations(features: [MKGeoJSONFeature], layerID: Int, mapThemeID: Int) -> [MalinkiAnnotation]{
        var annotations: [MalinkiAnnotation] = []
        let configuration = MalinkiConfigurationProvider.sharedInstance
        let vectorDataConfig = configuration.getVectorLayer(id: layerID, theme: mapThemeID)
        
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
                annotations.append(MalinkiAnnotation(title: title, subtitle: configuration.getExternalVectorName(id: layerID, theme: mapThemeID), coordinate: point.coordinate, themeID: mapThemeID, layerID: layerID, featureID: id))
            }
        }
        
        return annotations
    }
    
    private func updateAnnotations(annotation: MalinkiAnnotation, for layerID: Int) {
        if !self.annotations.keys.contains(layerID) {
            self.annotations[layerID] = []
        }
        self.annotations[layerID]?.append(annotation)
    }
    
    private func setAnnotations(annotations: [MalinkiAnnotation], for layerID: Int) {
        self.annotations[layerID] = annotations
    }
    
}
