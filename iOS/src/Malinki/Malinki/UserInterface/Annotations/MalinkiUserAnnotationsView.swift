//
//  MalinkiUserAnnotationsView.swift
//  Malinki
//
//  Created by Christoph Jung on 23.06.22.
//

import SwiftUI
import MapKit
import SheeKit

@available(iOS 15.0.0, *)
struct MalinkiUserAnnotationsView: View {
    
    @EnvironmentObject var mapLayers: MalinkiLayerContainer
    @EnvironmentObject var mapRegion: MalinkiMapRegion
    
    @Binding private var sheetState: UISheetPresentationController.Detent.Identifier?
    @Binding private var isSheetShowing: Bool
    
    private var config = MalinkiConfigurationProvider.sharedInstance
    
    @State private var actionType: BookmarkActionType = .insert
    @State private var uuidString: String = ""
    @State private var showAlert: Bool = false
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

@available(iOS 15.0.0, *)
struct MalinkiUserAnnotationsView_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiUserAnnotationsView()
    }
}
