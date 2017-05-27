//
//  Canvas.swift
//  nodal
//
//  Created by Devin Lehmacher on 5/8/17.
//  Copyright © 2017 Devin Lehmacher. All rights reserved.
//

import UIKit
import Foundation

// a window into which one can view a canvas, e.g. a zoomed view of a canvas
protocol Window {
}

struct Point {
    var x: Double
    var y: Double

    var cgPoint: CGPoint {
        get {
            return CGPoint(x: CGFloat(x), y: CGFloat(y))
        }
    }
}

// an abstract region that contains elements that belong in the canvas
protocol Canvas {
    func projected(onto window: Window) -> Canvas
    var scale: Int { get }
}

// represents the entire graph / image that is being displayed
class CompleteCanvas: Canvas {
    let scale = 0

    var elements: [CanvasElement] = []

    func add(element: CanvasElement) {
        elements.append(element)
    }

    func projected(onto window: Window) -> Canvas {
        return CanvasSlice(backing: self, domain: window)
    }
}

// slice that represents only a subsection of the full Canvas
class CanvasSlice: Canvas {
    let scale = 1

    private let backingCanvas: Canvas
    private let window: Window

    func projected(onto window: Window) -> Canvas {
        return CanvasSlice(backing: self, domain: window)
    }

    init(backing canvas: Canvas, domain window: Window) {
        backingCanvas = canvas
        self.window = window
    }
}

// an element that can be put in the canvas
protocol CanvasElement: Drawable {
    var scale: Int { get }
}

class StraightLine: CanvasElement, Drawable {
    let scale = 0

    let start: Point
    let end: Point

    init(from s: Point, to e: Point) {
        start = s
        end = e
    }

    func draw() {
        let line = UIBezierPath()
        print("drawing a line")
        UIColor.blue.set()
        line.lineWidth = 1
        line.move(to: start.cgPoint)
        line.addLine(to: end.cgPoint)
        line.stroke()
    }
}
