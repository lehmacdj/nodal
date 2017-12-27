//
//  MainNodalViewController.swift
//  nodal
//
//  Created by Devin Lehmacher on 5/7/17.
//  Copyright © 2017 Devin Lehmacher. All rights reserved.
//

import UIKit

class MainNodalViewController: UIViewController {
    let fingerRecognizer: ActionGestureRecognizer =  {
        let rec = ActionGestureRecognizer()
        rec.touchType = .finger
        return rec
    }()

    let pencilRecognizer: ActionGestureRecognizer =  {
        let rec = ActionGestureRecognizer()
        rec.touchType = .pencil
        return rec
    }()

    let canvas = CompleteCanvas()

    var transform = CGAffineTransform.identity
    var inverseTransform = CGAffineTransform.identity

    let canvasView = CanvasView()

    private func setTool(_ tt: TouchType, provider: @escaping ActionProvider) {
        switch tt {
        case .finger:
            fingerRecognizer.actionProvider = provider
        case .pencil:
            pencilRecognizer.actionProvider = provider
        }
    }

    private func mapTool(_ tt: TouchType, with mapper: @escaping (@escaping ActionProvider) -> ActionProvider) {
        switch tt {
        case .finger:
            let prevProvider = fingerRecognizer.actionProvider
            fingerRecognizer.actionProvider = mapper(prevProvider)
        case .pencil:
            let prevProvider = pencilRecognizer.actionProvider
            pencilRecognizer.actionProvider = mapper(prevProvider)
        }
    }

    override func loadView() {
        super.loadView()

        view.addSubview(canvasView)
        canvasView.equalConstraints(to: view)

        fingerRecognizer.addTarget(self, action: #selector(actionEventRecieved(_:)))
        pencilRecognizer.addTarget(self, action: #selector(actionEventRecieved(_:)))
        canvasView.addGestureRecognizer(fingerRecognizer)
        canvasView.addGestureRecognizer(pencilRecognizer)

        let tools = [
            Tool(action: { tt in self.setTool(tt, provider: { BroadLine() } ) },
                 displayStyle: .text("pen"),
                 actionType: .focus),
            Tool(action: { tt in self.setTool(tt, provider: mkDrawStraightLine) },
                 displayStyle: .text("line"),
                 actionType: .focus),
            Tool(action: { tt in self.setTool(tt, provider: mkDrawCircle) },
                 displayStyle: .text("circle"),
                 actionType: .focus),
            Tool(action: { tt in self.mapTool(tt, with: { prev in { SlowAction(below: prev()) } }) },
                 displayStyle: .text("slow"),
                 actionType: .instant),
            Tool(action: { tt in
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

    @objc func actionEventRecieved(_ recognizer: ActionGestureRecognizer) {
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
