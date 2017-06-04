//
//  ViewController.swift
//  nodal
//
//  Created by Devin Lehmacher on 5/7/17.
//  Copyright © 2017 Devin Lehmacher. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let canvas = CompleteCanvas()

    @IBOutlet weak var canvasView: DrawingCanvasView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let rec = ActionGestureRecognizer(target: self, action: #selector(actionEventRecieved(_:)))
        canvasView.addGestureRecognizer(rec)
        print("loaded!")
    }
    
    func actionEventRecieved(_ recognizer: ActionGestureRecognizer) {
        switch recognizer.state {
        case .began,
             .changed:
            canvasView.temporaryElement = recognizer.action
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
