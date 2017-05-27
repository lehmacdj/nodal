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
    
    var currentAction: Action? = nil
    
    @IBOutlet weak var canvasView: DrawingCanvasView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("loaded!")
    }

    @IBAction func receivedSwipe(_ gr: UIPanGestureRecognizer) {
        let pc = gr.location(in: view)
        switch gr.state {
        case .began:
            print(pc)
            currentAction = DrawingSmoothLine(point: gr.location(in: view))
        case .changed:
            (currentAction! as! DrawingSmoothLine).add(pc)
            canvasView.temporaryElement = currentAction?.partial(with: pc)
        case .ended:
            print(pc)
            let res = currentAction!.finish(with: pc)
            canvas.add(element: res)
            canvasView.temporaryElement = nil
            canvasView.add(element: res)
            currentAction = nil
        default:
            print("Unexpected type of GestureState!")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
