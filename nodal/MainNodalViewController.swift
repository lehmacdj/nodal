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

    @IBOutlet weak var canvasView: DrawingCanvasView!

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
            if let representation = recognizer.action as? Representable? {
                canvasView.temporaryElement = representation
            }
        case .ended:
            if let res = recognizer.action?.finish() {
                canvas.add(element: res)
                canvasView.temporaryElement = nil
                canvasView.add(element: res)
            }
        default:
            print("something broke, we are in an unexpected state")
        }
    }
}
