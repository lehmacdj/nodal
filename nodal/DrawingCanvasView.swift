//
//  DrawingCanvasView.swift
//  nodal
//
//  Created by Devin Lehmacher on 5/8/17.
//  Copyright © 2017 Devin Lehmacher. All rights reserved.
//

import UIKit

class DrawingCanvasView: UIView {
    private var elements: [Representable] = []
    var temporaryElement: Representable? = nil {
        didSet {
            setNeedsDisplay()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        contentMode = .redraw
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.white
        contentMode = .redraw
    }

    func add(element: Representable) {
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
            t.path.stroke()
        }

        for e in elements {
            UIColor.black.set()
            e.path.stroke()
        }
    }
}
