//
//  DrawingCanvasView.swift
//  nodal
//
//  Created by Devin Lehmacher on 5/8/17.
//  Copyright © 2017 Devin Lehmacher. All rights reserved.
//

import UIKit

class DrawingCanvasView: UIView {
    private var elements: [Drawable] = []
    var temporaryElement: Drawable? = nil {
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
        print(bounds)
    }
    
    func add(element e: Drawable) {
        elements.append(e)
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        print("redrawing!")
        
        for e in elements {
            e.draw()
        }
        
        if let temp = temporaryElement {
            temp.draw()
        }
    }
}

protocol Drawable {
    func draw()
}
