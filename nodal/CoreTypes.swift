//
//  CoreTypes.swift
//  nodal
//
//  Created by Devin Lehmacher on 1/1/18.
//  Copyright © 2018 Devin Lehmacher. All rights reserved.
//

import Foundation
import UIKit

// Denotes the two physical touch types to provide additional
// type safety / not special casing .indirect in every case
enum TouchType {
    case finger
    case pencil
    
    static func fromUITouchType(_ uiTT: UITouchType) -> TouchType? {
        switch uiTT {
        case .direct:
            return .finger
        case .indirect:
            return nil
        case .pencil:
            return .pencil
        }
    }
    
    static func fromNSNumber(_ nsn: NSNumber) -> TouchType? {
        return UITouchType(rawValue: nsn.intValue).flatMap(fromUITouchType)
    }
    
    static func toNSNumber(_ tt: TouchType) -> NSNumber {
        switch tt {
        case .finger:
            return UITouchType.direct.rawValue as NSNumber
        case .pencil:
            return UITouchType.stylus.rawValue as NSNumber
        }
    }
}
