//
//  MalinkiSheetHeader.swift
//  Malinki
//
//  Created by Christoph Jung on 15.12.21.
//

import SwiftUI
import SheeKit

/// A structure to present the header of a bottom sheet.
@available(iOS 15.0, *)
struct MalinkiSheetHeader: View {
    
    @Binding private var isSheetShowing: Bool
    @Binding private var sheetDetent: UISheetPresentationController.Detent.Identifier?
    private var title: String
    private var subtitle: String
    
    /// The initialiser of this struct.
    /// - Parameters:
    ///   - title: the title of the bottom sheet
    ///   - isSheetShowing: a binding indicating, whether the sheet is open or not
    ///   - sheetDetent: a binding to control the selected detent of a sheet
    init(title: String, isSheetShowing: Binding<Bool>, sheetDetent: Binding<UISheetPresentationController.Detent.Identifier?>, subtitle: String = "") {
        self.title = title
        self._isSheetShowing = isSheetShowing
        self._sheetDetent = sheetDetent
        self.subtitle = subtitle
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(LocalizedStringKey(self.title))
                    .font(.headline)
                
                if self.subtitle != "" {
                    Text(self.subtitle)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.leading)
            
            Spacer()
            
            Button(action: {
                self.sheetDetent = .medium
                self.isSheetShowing = false
            }) {
                Image(systemName: "xmark.circle.fill")
                    .padding(.trailing)
                    .foregroundColor(Color.secondary)
                    .font(.headline)
            }
        }
    }
}

@available(iOS 15.0, *)
struct MalinkiSheetHeader_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiSheetHeader(title: "Test", isSheetShowing: .constant(true), sheetDetent: .constant(UISheetPresentationController.Detent.Identifier.medium))
    }
}
