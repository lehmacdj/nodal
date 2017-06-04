//
//  Canvas.swift
//  nodal
//
//  Created by Devin Lehmacher on 5/8/17.
//  Copyright © 2017 Devin Lehmacher. All rights reserved.
//

import UIKit
import Foundation

// a particular scaling/view of a canvas
protocol Window {
    var x: Double { get }
    var y: Double { get }
    var dx: Double { get }
    var dy: Double { get }
    var scale: Int { get }
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

    // a representation of every element in the canvas
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
    let scale = 0

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

protocol Representable {
    var path: UIBezierPath { get }
}

// an element that can be put in the canvas
protocol CanvasElement: Representable {
    var scale: Int { get }
}

class StraightLine: CanvasElement {
    let scale = 0

    let path = UIBezierPath()

    init(from s: Point, to e: Point) {
        path.move(to: s.cgPoint)
        path.addLine(to: e.cgPoint)
    }
}

class Path: CanvasElement {
    let scale = 0
    let path: UIBezierPath

    init(_ path: UIBezierPath) {
        self.path = path
    }
}

class NullElement: CanvasElement {
    let scale = 0
    let path = UIBezierPath()
}
