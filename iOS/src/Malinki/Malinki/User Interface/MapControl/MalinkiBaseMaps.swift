//
//  MalinkiButtonGroup.swift
//  Malinki
//
//  Created by Christoph Jung on 08.07.21.
//

import SwiftUI

/// A struture to create a row of basemap buttons.
@available(iOS 15.0, *)
struct MalinkiBasemaps: View {
    
    @Binding private var basemapID: Int
    @Binding private var sheetState: MalinkiSheet.State?
    
    /// The initialiser of this structure.
    /// - Parameter basemapID: a binding containing the id of the toggled basemap
    /// - Parameter showBasemapsSheet: a binding to close the basemap sheet
    init(basemapID: Binding<Int>, sheetState: Binding<MalinkiSheet.State?>) {
        self._basemapID = basemapID
        self._sheetState = sheetState
    }
    
    /// The columns for creating a lazy grid.
    private var columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        
        NavigationView {
            ScrollView {
                LazyVGrid(columns: self.columns, spacing: 2, pinnedViews: []) {
                    
                    ForEach(MalinkiConfigurationProvider.sharedInstance.getBasemaps(), id: \.id) { basemap in
                        MalinkiBasemapButton(toggledBasemapID: self.$basemapID, imageName: basemap.imageName, basemapName: basemap.externalNames.de, id: basemap.id).padding()
                    }
                }
            }
            .background(Color(uiColor: .systemGray6))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .principal, content: {
                    HStack {
                        Text(LocalizedStringKey("Basemaps"))
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
struct MalinkiButtonGroup_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiBasemaps(basemapID: .constant(0), sheetState: .constant(MalinkiSheet.State?.none))
    }
}
