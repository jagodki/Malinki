//
//  MalinkiTileOverlay.swift
//  Malinki
//
//  Created by Christoph Jung on 06.09.21.
//

import Foundation
import MapKit

extension String {

    func stringByAppendingPathComponent(path: String) -> String {
        let nsSt = self as NSString
        return nsSt.appendingPathComponent(path)
    }
}

/// A class for loading a TMS as a MKTileOverlay.
public class MalinkiTileOverlay: MKTileOverlay {
    
    private let TILE_CACHE = "TILE_CACHE"
    var alpha: CGFloat = 1.0
    
    /// The initialiser of this class.
    /// - Parameters:
    ///   - urlTemplate: the url of the services with placeholders
    ///   - alpha: the opacity of the received image for displaying
    init(urlTemplate: String?, alpha: CGFloat = 1.0) {
        self.alpha = alpha
        super.init(urlTemplate: urlTemplate)
    }
    
    private func createPathIfNecessary(path: String) -> Void {
        let fm = FileManager.default
        if(!fm.fileExists(atPath: path)) {
            do {
                try fm.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                print(error)
            }
        }
    }
    
    private func cachePathWithName(name: String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let cachesPath: String = paths as String
        let cachePath = cachesPath.stringByAppendingPathComponent(path: name)
        self.createPathIfNecessary(path: cachesPath)
        self.createPathIfNecessary(path: cachePath)

        return cachePath
    }
    
    private func getFilePathForURL(url: URL, folderName: String) -> String {
        return self.cachePathWithName(name: folderName).stringByAppendingPathComponent(path: "\(url.hashValue)")
    }

    private func cacheUrlToLocalFolder(url: URL, data: NSData, folderName: String) {
        let localFilePath = getFilePathForURL(url: url, folderName: folderName)
        do {
            try data.write(toFile: localFilePath)
        } catch let error {
            print(error)
        }
    }
    
    public override func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void) {
        let url1 = self.url(forTilePath: path)
        let filePath = getFilePathForURL(url: url1, folderName: self.TILE_CACHE)

        let file = FileManager.default

        if file.fileExists(atPath: filePath) {
            let tileData =  try? NSData(contentsOfFile: filePath, options: .dataReadingMapped)
            result(tileData as Data?, nil)
        } else {
            let request = NSMutableURLRequest(url: url1)
            request.httpMethod = "GET"

            let session = URLSession.shared
            session.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in

                if error != nil {
                    print("Error downloading tile")
                    result(nil, error)
                }
                else {
                    do {
                        try data?.write(to: URL(fileURLWithPath: filePath))
                    } catch let error {
                        print(error)
                    }
                    result(data, nil)
                }
            }).resume()
        }
    }
}
