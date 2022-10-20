//
//  MalinkiMapContent.swift
//  Malinki
//
//  Created by Christoph Jung on 09.08.21.
//

import SwiftUI
import SheeKit

/// A structure to present and control the map content/layers.
@available(iOS 15.0, *)
struct MalinkiMapContent: View {
    
    @EnvironmentObject var mapLayers: MalinkiLayerContainer
    @Binding private var sheetDetent: UISheetPresentationController.Detent.Identifier?
    @Binding private var isSheetShowing: Bool
    
    /// The initialiser of this sctructure.
    /// - Parameters:
    ///   - isSheetShowing: a binding to control the presentation of a sheet
    ///   - sheetDetent: a binding to control the selected detent of a sheet
    init(isSheetShowing: Binding<Bool>, sheetDetent: Binding<UISheetPresentationController.Detent.Identifier?>) {
        self._isSheetShowing = isSheetShowing
        self._sheetDetent = sheetDetent
    }
    
    var body: some View {
        
        NavigationView {
            Form {
                List {
                    
                    //marker layer
                    if self.mapLayers.mapThemes.filter({$0.hasAnnotations && $0.themeID == self.mapLayers.selectedMapThemeID}).count != 0 {
                        Section {
                            Toggle(isOn: self.$mapLayers.mapThemes.filter({$0.themeID.wrappedValue == self.mapLayers.selectedMapThemeID}).first!.annotationsAreToggled) {
                                HStack {
                                    Image(systemName: "mappin.circle.fill")
                                    Text(LocalizedStringKey("Marker to query data"))
                                }
                            }.toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
                        }
                    }
                    
                    //all overlay layers of the map
                    Section {
                        List(self.$mapLayers.rasterLayers.filter({$0.themeID.wrappedValue == self.mapLayers.selectedMapThemeID})) { $layer in
                            Toggle(isOn: $layer.isToggled) {
                                HStack {
                                    NavigationLink(destination: MalinkiLegendView(title: layer.name, mapTheme: layer.themeID, layerID: layer.id)) {
                                        layer.image
                                            .foregroundColor(.accentColor)
                                        Text(layer.name)
                                    }
                                }
                            }.toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .principal, content: {
                    MalinkiSheetHeader(title: "Map Content", isSheetShowing: self.$isSheetShowing, sheetDetent: self.$sheetDetent)
                })
            })
        }
    }
    
}

@available(iOS 15.0, *)
struct MalinkiMapContent_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiMapContent(isSheetShowing: .constant(false), sheetDetent: .constant(UISheetPresentationController.Detent.Identifier.medium))
            .environmentObject(MalinkiLayerContainer(layers: MalinkiConfigurationProvider.sharedInstance.getAllMapLayersArray(), themes: MalinkiConfigurationProvider.sharedInstance.getAllMapLayersArray().map({MalinkiTheme(themeID: $0.themeID)}), selectedMapThemeID: 0))
    }
}
