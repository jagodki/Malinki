//
//  MalinkiImageLoader.swift
//  Malinki
//
//  Created by Christoph Jung on 19.10.22.
//

import Foundation
import UIKit
import Combine

class MalinkiImageLoader: ObservableObject {
    
    @Published var image: UIImage?
    @Published var noImage: Bool = false
    private var cancellable: AnyCancellable?
    private let mapTheme: Int
    private let layerID: Int
    
    /// The initialiser of this class.
    /// - Parameter mapTheme: the ID of the map theme
    /// - Parameter layerID: the ID of the layer providing the image
    init(mapTheme: Int, layerID: Int) {
        self.mapTheme = mapTheme
        self.layerID = layerID
    }
    
    /// This function loads the image async.
    func load() {
        if self.image == nil {
            let config = MalinkiConfigurationProvider.sharedInstance.getLegendGraphic(for: self.layerID, in: self.mapTheme)
            
            if let urlString = config.url {
                self.cancellable = URLSession.shared.dataTaskPublisher(for: URL(string: urlString)!)
                    .map { UIImage(data: $0.data) }
                    .replaceError(with: nil)
                    .receive(on: DispatchQueue.main)
                    .assign(to: \.image, on: self)
            } else if let imageName = config.fileName {
                self.image = UIImage(named: imageName)
            } else {
                self.noImage = true
            }
        }
        
    }
    
    /// This function cancels the image load.
    func cancel() {
        self.noImage = false
        self.cancellable?.cancel()
    }
    
}
