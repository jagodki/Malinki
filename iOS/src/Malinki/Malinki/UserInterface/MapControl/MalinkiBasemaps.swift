//
//  MalinkiButtonGroup.swift
//  Malinki
//
//  Created by Christoph Jung on 08.07.21.
//

import SwiftUI
import SheeKit

/// A struture to create a row of basemap buttons.
@available(iOS 15.0, *)
struct MalinkiBasemaps: View {
    
    @Binding private var basemapID: Int
    @Binding private var isSheetShowing: Bool
    @Binding private var sheetDetent: UISheetPresentationController.Detent.Identifier?
    
    /// The initialiser of this structure.
    /// - Parameters:
    ///   - basemapID: a binding containing the id of the toggled basemap
    ///   - isSheetShowing: a binding to control the visibility of a sheet
    ///   - sheetDetent: a binding to control the selected detent of a sheet
    init(basemapID: Binding<Int>, isSheetShowing: Binding<Bool>, sheetDetent: Binding<UISheetPresentationController.Detent.Identifier?>) {
        self._basemapID = basemapID
        self._isSheetShowing = isSheetShowing
        self._sheetDetent = sheetDetent
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
                    MalinkiSheetHeader(title: String(localized: "Basemaps"), isSheetShowing: self.$isSheetShowing, sheetDetent: self.$sheetDetent)
                })
            })
        }
    }
}

@available(iOS 15.0, *)
struct MalinkiButtonGroup_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiBasemaps(basemapID: .constant(0), isSheetShowing: .constant(false), sheetDetent: .constant(UISheetPresentationController.Detent.Identifier.medium))
    }
}
