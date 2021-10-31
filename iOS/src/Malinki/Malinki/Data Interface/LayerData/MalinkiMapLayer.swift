//
//  MalinkiMapLayer.swift
//  Malinki
//
//  Created by Christoph Jung on 09.08.21.
//

import SwiftUI
import Combine

/// A structure to descripe a map layer.
final class MalinkiMapLayer: Hashable, Identifiable, ObservableObject {
    
    let id: Int
    let name: String
    let image: Image
    var isToggled: Binding<Bool>
//    @Published var isToggled: Bool = true
    let themeID: Int
    let uuid: UUID
    
    /// The initialiser of this structure.
    /// - Parameters:
    ///   - id: the ID of the map layer
    ///   - name: the external name of the map layer
    ///   - imageName: the image name of the map layer
    ///   - themeID: the id of the corresponding map theme
    init(id: Int, name: String, imageName: String, themeID: Int) {
        self.id = id
        self.name = name
        self.image = Image(systemName: imageName)
        self.uuid = UUID()
        self.themeID = themeID
        let toggled = CurrentValueSubject<Bool, Never>(true)
        self.isToggled = Binding<Bool> (
            get: {toggled.value},
            set: {toggled.value = $0}
        )
    }
    
    static func == (lhs: MalinkiMapLayer, rhs: MalinkiMapLayer) -> Bool {
        return lhs.id == rhs.id && lhs.uuid == rhs.uuid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
        hasher.combine(self.uuid)
    }
}
