//
//  MalinkiVectorData.swift
//  Malinki
//
//  Created by Christoph Jung on 17.11.21.
//

import Foundation
import MapKit

struct MalinkiVectorData {
    
    var vectorLayerConfiguration: String
    
//    func getFeatures() -> [MKGeoJSONFeature] {
//        <#function body#>
//    }
    
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
            print("ERROR: unable to request data from WFS: \(error)")
        }
        
        return features
    }
}
