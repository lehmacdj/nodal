//
//  CatmullRom.swift
//  nodal
//
//  Created by Devin Lehmacher on 4/17/19.
//  Copyright © 2019 Devin Lehmacher. All rights reserved.
//

import Foundation
import CoreGraphics

let EPSILON: CGFloat = 1.0e-5

struct CubicBezierControlPoints {
    let controlPoint1: CGPoint
    let controlPoint2: CGPoint
}

// compute Cubic bezier parameters to create a Catmull-Rom interpolation between p2 and p3
// adapted from:
// https://github.com/jnfisher/ios-curve-interpolation/blob/master/Curve%20Interpolation/UIBezierPath%2BInterpolation.m
func catmullRomInterpolate(p0: CGPoint, p1: CGPoint, p2: CGPoint, p3: CGPoint, alpha: CGFloat) -> CubicBezierControlPoints {

    let d01 = CGVector(from: p0, to: p1).magnitude
    let d12 = CGVector(from: p1, to: p2).magnitude
    let d23 = CGVector(from: p2, to: p3).magnitude

    var c1: CGPoint
    if d12 < EPSILON {
        c1 = p1
    } else {
        c1 = pow(d01, 2*alpha) * p2
        c1 = c1 - pow(d12, 2*alpha) * p0.vector
        let x = 2 * pow(d01, 2*alpha)
        let y = 3 * pow(d01, alpha) * pow(d12, alpha)
        let z = pow(d12, 2*alpha)
        c1 = c1 + (x + y + z) * p1.vector
        let a = pow(d01, alpha) + pow(d12, alpha)
        let b = 3 * pow(d01, alpha) * a
        c1 = (1 / b) * c1
    }

    var c2: CGPoint
    if d23 < EPSILON {
        c2 = p2
    } else {
        c2 = pow(d23, 2*alpha) * p1
        c2 = c2 - pow(d12, 2*alpha) * p3.vector
        let x = 2 * pow(d23, 2*alpha)
        let y = 3 * pow(d23, alpha) * pow(d12, alpha)
        let z = pow(d12, 2*alpha)
        c2 = c2 + (x + y + z) * p2.vector
        let a = pow(d23, alpha) + pow(d12, alpha)
        let b = 3 * pow(d23, alpha) * a
        c2 = (1 / b) * c2
    }

    return CubicBezierControlPoints(controlPoint1: c1, controlPoint2: c2)
}
