//
//  MalinkiVectorData.swift
//  Malinki
//
//  Created by Christoph Jung on 17.11.21.
//

import Foundation
import MapKit
import CoreGraphics
import SwiftUI
import SWXMLHash

@available(iOS 15.0.0, *)
public class MalinkiVectorData {
    
    enum MalinkiVectorDataError: Error {
        case invalidURLString
    }
    
    public func decodeGeoJSON(from data: Data) -> [MKGeoJSONFeature] {
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
    
    public func fetchData(from urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw MalinkiVectorDataError.invalidURLString
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        return data
    }
    
    public func getLocalData(from pathAsString: String) -> Data {
        var jsonData = Data()
        
        do {
            //get the path of the local file
            if let bundleURL = Bundle.main.url(forResource: pathAsString, withExtension: "geojson") {
                
                //try to read the data
                jsonData = try Data(contentsOf: bundleURL)
            }
        } catch let error {
            print("ERROR: unable to read local GeoJSON-file: \(error)")
        }
        
        return jsonData
    }
    
    public func decodeGML(from data: Data) -> XMLIndexer {
        let gml = XMLHash.lazy(data)
        return gml
    }
    
    
}
