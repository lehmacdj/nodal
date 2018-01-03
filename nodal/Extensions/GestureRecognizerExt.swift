//
//  GestureRecognizerExt.swift
//  nodal
//
//  Created by Devin Lehmacher on 1/1/18.
//  Copyright © 2018 Devin Lehmacher. All rights reserved.
//

import UIKit

extension UIGestureRecognizer {
    var touchTypes: [TouchType] {
        get {
            return allowedTouchTypes.flatMap(TouchType.fromNSNumber)
        }

        set {
            allowedTouchTypes = newValue.map(TouchType.toNSNumber)
        }
    }
}
