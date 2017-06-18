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

typealias Drawer = () -> ()

protocol CanvasElement {
    // the bounding box for this element, in absolute coordinates
    var bounds: CGRect { get }

    // return a function that draws this element to the
    // canvas with the scaled size of the
    func createDrawer(with transform: CGAffineTransform) -> Drawer
}

class StraightLine: CanvasElement {
    let bounds: CGRect

    let path = UIBezierPath()

    init(from s: CGPoint, to e: CGPoint) {
        path.addLine(to: e)
        bounds = path.bounds
    }

    func createDrawer(with transform: CGAffineTransform) -> Drawer {
        let pathCopy = UIBezierPath(cgPath: path.cgPath)
        pathCopy.apply(transform)
        return {
            pathCopy.stroke()
        }
    }
}

class Path: CanvasElement {
    let bounds: CGRect
    let path: UIBezierPath

    init(_ path: UIBezierPath) {
        self.path = path
        bounds = path.bounds
    }

    func createDrawer(with transform: CGAffineTransform) -> Drawer {
        let pathCopy = UIBezierPath(cgPath: path.cgPath)
        pathCopy.apply(transform)
        return {
            pathCopy.stroke()
        }
    }
}

func computeBounds(points: [SamplePoint], radius: CGFloat) -> CGRect? {
    let comparePoints: (SamplePoint, SamplePoint) -> Bool = { (p1, p2) in
        p1.location.x > p2.location.x || p1.location.y > p2.location.y }
    if let min = points.min(by: comparePoints),
       let max = points.max(by: comparePoints) {
        let dpoint = CGVector(dx: radius, dy: radius)
        let minBound = min.location - dpoint
        let maxBound = max.location + dpoint
        let dBoundX = maxBound.x - minBound.y
        let dBoundY = maxBound.y - minBound.y
        let size = CGSize(width: dBoundX, height: dBoundY)
        return CGRect(origin: minBound, size: size)
    }

    return nil
}

class PenStroke: CanvasElement {
    let bounds: CGRect
    let points: [SamplePoint]

    init?(_ points: [SamplePoint]) {
        self.points = points
        if let bounds = computeBounds(points: points, radius: 1) {
            self.bounds = bounds
        } else {
            return nil
        }
    }

    func createDrawer(with transform: CGAffineTransform) -> Drawer {
        let spline = Spline(points: points, width: 30)
        return {
            spline.draw()
        }
    }
}
