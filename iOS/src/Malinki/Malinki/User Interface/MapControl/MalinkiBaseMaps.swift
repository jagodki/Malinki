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
    
    /// The initialiser of this structure.
    /// - Parameter basemapID: a binding containing the id of the toggled basemap
    init(basemapID: Binding<Int>) {
        self._basemapID = basemapID
    }
    
    /// The columns for creating a lazy grid.
    //    private var columns: [GridItem] =
    //        Array(repeating: .init(.flexible()), count: MalinkiConfigurationProvider.sharedInstance.getBasemaps().count)
    private var columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        VStack {
            
            Rectangle()
                .frame(width: 50, height: 5, alignment: .center)
                .foregroundColor(Color.secondary)
                .cornerRadius(20)
            
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
        MalinkiBasemaps(basemapID: .constant(0))
    }
}
