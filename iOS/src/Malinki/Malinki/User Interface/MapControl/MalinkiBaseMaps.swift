//
//  MalinkiButtonGroup.swift
//  Malinki
//
//  Created by Christoph Jung on 08.07.21.
//

import SwiftUI

struct MalinkiBasemaps: View {
    
//    private var columns: [GridItem] = [GridItem(.flexible()),
//                                       GridItem(.flexible()),
//                                       GridItem(.flexible()),
//                                       GridItem(.flexible())]
//    private var columns: [GridItem] {
//        var gridItems: [GridItem] = []
//        let countOfBasemaps = MalinkiConfigurationProvider.sharedInstance.configData?.basemaps.count ?? 0
//
//        for _ in 0...countOfBasemaps {
//            gridItems.append(GridItem(.flexible()))
//        }
//
//        return gridItems
//    }
    
    var columns: [GridItem] =
        Array(repeating: .init(.flexible()), count: MalinkiConfigurationProvider.sharedInstance.configData?.basemaps.count ?? 0)
    
    var body: some View {
        LazyVGrid(columns: self.columns, spacing: 2, pinnedViews: []) {
            
            ForEach(MalinkiConfigurationProvider.sharedInstance.configData?.basemaps ?? [], id: \.id) { basemap in
                MalinkiBasemapButton(isToggled: .constant(basemap.onStartUp), imageName: basemap.imageName, basemapName: basemap.externalNames.de)
            }
            
        }
        
    }
}

struct MalinkiButtonGroup_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiBasemaps()
    }
}
