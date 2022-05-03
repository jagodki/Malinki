//
//  MalinkiApp.swift
//  Malinki
//
//  Created by Christoph Jung on 28.06.21.
//

import SwiftUI

@available(iOS 15.0, *)
@main
struct MalinkiApp: App {
    
    init() {
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main, using: {_ in
            
            //get the path
            let fileManager = FileManager.default
            let documentsUrl =  fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            let cachePath = documentsUrl?.path.stringByAppendingPathComponent(path: "TILE_CACHE")
            
            //clear cache
            do {
                if let mapCachePath = cachePath {
                    try fileManager.removeItem(atPath: mapCachePath)
                }
            } catch {
                print("ERROR - could not clear cache folder: \(error)")
            }
        })
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
