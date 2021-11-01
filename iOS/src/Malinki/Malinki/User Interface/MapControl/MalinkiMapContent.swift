//
//  MalinkiMapContent.swift
//  Malinki
//
//  Created by Christoph Jung on 09.08.21.
//

import SwiftUI

/// A structure to present the show and control the map content/layers.
@available(iOS 15.0, *)
struct MalinkiMapContent: View {
    
    @EnvironmentObject var mapLayers: MalinkiLayerContainer
    @Binding private var sheetState: MalinkiSheet.State?
    @Binding private var mapThemeID: Int
    
    /// The initialiser of this sctructure.
    /// - Parameter mapLayers: a dictionary of map layers, that should be presented in a list
    /// - Parameter mapThemeID: the ID of the current map theme
    init(sheetState: Binding<MalinkiSheet.State?>, mapThemeID: Binding<Int>) {
        self._sheetState = sheetState
        self._mapThemeID = mapThemeID
    }
    
    var body: some View {
        
        NavigationView {
            Form {
                List(self.$mapLayers.rasterLayers.filter({$0.themeID.wrappedValue == self.mapThemeID})) { $layer in
                    Toggle(isOn: $layer.isToggled) {
                        HStack {
                            layer.image
                                .clipShape(Circle())
                            Text(layer.name)
                        }
                    }.toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .principal, content: {
                    HStack {
                        Text(LocalizedStringKey("Map Content"))
                            .font(.headline)
                            .padding(.leading)
                        
                        Spacer()
                        
                        Button(action: {self.sheetState = nil}) {
                            Image(systemName: "xmark.circle.fill")
                                .padding(.trailing)
                                .foregroundColor(Color.secondary)
                                .font(.headline)
                        }
                    }
                })
            })
        }
    }
    
}

@available(iOS 15.0, *)
struct MalinkiMapContent_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiMapContent(sheetState: .constant(MalinkiSheet.State?.none), mapThemeID: .constant(0))
            .environmentObject(MalinkiLayerContainer(layers: MalinkiConfigurationProvider.sharedInstance.getAllMapLayersArray()))
    }
}
