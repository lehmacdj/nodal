//
//  CanvasView.swift
//  nodal
//
//  Created by Devin Lehmacher on 5/8/17.
//  Copyright © 2017 Devin Lehmacher. All rights reserved.
//

import UIKit

class CanvasView: UIView {
    private var elements: [Drawer] = []
    var temporaryElement: Drawer? = nil {
        didSet {
            setNeedsDisplay()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        contentMode = .redraw
        layer.drawsAsynchronously = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.white
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
        if let t = temporaryElement {
            UIColor.blue.set()
            t(rect)
        }

        UIColor.black.set()
        for e in elements {
            e(rect)
        }
    }
}
