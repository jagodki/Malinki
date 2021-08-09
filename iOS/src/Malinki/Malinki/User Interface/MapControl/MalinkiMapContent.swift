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
        List {
            Section(header: Text("Map Layers", comment: "the name of the list with the map layers")
                        .font(.headline)) {
                ForEach(self.mapLayers, id: \.name) { mapLayer in
                    Toggle(isOn: mapLayer.$isToggled) {
                        HStack {
                            mapLayer.image
                                .clipShape(Circle())
                            Text(mapLayer.name)
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .padding()
    }
    
}

struct MalinkiMapContent_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiMapContent(mapLayers: .constant([MalinkiMapLayer(name: "Test", image: Image(systemName: "cloud.moon.fill"), isToggled: true), MalinkiMapLayer(name: "Test2", image: Image(systemName: "cloud.bolt.fill"), isToggled: false)]))
    }
}
