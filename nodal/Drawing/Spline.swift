//
//  Spline.swift
//  nodal
//
//  Created by Devin Lehmacher on 6/13/17.
//  Copyright © 2017 Devin Lehmacher. All rights reserved.
//

import UIKit


// core datatype for representing any sequence of points
// provides access neighbors in the sequence for the
// purpose of interpolation
class Spline: Sequence {
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
            pathL.addLine(to: sp.location)
            UIColor.blue.set()
            pathL.stroke()
            let pathR = UIBezierPath()
            pathR.move(to: sp.location)
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

    func makeIterator() -> SplinePointIterator {
        return SplinePointIterator(self)
    }
}

struct SplinePointIterator: IteratorProtocol {
    let spline: Spline
    var index = 0

    fileprivate var points: [SamplePoint] {
        return spline.points
    }

    var point: SamplePoint {
        return points[index]
    }

    var location: CGPoint {
        return point.location
    }

    init(_ spline: Spline) {
        self.spline = spline
    }

    mutating func next() -> SplinePoint? {
        guard inBounds(index) else { return nil }

        index += 1
        return SplinePoint(index: index - 1,
                           parent: self)
    }

    func inBounds(_ index: Int) -> Bool {
        return index >= 0
            && index < spline.points.count
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
    let index: Int // in bounds in the spline by invariant
    let parent: SplinePointIterator

    var neighbors: Neighbors {
        if parent.inBounds(index - 1) && parent.inBounds(index + 1) {
            return .preceedingAndFollowing(parent.points[index - 1], parent.points[index + 1])
        } else if parent.inBounds(index - 1) {
            return .preceedingOnly(parent.points[index - 1])
        } else if parent.inBounds(index + 1) {
            return .followingOnly(parent.points[index + 1])
        } else {
            return .noNeighbors
        }
    }

    // return a relative point if it exists
    // examples:
    // - p.relative(-1) = "the immediate prior point in the parent spline"
    // - p.relative(0) = p.point
    // - p.relative(1) = "the immediate next point in the parent spline"
    func relative(_ i: Int) -> SamplePoint? {
        if parent.inBounds(index + i) {
            return parent.points[index + i]
        } else {
            return nil
        }
    }

    var location: CGPoint {
        return parent.points[index].location
    }

    var force: CGFloat {
        return parent.points[index].force
    }

    func boundingDirections() -> (CGVector, CGVector) {
        let dleft: CGVector
        switch neighbors {
        case .noNeighbors:
            dleft = CGVector(magnitude: 1, angle: 0)
        case .followingOnly(let p):
            dleft = CGVector(from: location, to: p.location).perpendicular().intoUnit()
        case .preceedingOnly(let p):
            dleft = -1 * CGVector(from: location, to: p.location).perpendicular().intoUnit()
        case .preceedingAndFollowing(let first, let second):
            let prev = CGVector(from: first.location, to: location)
            let next = CGVector(from: location, to: second.location)
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
