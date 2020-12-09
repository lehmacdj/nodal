//
//  Locatable.swift
//  nodal
//
//  Created by Devin Lehmacher on 5/5/19.
//  Copyright © 2019 Devin Lehmacher. All rights reserved.
//

import Foundation
import CoreGraphics

// eventually want to generalize to a more infinite
// coordinate system
protocol Locatable {
    var location: CGPoint { get }
    var size: CGSize { get }
}

extension Locatable {
    var frame: CGRect {
        return CGRect(origin: location, size: size)
    }
}
