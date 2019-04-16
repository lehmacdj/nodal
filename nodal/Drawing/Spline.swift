//
//  Spline.swift
//  nodal
//
//  Created by Devin Lehmacher on 6/13/17.
//  Copyright © 2017 Devin Lehmacher. All rights reserved.
//

import UIKit

// core datatype for representing any kind of drawn line
class Spline {
    var points: [SamplePoint]

    convenience init() {
        self.init(points: [])
    }

    init(points: [SamplePoint]) {
        self.points = points
    }

    // draw the spline in the rectangle
    // (without modifying the coordinates of any of the points)
    func draw(_ rect: CGRect) {
        for sp in self {
            let (left, right) = sp.boundingPoints()
            let pathL = UIBezierPath()
            pathL.move(to: left)
            pathL.addLine(to: sp.point.location)
            UIColor.blue.set()
            pathL.stroke()
            let pathR = UIBezierPath()
            pathR.move(to: sp.point.location)
            pathR.addLine(to: right)
            UIColor.red.set()
            pathR.stroke()
        }

        let path = UIBezierPath()
        var first = true
        for p in points {
            if first {
                path.move(to: p.location)
                first = false
            } else {
                path.addLine(to: p.location)
            }
        }

        UIColor.green.set()
        path.lineWidth = 1
        path.stroke()
        UIColor.black.set()
    }
}

extension Spline: Sequence {
    func makeIterator() -> SplinePointIterator {
        return SplinePointIterator(self)
    }
}

struct SplinePointIterator: IteratorProtocol {
    let spline: Spline
    var index = 0

    init(_ spline: Spline) {
        self.spline = spline
    }

    func inBounds(_ index: Int) -> Bool {
        return index >= 0
            && index < spline.points.count
    }

    mutating func next() -> SplinePoint? {
        guard inBounds(index) else { return nil }

        let point = spline.points[index]
        let neighbors: Neighbors
        if inBounds(index - 1) && inBounds(index + 1) {
            neighbors = .preceedingAndFollowing(spline.points[index - 1], spline.points[index + 1])
        } else if inBounds(index - 1) {
            neighbors = .preceedingOnly(spline.points[index - 1])
        } else if inBounds(index + 1) {
            neighbors = .followingOnly(spline.points[index + 1])
        } else {
            neighbors = .noNeighbors
        }

        index += 1
        return SplinePoint(point: point,
                           neighbors: neighbors)
    }
}

enum Neighbors {
    case noNeighbors
    case followingOnly(SamplePoint)
    case preceedingOnly(SamplePoint)
    case preceedingAndFollowing(SamplePoint, SamplePoint)
}

// a point and its neighbors
struct SplinePoint {
    let point: SamplePoint
    let neighbors: Neighbors

    var location: CGPoint {
        return point.location
    }

    // a normalized force factor that can be used to modify the width of lines
    var force: CGFloat {
        let protoForce: CGFloat
        switch point.data {
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

    func boundingDirections() -> (CGVector, CGVector) {
        let dleft: CGVector
        switch neighbors {
        case .noNeighbors:
            dleft = CGVector(magnitude: 1, angle: 0)
        case .followingOnly(let p):
            dleft = CGVector(from: point.location, to: p.location).perpendicular().intoUnit()
        case .preceedingOnly(let p):
            dleft = -1 * CGVector(from: point.location, to: p.location).perpendicular().intoUnit()
        case .preceedingAndFollowing(let first, let second):
            let prev = CGVector(from: first.location, to: point.location)
            let next = CGVector(from: point.location, to: second.location)
            // points that are to the left are less than a 180˚ turn
            let isLeft = next.heading(relativeTo: prev) < CGFloat.pi
            if isLeft {
                dleft = CGVector.mean(prev, next).perpendicular().intoUnit()
            } else {
                dleft = -1 * CGVector.mean(prev, next).perpendicular().intoUnit()
            }
        }

        return (dleft, -1 * dleft)
    }

    func boundingPoints() -> (CGPoint, CGPoint) {
        let (dleft, dright) = self.boundingDirections()
        return (self.location + dleft, self.location + dright)
    }
}
