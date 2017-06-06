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
let IGNORE_DIST = 0.003
let CANCELATION_INTERVAL = TimeInterval(0.1)

// recognizes Actions
class ActionGestureRecognizer: UIGestureRecognizer {
    // the action to perform on touches
    public var actionProvider: ActionProvider = { DrawSmoothLine() }

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
    }

    // the initial touch that is now being tracked by this recognizer
    var trackingData: TrackingData? = nil

    // the timer for starting drawing
    var startTimer: Timer? = nil

    // add a touch to the current action if it exists
    private func collect(touches: Set<UITouch>, event: UIEvent?) -> Bool {
        guard self.trackingData != nil else {
            return false
        }

        let trackingData = self.trackingData!

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

        guard event != nil else {
            return true
        }

        let event = event!

        for touch in event.coalescedTouches(for: trackingData.touch)! {
            if let sample = SamplePoint(for: touch, in: view!) {
                trackingData.action.add(sample: sample)
            }
        }

        if let predictedTouches = event.predictedTouches(for: trackingData.touch) {
            for touch in predictedTouches {
                if let sample = SamplePoint(for: touch, in: view!) {
                    trackingData.action.add(predicted: sample)
                }
            }
        }

        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesBegan!")
        guard trackingData == nil else {
            print("non-nil trackingData", trackingData!)
            return
        }

        if let firstTouch = touches.first {
            trackingData = TrackingData(action: actionProvider(),
                                        start: firstTouch.timestamp,
                                        touch: firstTouch)

            if touchType != .pencil {
                print("begining timer!")
                startTimer = Timer.scheduledTimer(
                    withTimeInterval: CANCELATION_INTERVAL,
                    repeats: false,
                    block: { timer in
                        print("timer fired!")
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
        print("touchesMoved!")
        if collect(touches: touches, event: event) {
            if state == .began {
                state = .changed
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesEnded!")
        if collect(touches: touches, event:event) {
            state = .ended
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesCancelled!")
        if collect(touches: touches, event: event) {
            state = .failed
        }
    }

    override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
        print("touchesEstimatedPropertiesUpdated!")
        // currently we don't support updating the estimated properties
    }

    override func reset() {
        print("reset!")
        trackingData = nil
        if let timer = startTimer {
            timer.invalidate()
            startTimer = nil
        }
        super.reset()
    }
}
