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
    var width: CGFloat

    init(points: [SamplePoint], width: CGFloat) {
        self.points = points
        self.width = width
    }

    func draw() {
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
        path.lineWidth = 4
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
            neighbors = .middle(spline.points[index - 1], spline.points[index + 1])
            print("there are two!")
        } else if inBounds(index - 1) {
            neighbors = .end(spline.points[index - 1])
        } else if inBounds(index + 1) {
            neighbors = .start(spline.points[index + 1])
        } else {
            neighbors = .single
        }

        index += 1
        return SplinePoint(point: point,
                           neighbors: neighbors,
                           width: spline.width)
    }
}

enum Neighbors {
    case single
    case start(SamplePoint)
    case end(SamplePoint)
    case middle(SamplePoint, SamplePoint)
}

// a point and its neighbors
struct SplinePoint {
    let point: SamplePoint
    let neighbors: Neighbors
    let width: CGFloat

    func boundingPoints() -> (CGPoint, CGPoint) {
        let dleft: CGVector
        switch neighbors {
        case .single:
            dleft = CGVector(magnitude: width, angle: 0)
        case .start(let p):
            dleft = width * CGVector(from: point.location, to: p.location).perpendicular().intoUnit()
        case .end(let p):
            dleft = -width * CGVector(from: point.location, to: p.location).perpendicular().intoUnit()
        case .middle(let first, let second):
            let prev = CGVector(from: first.location, to: point.location)
            let next = CGVector(from: point.location, to: second.location)
            // points that are to the left are less than a 180˚ turn
            let isLeft = next.heading(relativeTo: prev) < CGFloat.pi
            if isLeft {
                dleft = width * CGVector.mean(prev.intoUnit(), next.intoUnit()).perpendicular()
            } else {
                dleft = -width * CGVector.mean(prev.intoUnit(), next.intoUnit()).perpendicular()
            }
        }
        let bounds = (point.location + dleft, point.location - dleft)
        print("bounding points!: ", bounds)
        return bounds
    }
}
