//
//  MainNodalViewController.swift
//  nodal
//
//  Created by Devin Lehmacher on 5/7/17.
//  Copyright © 2017 Devin Lehmacher. All rights reserved.
//

import UIKit

class MainNodalViewController: UIViewController {

    let canvas = CompleteCanvas()

    var transform = CGAffineTransform()
    var inverseTransform = CGAffineTransform()

    @IBOutlet weak var canvasView: CanvasView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let rec = ActionGestureRecognizer(target: self, action: #selector(actionEventRecieved(_:)))
        rec.touchType = .pencil
        canvasView.addGestureRecognizer(rec)
        print("loaded!")
    }

    func actionEventRecieved(_ recognizer: ActionGestureRecognizer) {
        switch recognizer.state {
        case .began,
             .changed:
            if let drawer = recognizer.action?.intermediate() {
                canvasView.temporaryElement = drawer
            }
        case .ended:
            if let res = recognizer.action?.finish(with: transform) {
                canvas.add(element: res)
                canvasView.temporaryElement = nil
                canvasView.add(element: res.createDrawer(with: inverseTransform))
            }
        default:
            print("something broke, we are in an unexpected state")
        }
    }
}
