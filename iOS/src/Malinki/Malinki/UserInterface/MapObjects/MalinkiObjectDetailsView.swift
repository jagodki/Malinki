//
//  MalinkiObjectDetailsView.swift
//  Malinki
//
//  Created by Christoph Jung on 12.07.21.
//

import SwiftUI
import SheeKit
import MapKit

@available(iOS 15.0, *)
struct MalinkiObjectDetailsView: View {
    
    @Binding private var isSheetShowing: Bool
    @Binding private var sheetDetent: UISheetPresentationController.Detent.Identifier?
    @EnvironmentObject var features: MalinkiFeatureDataContainer
    
    init(isSheetShowing: Binding<Bool>, sheetDetent: Binding<UISheetPresentationController.Detent.Identifier?>) {
        self._isSheetShowing = isSheetShowing
        self._sheetDetent = sheetDetent
    }
    
    var body: some View {
        
        if self.features.featureData.count == 0 {
            ProgressView("Loading...")
                .progressViewStyle(CircularProgressViewStyle())
        } else {
            NavigationView {
                List(self.$features.featureData) { $feature in
                    Section(header: Text(self.features.featureData.count > 1 ? feature.name : "Object Data")
                                .foregroundColor(.primary)
                                .fontWeight(.semibold)) {
                        ForEach(feature.data.sorted(by: >), id: \.key) { key, value in
                            VStack(alignment: .leading) {
                                Text(key)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(value)
                            }
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(content: {
                    ToolbarItem(placement: .principal, content: {
                        MalinkiSheetHeader(title: self.features.featureData.count > 1 ? "\(self.features.featureData[0].name) +\(self.features.featureData.count - 1)" : self.features.featureData.first?.name ?? "", isSheetShowing: self.$isSheetShowing, sheetDetent: self.$sheetDetent, subtitle: self.features.selectedAnnotation?.subtitle ?? "")
                    })
                })
            }
        }
        
    }
    
}

@available(iOS 15.0, *)
struct MalinkiObjectDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiObjectDetailsView(isSheetShowing: .constant(true), sheetDetent: .constant(UISheetPresentationController.Detent.Identifier.medium))
            .environmentObject(MalinkiFeatureDataContainer())
    }
}
