//
//  MalinkiConfigurationLoader.swift
//  Malinki
//
//  Created by Christoph Jung on 15.08.21.
//

import Foundation

/// A structure for loading the main configuration file
struct MalinkiConfigurationLoader {
    
    private let configFileName = "Configuration"
    var configData: MalinkiConfiguration? = nil
    
    /// The initialiser of this structure.
    init() {
        
        guard let configURL = Bundle.main.url(forResource: self.configFileName, withExtension: "json") else {
            return
        }
        
        do {
            let decoder = JSONDecoder()
            self.configData = try decoder.decode(MalinkiConfiguration.self, from: Data(contentsOf: configURL))
        } catch  {
            print("Error decoding the configuration!")
        }
        
    }
}
