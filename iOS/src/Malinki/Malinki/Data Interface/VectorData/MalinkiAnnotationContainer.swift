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
    var newAnnotationsLoaded: Bool = false
    
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
                
                //get data from file
                let jsonData = self.getLocalData(from: local)
                
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
                
            } else if let remote = vectorTypes?.remoteFile {
                Task {
                    //get the data from the remote source
                    let jsonData = try await self.fetchData(from: remote)
                    
                    //get the feature data from the GeoJSON
                    let features = self.decodeGeoJSON(from: jsonData)
                    
                    //get the annotations
                    DispatchQueue.main.async {
                        self.setAnnotations(annotations: self.createAnnotations(features: features, layerID: layerID, mapThemeID: mapThemeID), for: layerID)
                    }
                }
            } else if let wfs = vectorTypes?.wfs {
                Task {
                    //create the GetFeature-Request
                    let additionalParameters = wfs.additionalParameters ?? ""
                    let wfsRequest = "\(wfs.baseURL)&SERVICE=WFS&REQUEST=GetFeature&SRSNAME=\(wfs.crs)&TYPENAME=\(wfs.typename)&TYPENAMES=\(wfs.typenames)&VERSION=\(wfs.version)\(additionalParameters)"
                    
                    //get the data from the wfs response
                    let data = try await self.fetchData(from: wfsRequest)
                    
                    //get the id and title names
                    let id = vectorDataConfig?.attributes.id ?? ""
                    let title = vectorDataConfig?.attributes.title ?? ""
                    let geometry = vectorDataConfig?.attributes.geometry ?? ""
                    
                    //decode the gml
                    let gml = self.decodeGML(from: data)
                    for member in gml["wfs:FeatureCollection"]["wfs:member"].all {
                        for child in member.children {
                            
                            //get the coordinate pair, i.e. the value of the child of gml:Point
                            let coordinates = (child[geometry]["gml:Point"].children[0].element?.text ?? "").split(separator: " ")
                            let x = coordinates.first ?? "-999.99"
                            let y = coordinates.last ?? "-999.99"
                            
                            //create new annotations
                            DispatchQueue.main.async {
                                self.updateAnnotations(annotation: MalinkiAnnotation(title: child[title].element?.text,
                                                                                     subtitle: configuration.getExternalVectorName(id: layerID,theme: mapThemeID),
                                                                                     coordinate: CLLocationCoordinate2D(latitude: Double(y) ?? -999.99,
                                                                                                                        longitude: Double(x) ?? -999.99),
                                                                                     themeID: mapThemeID,
                                                                                     layerID: layerID,
                                                                                     featureID: Int(child[id].element?.text ?? "0") ?? -99),
                                                       for: layerID)
                            }
                        }
                    }
                }
                
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
        
        self.newAnnotationsLoaded = true
    }
    
    private func setAnnotations(annotations: [MalinkiAnnotation], for layerID: Int) {
        self.annotations[layerID] = annotations
        
        self.newAnnotationsLoaded = true
    }
    
}
