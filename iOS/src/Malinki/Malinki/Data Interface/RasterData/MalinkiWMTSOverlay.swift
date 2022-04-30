//
//  MalinkiWMTSOverlay.swift
//  Malinki
//
//  Created by Christoph Jung on 22.09.21.
//

import Foundation
import MapKit

/// A class for loading a WMTS as a MKTileOverlay.
public class MalinkiWMTSOverlay: MalinkiTileOverlay {
    
    private var url: String
    
    /// The initialiser of this class.
    /// - Parameters:
    ///   - url: the base url of the service without any parameters
    ///   - alpha: the opacity of the received image for displaying
    ///   - subDirName: the name of the sub directory for caching tiles   
    init(url: String, alpha: CGFloat = 1.0, subDirName: String) {
        self.url = url
        super.init(urlTemplate: url, alpha: alpha, subDirName: subDirName)
    }
    
    public override func url(forTilePath path: MKTileOverlayPath) -> URL {
        let matrix = path.z
        let row = path.y
        let col = path.x
        
        let resolvedUrl = self.url + "&TILEMATRIX=\(matrix)&TILEROW=\(row)&TIlECOL=\(col)"

        return URL(string: resolvedUrl)!
    }
    
}
