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

    init?(for touch: UITouch, in view: UIView, prev sample: SamplePoint) {
        self.init(for: touch, in: view, prev: sample.location)

        guard abs(self.force - sample.force) < IGNORE_FORCE else {
            return nil
        }
    }

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

    // a normalized force factor that can be used to modify the width of lines
    var force: CGFloat {
        let protoForce: CGFloat
        switch data {
        case let .pencil(force: force, altitude: altitude, azimuth: _):
            protoForce = force * sin(altitude)
        case .touch3D(let force):
            protoForce = force
        case .touch:
            protoForce = 1.0
        }

        // TODO: some kind of restriction of the domain to be more
        // regular. Right now the value could be anywhere from 0 to infinity
        return protoForce
    }
}
