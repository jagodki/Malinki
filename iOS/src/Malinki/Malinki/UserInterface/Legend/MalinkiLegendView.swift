//
//  MalinkiLegendView.swift
//  Malinki
//
//  Created by Christoph Jung on 18.10.22.
//

import SwiftUI

struct MalinkiLegendView: View {
    
    @ObservedObject private var imageLoader: MalinkiImageLoader
    private let title: String
    private let mapTheme: Int
    private let layerID: Int
    
    /// The initialiser of this structure.
    /// - Parameters:
    ///   - title: the title of this navigation view
    ///   - mapTheme: the ID of the map theme
    ///   -  layerID: the ID of the layer providing the legend
    init(title: String, mapTheme: Int, layerID: Int) {
        self.title = title
        self.mapTheme = mapTheme
        self.layerID = layerID
        self.imageLoader = MalinkiImageLoader(mapTheme: mapTheme, layerID: layerID)
        self.imageLoader.load()
    }
    
    private var image: some View {
        NavigationView() {
            Form {
                HStack {
                    Spacer()
                    
                    if let legendImage = self.imageLoader.image {
                        Image(uiImage: legendImage)
                    } else if self.imageLoader.noImage {
                        Image(systemName: "photo")
                            .resizable()
                    } else {
                        VStack {
                            ProgressView()
                                .frame(width: 100, height: 100)
                            Text(LocalizedStringKey("Loading..."))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
            }
        }
        .navigationTitle(self.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var body: some View {
        self.image
            .onDisappear(perform: self.imageLoader.cancel)
    }
}

struct MalinkiLegendView_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiLegendView(title: "Legend Graphic", mapTheme: 0, layerID: 0)
    }
}
