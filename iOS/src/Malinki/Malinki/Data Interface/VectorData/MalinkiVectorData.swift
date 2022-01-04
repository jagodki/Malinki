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
    
    
}
