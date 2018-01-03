//
//  Sample.swift
//  nodal
//
//  Created by Devin Lehmacher on 6/6/17.
//  Copyright © 2017 Devin Lehmacher. All rights reserved.
//

import Foundation
import UIKit

enum SampleData {
    case touch
    case touch3D(force: CGFloat)
    case pencil(force: CGFloat,
                altitude: CGFloat,
                azimuth: CGFloat)
}

struct SamplePoint {
    let timestamp: TimeInterval
    let location: CGPoint
    var data: SampleData

    init?(for touch: UITouch, in view: UIView, prev point: CGPoint) {
        self.location = touch.preciseLocation(in: view)
        self.timestamp = touch.timestamp

        guard CGVector(from: self.location, to: point).quadrance > IGNORE_DIST else {
            return nil
        }

        let hasForceTouch = view.traitCollection.forceTouchCapability == .available
        switch touch.type {
        case .direct where hasForceTouch:
            self.data = .touch3D(force: touch.force)
        case .direct where !hasForceTouch:
            self.data = .touch
        case .stylus:
            self.data = .pencil(force: touch.force,
                           altitude: touch.altitudeAngle,
                           azimuth: touch.azimuthAngle(in: view))
        default:
            return nil
        }
    }

    init?(for touch: UITouch, in view: UIView) {
        self.location = touch.preciseLocation(in: view)
        self.timestamp = touch.timestamp
        let hasForceTouch = view.traitCollection.forceTouchCapability == .available
        switch touch.type {
        case .direct where hasForceTouch:
            self.data = .touch3D(force: touch.force)
        case .direct where !hasForceTouch:
            self.data = .touch
        case .stylus:
            self.data = .pencil(force: touch.force,
                           altitude: touch.altitudeAngle,
                           azimuth: touch.azimuthAngle(in: view))
        default:
            return nil
        }
    }
}
