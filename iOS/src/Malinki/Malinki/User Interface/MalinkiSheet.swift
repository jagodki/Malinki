//
//  MalinkiSheetType.swift
//  Malinki
//
//  Created by Christoph Jung on 31.10.21.
//

import Foundation

class MalinkiSheet: MalinkiSheetState<MalinkiSheet.State> {
    
    enum State {
        case basemaps
        case layers
        case details
    }
    
}
