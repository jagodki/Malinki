//
//  MalinkiBasemapButton.swift
//  Malinki
//
//  Created by Christoph Jung on 05.08.21.
//

import SwiftUI

struct MalinkiBasemapButton: View {
    
    @Binding private var isToggled: Bool
    private var imagePath: String
    private var basemapName: String
    
    init(isToggled: Binding<Bool>, imagePath: String, basemapName: String) {
        self._isToggled = isToggled
        self.imagePath = imagePath
        self.basemapName = basemapName
    }
    
    var body: some View {
        
        VStack {
            Button(action: {
                print("Theme Button pressed")
            }) {
                VStack {
                    Image(self.imagePath)
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
        MalinkiBasemapButton(isToggled: .constant(true), imagePath: "osm_basemap", basemapName: "OSM Street")
    }
}
