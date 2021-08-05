//
//  MalinkiBasemapButton.swift
//  Malinki
//
//  Created by Christoph Jung on 05.08.21.
//

import SwiftUI

/// A structure to create a Basemap Button.
struct MalinkiBasemapButton: View {
    
    @Binding private var isToggled: Bool
    private var imageName: String
    private var basemapName: String
    
    /// The initialiser of this structure.
    /// - Parameters:
    ///   - isToggled: a binding indicating, if the button is toggled or not
    ///   - imageName: the name of the image
    ///   - basemapName: the name of the basemap, presented at the bottom of the button
    init(isToggled: Binding<Bool>, imageName: String, basemapName: String) {
        self._isToggled = isToggled
        self.imageName = imageName
        self.basemapName = basemapName
    }
    
    var body: some View {
        
        VStack {
            Button(action: {
                print("Theme Button pressed")
            }) {
                VStack {
                    Image(self.imageName)
                        .frame(minWidth: 0, idealWidth: 100, maxWidth: 100, minHeight: 50, idealHeight: 50, maxHeight: 50, alignment: .center)
                        .cornerRadius(5)
                        .overlay(RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.accentColor, lineWidth: self.isToggled ? 2 : 0))
                }
            }
            
            Text(self.basemapName)
                .frame(width: 100, height: 20, alignment: .center)
                .font(self.isToggled ? .footnote.bold() : .footnote)
                .foregroundColor(self.isToggled ? .accentColor : .secondary)
        }
        
    }
}

struct MalinkiBasemapButton_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiBasemapButton(isToggled: .constant(true), imageName: "osm_basemap", basemapName: "OSM Street")
    }
}
