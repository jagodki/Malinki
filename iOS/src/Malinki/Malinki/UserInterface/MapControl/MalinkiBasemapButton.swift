//
//  MalinkiBasemapButton.swift
//  Malinki
//
//  Created by Christoph Jung on 05.08.21.
//

import SwiftUI

/// A structure to create a Basemap Button.
struct MalinkiBasemapButton: View {
    
    @Binding private var toggledBasemapID: Int
    private var imageName: String
    private var basemapName: String
    private var id: Int
    
    /// The initialiser of this structure.
    /// - Parameters:
    ///   - toggledBasemapID: a binding indicating the id of the toggled basemap
    ///   - imageName: the name of the image
    ///   - basemapName: the name of the basemap, presented at the bottom of the button
    ///   - id: the id of this basemap according to the configuration
    init(toggledBasemapID: Binding<Int>, imageName: String, basemapName: String, id: Int) {
        self._toggledBasemapID = toggledBasemapID
        self.imageName = imageName
        self.basemapName = basemapName
        self.id = id
    }
    
    var body: some View {
        
        VStack {
            Button(action: {
                self.toggledBasemapID = self.id
            }) {
                VStack {
                    Image(self.imageName)
                        .frame(minWidth: 0, idealWidth: 100, maxWidth: 100, minHeight: 50, idealHeight: 50, maxHeight: 50, alignment: .center)
                        .cornerRadius(5)
                        .overlay(RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.accentColor, lineWidth: self.id == self.toggledBasemapID ? 2 : 0))
                        .shadow(radius: self.id == self.toggledBasemapID ? 0 : 1)
                }
            }
            
            Text(self.basemapName)
                .frame(width: 100, height: 20, alignment: .center)
                .font(self.id == self.toggledBasemapID ? .footnote.bold() : .footnote)
                .foregroundColor(self.id == self.toggledBasemapID ? .accentColor : .secondary)
        }
        
    }
}

struct MalinkiBasemapButton_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiBasemapButton(toggledBasemapID: .constant(0), imageName: "osm_basemap", basemapName: "OSM Street", id: 1)
    }
}
