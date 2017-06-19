//
//  CanvasView.swift
//  nodal
//
//  Created by Devin Lehmacher on 5/8/17.
//  Copyright © 2017 Devin Lehmacher. All rights reserved.
//

import UIKit

class CanvasView: BaseView {
    private var elements: [Drawer] = []
    var temporaryElement: Drawer? = nil {
        didSet {
            setNeedsDisplay()
        }
    }

    override init() {
        super.init()
        backgroundColor = .white
        contentMode = .redraw
        layer.drawsAsynchronously = true
    }

    func add(element: @escaping Drawer) {
        elements.append(element)
        setNeedsDisplay()
    }

    func clear() {
        elements.removeAll()
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        for e in elements {
            UIColor.black.set()
            e(rect)
        }

        if let t = temporaryElement {
            UIColor.blue.set()
            t(rect)
        }
    }
}
