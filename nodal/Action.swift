//
//  Action.swift
//  nodal
//
//  Created by Devin Lehmacher on 5/8/17.
//  Copyright © 2017 Devin Lehmacher. All rights reserved.
//

import Foundation
import UIKit

typealias ActionProvider = () -> Action

protocol Action: Representable {
    func add(sample: SamplePoint)
    func add(predicted sample: SamplePoint)
    func finish() -> CanvasElement?
}

extension Action {
    // by default ignore predicted samples for all actions
    func add(predicted sample: SamplePoint) {}
}

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

class DrawLine: Action {
    var firstPoint: CGPoint? = nil
    var secondPoint: CGPoint? = nil
    var path: UIBezierPath {
        get {
            if let first = firstPoint, let second = secondPoint {
                let path = UIBezierPath()
                path.move(to: first)
                path.addLine(to: second)
                return path
            } else {
                return UIBezierPath()
            }
        }
    }

    func add(sample: SamplePoint) {
        if firstPoint == nil {
            firstPoint = sample.location
        } else {
            secondPoint = sample.location
        }
    }

    func finish() -> CanvasElement? {
        if let first = firstPoint, let second = secondPoint {
            let p1 = Point(x: Double(first.x), y: Double(first.y))
            let p2 = Point(x: Double(second.x), y: Double(second.y))
            let line = StraightLine(from: p1, to: p2)
            return line
        } else {
            return nil
        }
    }
}

class DrawSmoothLine: Action {
    var backingPath: UIBezierPath? = nil

    var path: UIBezierPath {
        get {
            if let path = backingPath {
                return path
            } else {
                return UIBezierPath()
            }
        }
    }

    func add(sample: SamplePoint) {
        if let path = backingPath {
            path.addLine(to: sample.location)
        } else {
            backingPath = UIBezierPath()
            backingPath!.move(to: sample.location)
        }
    }

    func finish() -> CanvasElement? {
        if let path = backingPath {
            return Path(path)
        } else {
            return nil
        }
    }
}
