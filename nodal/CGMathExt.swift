//
//  CGMathExt.swift
//  nodal
//
//  Created by Devin Lehmacher on 6/8/17.
//  Copyright © 2017 Devin Lehmacher. All rights reserved.
//

import UIKit

// addition and subtraction of sizes and points
func +(left: CGPoint, right: CGSize) -> CGPoint {
    return CGPoint(x: left.x + right.width,
                   y: left.y + right.height)
}

func -(left: CGPoint, right: CGSize) -> CGPoint {
    return CGPoint(x: left.x - right.width,
                   y: left.y - right.height)
}


// addition and subtraction of vectors and points
func +(left: CGPoint, right: CGVector) -> CGPoint {
    return CGPoint(x: left.x + right.dx,
                   y: left.y + right.dy)
}

func -(left: CGPoint, right: CGVector) -> CGPoint {
    return CGPoint(x: left.x - right.dx,
                   y: left.y - right.dy)
}

extension CGVector {
    // create vectors between points
    init(from p1: CGPoint, to p2: CGPoint) {
        self.init(dx: p2.x - p1.x,
                  dy: p2.y - p1.y)
    }
}

// help routines for working with polar coordinates
extension CGVector {
    // the angle in radians from the X-axis
    var angle: CGFloat {
        return atan2(dy, dx)
    }

    // the angle of this vector relative to another
    func heading(relativeTo vec: CGVector) -> CGFloat {
        return acos(self.dot(vec) / (self.magnitude * vec.magnitude))
    }

    // the magnitude of the vector
    var magnitude: CGFloat {
        return sqrt(pow(dx, 2) + pow(dy, 2))
    }

    // initalize a vector from polar coordinates
    init(magnitude: CGFloat, angle: CGFloat) {
        self.init(dx: magnitude * cos(angle),
                  dy: magnitude * sin(angle))
    }

    // create unit vectors
    init(unitWithAngle angle: CGFloat) {
        self.init(magnitude: 1, angle: angle)
    }
}

// primitive transformations
extension CGVector {
    // return unit vector with the same angle
    func intoUnit() -> CGVector {
        return CGVector(unitWithAngle: self.angle)
    }

    // return the 90˚ left rotated vector
    func perpendicular() -> CGVector {
        return CGVector(dx: -self.dy,
                        dy: self.dx)
    }
}

// helper operations
extension CGVector {
    static func mean(_ v1: CGVector, _ v2: CGVector) -> CGVector {
        return CGVector(dx: (v1.dx + v2.dx) / 2,
                        dy: (v1.dy + v2.dy) / 2)
    }

    func dot(_ other: CGVector) -> CGFloat {
        return dx * other.dx + dy * other.dy
    }
}

// scalar multiplication for vectors
func *(left: CGFloat, right: CGVector) -> CGVector {
    return CGVector(dx: left * right.dx,
                    dy: left * right.dy)
}
