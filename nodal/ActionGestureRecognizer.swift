//
//  ActionGestureRecognizer.swift
//  nodal
//
//  Created by Devin Lehmacher on 5/27/17.
//  Copyright © 2017 Devin Lehmacher. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

// the distance to ignore other touches within
let IGNORE_DIST = CGFloat(0.03)
let CANCELATION_INTERVAL = TimeInterval(0.1)

// recognizes Actions
class ActionGestureRecognizer: UIGestureRecognizer {
    // the action to perform on touches
    public var actionProvider: ActionProvider = { SlowAction(below: BroadLine(), interval: 1) }

    public var action: Action? {
        return trackingData?.action
    }

    enum TouchType {
        case pencil
        case finger
    }

    // accepted touch types
    var touchType: TouchType = .finger {
        didSet {
            switch touchType {
            case .pencil:
                allowedTouchTypes = [UITouchType.stylus.rawValue as NSNumber]
            case .finger:
                allowedTouchTypes = [UITouchType.direct.rawValue as NSNumber]
            }
        }
    }

    struct TrackingData {
        let action: Action
        let start: TimeInterval
        let touch: UITouch
        var lastLocation: CGPoint
    }

    // the initial touch that is now being tracked by this recognizer
    var trackingData: TrackingData? = nil

    // the timer for starting drawing
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
            if let sample = SamplePoint(for: touch, in: view!, prev: trackingData.lastLocation) {
                self.trackingData!.lastLocation = sample.location
                if touch.estimatedPropertiesExpectingUpdates.isEmpty {
                    trackingData.action.add(sample: sample)
                } else {
                    trackingData.action.add(estimated: sample,
                                            // there are estimated properties?
                                            with: touch.estimationUpdateIndex!)
                }
            }
        }

        if let predictedTouches = event.predictedTouches(for: trackingData.touch) {
            for touch in predictedTouches {
                if let sample = SamplePoint(for: touch, in: view!) {
                    // all estimated touches are temporary so we don't keep
                    // track of estimated properties
                    trackingData.action.add(predicted: sample)
                }
            }
        }

        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard trackingData == nil else {
            print("non-nil trackingData", trackingData!)
            return
        }

        if let firstTouch = touches.first {
            trackingData = TrackingData(action: actionProvider(),
                                        start: firstTouch.timestamp,
                                        touch: firstTouch,
                                        lastLocation: firstTouch.location(in: view!))

            if touchType != .pencil {
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

        if collect(touches: touches, event: event) {
            if touchType == .pencil {
                state = .began
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
        guard let action = trackingData?.action else {
            return
        }

        for touch in touches {
            // optimization oportunity, store the touches that needed updates
            // and make sure that this is one of them before constructing a
            // new SamplePoint
            if let sample = SamplePoint(for: touch, in: view!) {
                let updateIndex = touch.estimationUpdateIndex!
                // should we say an update is final if there are no
                // remaining updates expected? or could such a touch
                // still receive an update
                if touch.estimatedProperties.isEmpty {
                    action.update(final: sample, with: updateIndex)
                } else {
                    action.update(estimated: sample, with: updateIndex)
                }
            }
        }
    }

    override func reset() {
        trackingData = nil
        if let timer = startTimer {
            timer.invalidate()
            startTimer = nil
        }
        super.reset()
    }
}
