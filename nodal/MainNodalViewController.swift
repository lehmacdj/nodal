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

    var transform = CGAffineTransform.identity
    var inverseTransform = CGAffineTransform.identity

    let canvasView = CanvasView()

    override func loadView() {
        super.loadView()

        view.addSubview(canvasView)
        canvasView.equalConstraints(to: view)

        let recFinger = ActionGestureRecognizer(target: self, action: #selector(actionEventRecieved(_:)))
        recFinger.touchType = .finger
        canvasView.addGestureRecognizer(recFinger)

        let recPencil = ActionGestureRecognizer(target: self, action: #selector(actionEventRecieved(_:)))
        recPencil.touchType = .pencil
        canvasView.addGestureRecognizer(recPencil)

        let tools = [
            Tool(action: {
                     recFinger.actionProvider = { BroadLine() }
                     recPencil.actionProvider = { BroadLine() }
                 },
                 displayStyle: .text("pen"),
                 actionType: .focus),
            Tool(action: {
                     recFinger.actionProvider = mkDrawStraightLine
                     recPencil.actionProvider = mkDrawStraightLine
                 },
                 displayStyle: .text("line"),
                 actionType: .focus),
            Tool(action: {
                     recFinger.actionProvider = mkDrawCircle
                     recPencil.actionProvider = mkDrawCircle
                 },
                 displayStyle: .text("circle"),
                 actionType: .focus),
            Tool(action: {
                     let fp = recFinger.actionProvider
                     let pp = recPencil.actionProvider
                     recFinger.actionProvider = { SlowAction(below: fp()) }
                     recPencil.actionProvider = { SlowAction(below: pp()) }
                 },
                 displayStyle: .text("slow"),
                 actionType: .instant),
            Tool(action: {
                    self.canvasView.clear()
                    self.canvas.elements.removeAll()
                 },
                 displayStyle: .text("clear"),
                 actionType: .instant),
        ]

        let toolbar = ToolSelectorView(tools: tools)
        view.addSubview(toolbar)
        toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        toolbar.widthAnchor.constraint(equalToConstant: 60).isActive = true
        toolbar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        toolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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
