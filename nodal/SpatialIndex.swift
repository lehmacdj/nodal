//
//  VectorStore.swift
//  nodal
//
//  Created by Devin Lehmacher on 5/5/19.
//  Copyright © 2019 Devin Lehmacher. All rights reserved.
//

import Foundation
import CoreGraphics

// eventually want this to be a thin wrapper around a haskell
// implementation of a R+ tree
class SpatialIndex {
    var elements = [Locatable]()

    func add(_ object: Locatable) {
        elements.append(object)
    }

    func inBounds(_ bounds: CGRect) -> [Locatable] {
        return elements.filter { x in
            // can complicate this to clip out things that barely overlap
            // or their overlap is too large/too small
            bounds.intersects(x.frame)
        }
    }
}
