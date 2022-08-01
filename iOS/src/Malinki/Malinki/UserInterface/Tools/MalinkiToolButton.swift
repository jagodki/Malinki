//
//  MalinkiToolButton.swift
//  Malinki
//
//  Created by Christoph Jung on 07.04.22.
//

import SwiftUI

/// A structur to show a menu button with several tools available.
@available(iOS 15.0, *)
struct MalinkiToolButton: View {
    
    @Binding var sheetState: MalinkiSheetState?
    @State private var showingActions: Bool = false
    
    var body: some View {
        Menu {
            //the search entry
            Button(action: {
                self.sheetState = .search
            }) {
                Text(LocalizedStringKey("Search"))
                Image(systemName: "magnifyingglass")
            }
            
            //the bookmarks entry
            Button(action: {
                self.sheetState = .bookmarks
            }) {
                Text(LocalizedStringKey("Bookmarks"))
                Image(systemName: "bookmark.fill")
            }
            
            //the annotations entry
            Button(action: {
                self.sheetState = .annotations
            }) {
                Text(LocalizedStringKey("Marker"))
                Image(systemName: "mappin.and.ellipse")
            }
            
            Divider()
            
            //the clean cache entry
            Button(action: {
                self.showingActions = true
            }) {
                Text(LocalizedStringKey("Clear Map Cache"))
                Image(systemName: "trash.fill")
            }
            
            //show the datasources
            Button(action: {
                self.sheetState = .datasources
            }) {
                Text(LocalizedStringKey("Datasources"))
                Image(systemName: "doc.plaintext")
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.title2)
                .foregroundColor(Color.primary)
                .padding()
        }.confirmationDialog(Text(LocalizedStringKey("All cached map tiles will be removed, i.e. map tiles will be requested from web services again after panning or zooming the map.")), isPresented: self.$showingActions, titleVisibility: .visible, actions: {
            Button("OK", role: .destructive) {
                let fm = FileManager.default
                let documentsUrl = fm.urls(for: .documentDirectory, in: .userDomainMask).first
                let cacheUrl = documentsUrl?.appendingPathComponent(MalinkiConfigurationProvider.sharedInstance.getCacheName())
                
                //clear cache
                do {
                    if let mapCacheUrl = cacheUrl {
                        _ = try fm.contentsOfDirectory(at: mapCacheUrl, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]).filter(\.hasDirectoryPath).map({try fm.removeItem(at: $0)})
                    }
                } catch {
                    print("ERROR - could not clear cache folder with tool button: \(error)")
                }
            }
        })
    }
}

@available(iOS 15.0, *)
struct MalinkiToolButton_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiToolButton(sheetState: .constant(.search))
    }
}
