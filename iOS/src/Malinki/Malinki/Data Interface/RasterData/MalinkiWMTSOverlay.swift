//
//  MalinkiWMTSOverlay.swift
//  Malinki
//
//  Created by Christoph Jung on 22.09.21.
//

import Foundation
import MapKit

public class MalinkiWMTSOverlay: MalinkiTileOverlay {
    
    private let TILE_CACHE = "TILE_CACHE"
    
    private var url: String
    
    init(url: String, alpha: CGFloat = 1.0) {
        self.url = url
        super.init(urlTemplate: url, alpha: alpha)
    }
    
    public override func url(forTilePath path: MKTileOverlayPath) -> URL {
        let matrix = path.z
        let row = path.y
        let col = path.x
        
        let resolvedUrl = self.url + "&TILEMATRIX=\(matrix)&TILEROW=\(row)&TIlECOL=\(col)"

        return URL(string: resolvedUrl)!
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
        createPathIfNecessary(path: cachesPath)
        createPathIfNecessary(path: cachePath)

        return cachePath
    }
    
    private func getFilePathForURL(url: URL, folderName: String) -> String {
        return cachePathWithName(name: folderName).stringByAppendingPathComponent(path: "\(url.hashValue)")
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
        let filePath = getFilePathForURL(url: url1, folderName: TILE_CACHE)

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
