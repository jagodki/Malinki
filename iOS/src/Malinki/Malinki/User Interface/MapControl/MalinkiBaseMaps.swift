//
//  MalinkiButtonGroup.swift
//  Malinki
//
//  Created by Christoph Jung on 08.07.21.
//

import SwiftUI

/// A struture to create a row of basemap buttons.
struct MalinkiBasemaps: View {
    
    @Binding private var basemapID: Int
    @Binding private var showBasemapsSheet: Bool
    
    /// The initialiser of this structure.
    /// - Parameter basemapID: a binding containing the id of the toggled basemap
    init(basemapID: Binding<Int>, showBasemapsSheet: Binding<Bool>) {
        self._basemapID = basemapID
        self._showBasemapsSheet = showBasemapsSheet
    }
    
    /// The columns for creating a lazy grid.
    private var columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        VStack {
            
            HStack {
                
                Text(LocalizedStringKey("Basemaps"))
                    .font(.headline)
                    .padding(.leading)
                
                Spacer()
                
                Button(action: {self.showBasemapsSheet = false}) {
                    Image(systemName: "xmark.circle.fill")
                        .padding(.trailing)
                        .foregroundColor(Color.secondary)
                        .font(.system(size: 20))
                }
            }
            
            Divider()
            
            ScrollView {
                LazyVGrid(columns: self.columns, spacing: 2, pinnedViews: []) {
                    
                    ForEach(MalinkiConfigurationProvider.sharedInstance.getBasemaps(), id: \.id) { basemap in
                        MalinkiBasemapButton(toggledBasemapID: self.$basemapID, imageName: basemap.imageName, basemapName: basemap.externalNames.de, id: basemap.id).padding()
                    }
                    
                }
            }
        }
    }
}

struct MalinkiButtonGroup_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiBasemaps(basemapID: .constant(0), showBasemapsSheet: .constant(true))
    }
}
