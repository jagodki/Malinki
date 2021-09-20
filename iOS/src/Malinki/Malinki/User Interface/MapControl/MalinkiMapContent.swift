//
//  MalinkiMapContent.swift
//  Malinki
//
//  Created by Christoph Jung on 09.08.21.
//

import SwiftUI

/// A structure to present the show and control the map content/layers.
struct MalinkiMapContent: View {
    
    @Binding private var mapLayers: [MalinkiMapLayer]
    
    /// The initialiser of this sctructure.
    /// - Parameter mapLayers: an array of map layers, that should be presented in a list
    init(mapLayers: Binding<[MalinkiMapLayer]>) {
        self._mapLayers = mapLayers
    }
    
    var body: some View {
        
        VStack {
            ForEach(self.mapLayers.indices, id:\.self) { index in
                Toggle(isOn: self.$mapLayers[index].isToggled) {
                    HStack {
                        self.mapLayers[index].image
                            .clipShape(Circle())
                        Text(self.mapLayers[index].name)
                    }.toggleStyle(SwitchToggleStyle(tint: .accentColor))
                }
            }
        }.padding()
    }
    
}

struct MalinkiMapContent_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiMapContent(mapLayers: .constant([MalinkiMapLayer(id: 0, name: "Test", imageName: "cloud.moon.fill"), MalinkiMapLayer(id: 1, name: "Test2", imageName: "cloud.bolt.fill")]))
    }
}
