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
/// This class provides acces to vector data of different source types.
public class MalinkiVectorData {
    
    enum MalinkiVectorDataError: Error {
        case invalidURLString
    }
    
    /// This function decodes given GeoJSON data to the build in MKGeoJSONFeatures.
    /// - Parameter data: a data object containing GeoJSON data
    /// - Returns: an array of MKGeoJSONFeature
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
    
    /// This function fetches json data from a remote source
    /// - Parameter urlString: the url of the source
    /// - Returns: the data from the remote location
    public func fetchData(from urlString: String) async throws -> Data {
        guard let urlStringEncoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: urlStringEncoded) else {
            throw MalinkiVectorDataError.invalidURLString
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        return data
    }
    
    /// This function fetches json data on the local device.
    /// - Parameter pathAsString: the path to the local file
    /// - Returns: the data from the local device
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
    
    /// This function decodes xml data.
    /// - Parameter data: previously fetched xml data
    /// - Returns: decoded data as XMLIndexer
    public func decodeGML(from data: Data) -> XMLIndexer {
        let gml = XMLHash.lazy(data)
        return gml
    }
    
    /// This function creates a WFS GetFeatures-Request from a given config.
    /// - Parameter config: a configuration of the WFS
    /// - Returns: the String of the GetFeatures-Request
    func createWFSGetFeatureRequest(from config: MalinkiConfigurationWFS) -> String {
        let additionalParameters = config.additionalParameters ?? ""
        let wfsRequest = "\(config.baseURL)&SERVICE=WFS&REQUEST=GetFeature&SRSNAME=\(config.crs)&TYPENAME=\(config.typename)&TYPENAMES=\(config.typenames)&VERSION=\(config.version)\(additionalParameters)"
        return wfsRequest
    }
    
    /// This function creates a String from a given Int, Double or String value.
    /// - Parameter anyValue: the value to convert into String
    /// - Returns: the converted value
    func createStringValue(from anyValue: Any) -> String {
        let stringValue: String
        
        switch anyValue {
        case is String:
            stringValue = anyValue as? String ?? ""
        case is Double:
            stringValue = String(anyValue as? Double ?? 0.0)
        case is Int:
            stringValue = String(anyValue as? Int ?? 0)
        default:
            stringValue = ""
        }
        
        return stringValue
    }
    
}
