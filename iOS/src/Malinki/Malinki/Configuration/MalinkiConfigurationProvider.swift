//
//  MalinkiConfigurationLoader.swift
//  Malinki
//
//  Created by Christoph Jung on 15.08.21.
//

import Foundation

/// A class for loading the main configuration file
class MalinkiConfigurationProvider {
    
    /// The singleton of this class
    static let sharedInstance = MalinkiConfigurationProvider()
    private let configFileName = "Configuration"
    var configData: MalinkiConfiguration? = nil

    /// The initialiser of this structure.
    private init() {
        guard let configURL = Bundle.main.url(forResource: self.configFileName, withExtension: "json") else {
            print("not able to find the configuration file")
            return
        }

        do {
            let decoder = JSONDecoder()
            self.configData = try decoder.decode(MalinkiConfiguration.self, from: Data(contentsOf: configURL))
        } catch  {
            print("Error decoding the configuration!")
            print(error)
        }

    }
    
}
