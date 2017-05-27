//
//  Action.swift
//  nodal
//
//  Created by Devin Lehmacher on 5/8/17.
//  Copyright © 2017 Devin Lehmacher. All rights reserved.
//

import Foundation
import UIKit

protocol Action {
    func partial(with point: CGPoint) -> Drawable
    func finish(with point: CGPoint) -> CanvasElement
}

class DrawingLine: Action {
    let firstPoint: CGPoint
    
    init(initialPoint point: CGPoint) {
        firstPoint = point
    }
    
    func complete(with second: CGPoint) -> StraightLine {
        let p1 = Point(x: Double(firstPoint.x), y: Double(firstPoint.y))
        let p2 = Point(x: Double(second.x), y: Double(second.y))
        let line = StraightLine(from: p1, to: p2)
        return line
    }
    
    func finish(with point: CGPoint) -> CanvasElement {
        return complete(with: point)
    }
    
    func partial(with point: CGPoint) -> Drawable {
        return PartialLine(point, outer: self)
    }
    
    private class PartialLine: Drawable {
        let secondPoint: CGPoint
        let outer: DrawingLine
        init(_ point: CGPoint, outer: DrawingLine) {
            secondPoint = point
            self.outer = outer
        }
        
        func draw() {
            print("drawing a partial line")
            let line = UIBezierPath()
            UIColor.black.set()
            line.lineWidth = 1
            line.move(to: outer.firstPoint)
            line.addLine(to: secondPoint)
            line.stroke()
        }
    }
}

class DrawingSmoothLine: Action, Drawable {
    var points: [CGPoint] = []
    
    var path = UIBezierPath()
    
    init(point: CGPoint) {
        path.move(to: point)
        points.append(point)
    }
    
    func add(_ point: CGPoint) {
        points.append(point)
        path.addLine(to: point)
    }
    
    func finish(with point: CGPoint) -> CanvasElement {
        let first = Point(x: Double(points[0].x), y: Double(points[0].y))
        let second = Point(x: Double(points[1].x), y: Double(points[1].y))
        let line = StraightLine(from: first, to: second)
        return line
    }
    
    func partial(with point: CGPoint) -> Drawable {
        return self
    }
    
    func draw() {
        UIColor.blue.set()
        path.stroke()
    }
}
