//
//  MalinkiOverrides.swift
//  Malinki
//
//  Created by Christoph Jung on 19.04.22.
//

import Foundation
import SwiftUI

public extension Text {
    func sectionHeaderStyle() -> some View {
        self
            .font(.system(.headline))
//            .fontWeight(.semibold)
            .foregroundColor(.primary)
            .textCase(nil)
    }
}
