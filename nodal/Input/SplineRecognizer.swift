//
//  ActionGestureRecognizer.swift
//  nodal
//
//  Created by Devin Lehmacher on 5/27/17.
//  Copyright © 2017 Devin Lehmacher. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

// recognizes Actions
class SplineRecognizer: UIGestureRecognizer {
    // since the recognizer is disabled when the delegate is nil it is safe
    // to implicitly unwrap the delegate
    public var splineRecognizerDelegate: SplineRecognizerDelegate! {
        didSet {
            if splineRecognizerDelegate == nil {
                isEnabled = false
            } else {
                isEnabled = true
            }
        }
    }

    // accepted touch types
    var touchType: TouchType = .finger {
        didSet {
            touchTypes = [touchType]
        }
    }

    struct TrackingData {
        let start: TimeInterval
        let touch: UITouch
        var lastSample: SamplePoint
    }

    // the initial touch that is now being tracked by this recognizer
    var trackingData: TrackingData? = nil

    // the timer for starting drawing
    // we only use this for fingers, because the pencil is precise enough that we should be able
    // to assume that any touch is intentional.
    var startTimer: Timer? = nil

    // add a touch to the current action if it exists
    private func collect(touches: Set<UITouch>, event: UIEvent?) -> Bool {
        guard let trackingData = self.trackingData else {
            return false
        }

        guard touches.contains(trackingData.touch) else {
            return false
        }

        for touch in touches {
            if touch !== trackingData.touch &&
               touch.timestamp - trackingData.start < CANCELATION_INTERVAL {
                // we have a second finger touch, at the same time
                // this cancels the drawing of a line with the finger
                // otherwise the data would come from the same recognizer
                if state == .possible {
                    state = .failed
                } else {
                    state = .cancelled
                }
                return false
            }
        }

        guard let event = event else {
            return true
        }

        for touch in event.coalescedTouches(for: trackingData.touch)! {
            if let sample = SamplePoint(for: touch, in: view!, prev: trackingData.lastSample) {
                self.trackingData!.lastSample = sample
                if touch.estimatedPropertiesExpectingUpdates.isEmpty {
                    splineRecognizerDelegate.add(sample: sample)
                } else {
                    splineRecognizerDelegate.add(estimated: sample,
                                            // there are estimated properties?
                                            with: touch.estimationUpdateIndex!)
                }
            }
        }

        if let predictedTouches = event.predictedTouches(for: trackingData.touch) {
            let predicted = predictedTouches.map { SamplePoint(for: $0, in: view!) }
            splineRecognizerDelegate.add(predicted: predicted)
        }

        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard trackingData == nil else {
            print("non-nil trackingData", trackingData!)
            return
        }

        if let firstTouch = touches.first {
            // the action should exist if we got a touches began, because
            // we disable the action recognizer when the provider is nil
            trackingData = TrackingData(start: firstTouch.timestamp,
                                        touch: firstTouch,
                                        lastSample: SamplePoint(for: firstTouch, in: view!))
        }

        if collect(touches: touches, event: event) {
            if touchType == .pencil {
                state = .began
            } else {
                startTimer = Timer.scheduledTimer(
                    withTimeInterval: CANCELATION_INTERVAL,
                    repeats: false,
                    block: { timer in
                        if self.state == .possible {
                            self.state = .began
                        }
                })
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if collect(touches: touches, event: event) {
            if state == .began {
                state = .changed
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if collect(touches: touches, event:event) {
            state = .ended
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if collect(touches: touches, event: event) {
            state = .failed
        }
    }

    override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
        for touch in touches {
            // optimization oportunity, store the touches that needed updates
            // and make sure that this is one of them before constructing a
            // new SamplePoint
            let sample = SamplePoint(for: touch, in: view!)
            let updateIndex = touch.estimationUpdateIndex!
            // should we say an update is final if there are no
            // remaining updates expected? or could such a touch
            // still receive an update
            if touch.estimatedProperties.isEmpty {
                splineRecognizerDelegate.update(final: sample, with: updateIndex)
            } else {
                splineRecognizerDelegate.update(estimated: sample, with: updateIndex)
            }
        }
    }

    override func reset() {
        trackingData = nil
        splineRecognizerDelegate.reset()
        if let timer = startTimer {
            timer.invalidate()
            startTimer = nil
        }
        super.reset()
    }
}
