//
//  MainNodalViewController.swift
//  nodal
//
//  Created by Devin Lehmacher on 5/7/17.
//  Copyright © 2017 Devin Lehmacher. All rights reserved.
//

import UIKit

class MainNodalViewController: UIViewController {
    // MARK: Drawing Layer + Underlying Data
    let canvas = CompleteCanvas()

    var transform = CGAffineTransform.identity
    var inverseTransform = CGAffineTransform.identity

    let canvasView = CanvasView()

    let completeSplineDelegate: SplineRecognizerDelegate = DecentBuilder()
    let twoPointSplineDelegate: SplineRecognizerDelegate = TwoPointBuilder()

    var fingerTool: Tool?
    var pencilTool: Tool?

    func tool(for touchType: TouchType) -> Tool? {
        switch touchType {
        case .pencil:
            return pencilTool
        case .finger:
            return fingerTool
        }
    }

    func set(tool: Tool?, for touchType: TouchType) {
        switch touchType {
        case .pencil:
            pencilTool = tool
        case .finger:
            fingerTool = tool
        }
    }

    // MARK: Action Gesture Recognizers
    let fingerRecognizer: SplineRecognizer =  {
        let rec = SplineRecognizer()
        rec.touchType = .finger
        return rec
    }()

    let pencilRecognizer: SplineRecognizer =  {
        let rec = SplineRecognizer()
        rec.touchType = .pencil
        return rec
    }()

    func splineRecognizer(_ tt: TouchType) -> SplineRecognizer {
        switch tt {
        case .finger:
            return fingerRecognizer
        case .pencil:
            return pencilRecognizer
        }
    }


    // MARK: Scroll View + Delegate
    let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.panGestureRecognizer.touchTypes = []
        sv.minimumZoomScale = 0.5
        sv.maximumZoomScale = 2.0
        return sv
    }()


    // MARK: Layout + Initialization

    override func loadView() {
        super.loadView()

        view.addSubview(scrollView)
        scrollView.addSubview(canvasView)
        scrollView.delegate = self

        scrollView.equalConstraints(to: view)

        // confusing special constraint is necessary to allow scrolling
        // this is really a crime as far as software engineering is concerned
        scrollView.equalConstraints(to: canvasView)

        // this does correctly create the scroll view, we just need to make it possible to scroll / zoom it now
        canvasView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 2.0).isActive = true
        canvasView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 2.0).isActive = true

        fingerRecognizer.addTarget(self, action: #selector(actionEventRecieved(_:)))
        pencilRecognizer.addTarget(self, action: #selector(actionEventRecieved(_:)))
        canvasView.addGestureRecognizer(fingerRecognizer)
        canvasView.addGestureRecognizer(pencilRecognizer)

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

extension MainNodalViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return canvasView
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {}
}
