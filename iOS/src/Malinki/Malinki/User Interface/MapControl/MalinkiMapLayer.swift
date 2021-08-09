//
//  MalinkiMapLayer.swift
//  Malinki
//
//  Created by Christoph Jung on 09.08.21.
//

import SwiftUI

/// A structure to descripe a map layer.
struct MalinkiMapLayer {
    let name: String
    let image: Image
    @State var isToggled: Bool
}
