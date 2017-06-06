//
//  Action.swift
//  nodal
//
//  Created by Devin Lehmacher on 5/8/17.
//  Copyright © 2017 Devin Lehmacher. All rights reserved.
//

import UIKit

typealias ActionProvider = () -> Action

protocol Action {
    func add(sample: SamplePoint)
    func add(predicted sample: SamplePoint)
    // add a sample that contains estimated data along
    // with a number that must be able to be used to 
    // correspond to it
    func add(estimated sample: SamplePoint, with id: NSNumber)

    func clearPredicted()

    func update(estimated sample: SamplePoint, with id: NSNumber)
    func update(final sample: SamplePoint, with id: NSNumber)

    func finish() -> CanvasElement?
}

// implements a default for Action's that do not need to use predicted
// touches or update estimated data
// this is necessary because swift doesn't support dynamic dispatch for
// protocols, so we can't simply provide a default implementation and then
// override it
protocol SimpleAction: Action {}
extension SimpleAction {
    func add(predicted sample: SamplePoint) {}
    func clearPredicted() {}

    func add(estimated sample: SamplePoint, with id: NSNumber) {
        self.add(sample: sample)
    }
    func update(estimated sample: SamplePoint, with id: NSNumber) {}
    func update(final sample: SamplePoint, with id: NSNumber) {}
}


class DrawStraightLine: SimpleAction {
    var firstPoint: CGPoint? = nil
    var secondPoint: CGPoint? = nil

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

extension DrawStraightLine: Representable {
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
}

class DrawPrimitiveLine: SimpleAction {
    var backingPath: UIBezierPath? = nil

    var path: UIBezierPath {
        if let path = backingPath {
            return path
        } else {
            return UIBezierPath()
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

extension DrawPrimitiveLine: Representable {}

// a simple class that returns a basis for strokes that draw different kinds
// of lines based on a sequence of points
// subclasses should override finish to produce the correct canvas element
class BuildStroke: Action {
    var points = [SamplePoint]()

    // map index to the index in `points` that contains the data for the corresponding UITouch
    var estimationMap = [NSNumber:Int]()

    var predictedPoints = [SamplePoint]()

    func add(sample: SamplePoint) {
        points.append(sample)
    }

    func add(predicted sample: SamplePoint) {
        predictedPoints.append(sample)
    }

    func clearPredicted() {
        predictedPoints.removeAll()
    }

    func add(estimated sample: SamplePoint, with id: NSNumber) {
        let index = points.count
        points.append(sample)
        estimationMap[id] = index
    }

    func update(estimated sample: SamplePoint, with id: NSNumber) {
        if let index = estimationMap[id] {
            points[index] = sample
        }
    }

    func update(final sample: SamplePoint, with id: NSNumber) {
        if let index = estimationMap[id] {
            points[index] = sample
            estimationMap.removeValue(forKey: id)
        }
    }

    func finish() -> CanvasElement? {
        return nil
    }
}
