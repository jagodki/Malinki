//
//  MalinkiMapContent.swift
//  Malinki
//
//  Created by Christoph Jung on 09.08.21.
//

import SwiftUI

/// A structure to present and control the map content/layers.
@available(iOS 15.0, *)
struct MalinkiMapContent: View {
    
    @EnvironmentObject var mapLayers: MalinkiLayerContainer
    @Binding private var mapThemeID: Int
    @Binding private var isSheetShowing: Bool
    
    /// The initialiser of this sctructure.
    /// - Parameter mapThemeID: the ID of the current map theme as binding
    /// - Parameter isSheetShowing: a binding to control the presentation of a sheet
    init(mapThemeID: Binding<Int>, isSheetShowing: Binding<Bool>) {
        self._mapThemeID = mapThemeID
        self._isSheetShowing = isSheetShowing
    }
    
    var body: some View {
        
        NavigationView {
            Form {
                List {
                    
                    //marker layer
                    if self.mapLayers.mapThemes.filter({$0.hasAnnotations && $0.themeID == self.mapThemeID}).count != 0 {
                        Section {
                            Toggle(isOn: self.$mapLayers.mapThemes.filter({$0.themeID.wrappedValue == self.mapThemeID}).first!.annotationsAreToggled) {
                                HStack {
                                    Image(systemName: "mappin.circle.fill")
                                    Text(LocalizedStringKey("Marker to query data"))
                                }
                            }.toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
                        }
                    }
                    
                    //all overlay layers of the map
                    Section {
                        List(self.$mapLayers.rasterLayers.filter({$0.themeID.wrappedValue == self.mapThemeID})) { $layer in
                            Toggle(isOn: $layer.isToggled) {
                                HStack {
                                    layer.image
                                    Text(layer.name)
                                }
                            }.toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .principal, content: {
                    MalinkiSheetHeader(title: "Map Content", isSheetShowing: self.$isSheetShowing)
                })
            })
        }
    }
    
}

@available(iOS 15.0, *)
struct MalinkiMapContent_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiMapContent(mapThemeID: .constant(0), isSheetShowing: .constant(false))
            .environmentObject(MalinkiLayerContainer(layers: MalinkiConfigurationProvider.sharedInstance.getAllMapLayersArray(), themes: MalinkiConfigurationProvider.sharedInstance.getAllMapLayersArray().map({MalinkiTheme(themeID: $0.themeID)})))
    }
}
