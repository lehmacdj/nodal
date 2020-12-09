//
//  Action.swift
//  nodal
//
//  Created by Devin Lehmacher on 5/8/17.
//  Copyright © 2017 Devin Lehmacher. All rights reserved.
//

import UIKit

protocol SplineRecognizerDelegate {
    // the currently constructed spline
    var spline: Spline { get }
    // reset internal state to be ready to construct a new spline
    func reset()

    func add(sample: SamplePoint)

    func add(predicted samples: [SamplePoint])
    func clearPredicted()

    // add a sample that contains estimated data along
    // with a number that must be able to be used to
    // correspond to it
    func add(estimated sample: SamplePoint, with id: NSNumber)

    func update(estimated sample: SamplePoint, with id: NSNumber)
    func update(final sample: SamplePoint, with id: NSNumber)
}

// does no interpolation or smart elimination of points
class BasicBuilder: SplineRecognizerDelegate {
    var spline = Spline()

    func reset() {
        spline = Spline()
    }

    func add(sample: SamplePoint) {
        spline.points.append(sample)
    }

    func add(predicted samples: [SamplePoint]) {}
    func clearPredicted() {}

    func add(estimated sample: SamplePoint, with id: NSNumber) {
        add(sample: sample)
    }

    func update(estimated sample: SamplePoint, with id: NSNumber) {}
    func update(final sample: SamplePoint, with id: NSNumber) {}
}

// keeps track of only the first and last point in the spline
// ignoring everything else
class TwoPointBuilder: SplineRecognizerDelegate {
    var spline = Spline()
    // nil if spline is finalized/ doesn't contain predicted points,
    // otherwise the last confirmed point
    private var finalPoint: SamplePoint?

    // estimation id numbers for the first and second point
    private var estimationId1: NSNumber?
    private var estimationId2: NSNumber?

    func reset() {
        spline = Spline()
        estimationId1 = nil
        estimationId2 = nil
        finalPoint = nil
    }

    func add(sample: SamplePoint) {
        if spline.points.count < 2 {
            spline.points.append(sample)
        } else {
            spline.points[1] = sample
        }
        finalPoint = nil
    }

    func add(predicted samples: [SamplePoint]) {
        guard spline.points.count > 0 else {
            fatalError("at least one UITouch should exist before adding any predicted samples")
        }

        if spline.points.count >= 2 {
            finalPoint = spline.points[1]
        }
        if let last = samples.last {
            add(sample: last)
        }
    }

    func clearPredicted() {
        if let sample = finalPoint {
            add(sample: sample)
        }
    }

    func add(estimated sample: SamplePoint, with id: NSNumber) {
        if spline.points.count == 0 {
            estimationId1 = id
        } else {
            estimationId2 = id
        }
        add(sample: sample)
    }

    func update(estimated sample: SamplePoint, with id: NSNumber) {
        if id == estimationId1 {
            spline.points[0] = sample
        } else if id == estimationId2 {
            if finalPoint == nil {
                spline.points[1] = sample
            } else {
                finalPoint = sample
            }
        }
    }

    func update(final sample: SamplePoint, with id: NSNumber) {
        if id == estimationId1 {
            spline.points[0] = sample
            estimationId1 = nil
        } else if id == estimationId2 {
            if finalPoint == nil {
                spline.points[1] = sample
            } else {
                finalPoint = sample
            }
            estimationId2 = nil
        }
    }
}

// does all the necessary things but nothing fancy to deduplicate points
class DecentBuilder: SplineRecognizerDelegate {
    var spline = Spline()

    // map index to the index in `points` that contains the data for the corresponding UITouch
    var estimationMap = [NSNumber:Int]()

    var nPredictedPoints: Int = 0

    func reset() {
        spline = Spline()
        estimationMap = [NSNumber:Int]()
        nPredictedPoints = 0
    }

    func add(sample: SamplePoint) {
        clearPredicted()
        spline.points.append(sample)
    }

    func add(predicted samples: [SamplePoint]) {
        clearPredicted()
        spline.points.append(contentsOf: samples)
        nPredictedPoints = samples.count
    }

    // this function should be called before sending the spline off to somewhere else
    func clearPredicted() {
        spline.points.removeLast(nPredictedPoints)
        nPredictedPoints = 0
    }

    func add(estimated sample: SamplePoint, with id: NSNumber) {
        clearPredicted()
        let index = spline.points.count
        spline.points.append(sample)
        estimationMap[id] = index
    }

    func update(estimated sample: SamplePoint, with id: NSNumber) {
        clearPredicted()
        if let index = estimationMap[id] {
            spline.points[index] = sample
        }
    }

    func update(final sample: SamplePoint, with id: NSNumber) {
        clearPredicted()
        if let index = estimationMap[id] {
            spline.points[index] = sample
            estimationMap.removeValue(forKey: id)
        }
    }
}

// an action that intentionally undersamples from the gesture recognizer
class SlowSplineRecognizerDelegate: SplineRecognizerDelegate {
    var spline: Spline {
        return below.spline
    }

    var below: SplineRecognizerDelegate
    var touches = 0
    var registered = Set<NSNumber>()
    let interval: Int

    func reset() {
        below.reset()
        touches = 0
        registered.removeAll()
    }

    convenience init(below delegate: SplineRecognizerDelegate) {
        self.init(below: delegate, interval: 20)
    }

    init(below delegate: SplineRecognizerDelegate, interval: Int) {
        below = delegate
        self.interval = interval
    }

    func add(sample: SamplePoint) {
        if touches % interval == 0 {
            below.add(sample: sample)
        }
        touches += 1
    }

    func add(predicted samples: [SamplePoint]) {
        var predictedPoints = 0
        let undersampledSamples = samples.makeIterator().filter { _ in
            predictedPoints += 1
            return predictedPoints % interval == 0
        }
        below.add(predicted: undersampledSamples)
    }

    func clearPredicted() {
        below.clearPredicted()
    }

    func add(estimated sample: SamplePoint, with id: NSNumber) {
        if touches % interval == 0 {
            registered.insert(id)
            below.add(estimated: sample, with: id)
        }
        touches += 1
    }

    func update(estimated sample: SamplePoint, with id: NSNumber) {
        if registered.contains(id) {
            below.update(estimated: sample, with: id)
        }
    }

    func update(final sample: SamplePoint, with id: NSNumber) {
        if registered.contains(id) {
            below.update(final: sample, with: id)
        }
    }
}
