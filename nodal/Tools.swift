//
//  Tools.swift
//  nodal
//
//  Created by Devin Lehmacher on 5/5/19.
//  Copyright © 2019 Devin Lehmacher. All rights reserved.
//

import UIKit

protocol Tool: ToolButtonDelegate {
    var mainController: MainNodalViewController { get }

    func deselected(by touchType: TouchType)
}

class PenTool: Tool {
    var mainController: MainNodalViewController
    var button: ToolSelectorButton!

    init(mainController: MainNodalViewController) {
        self.mainController = mainController
    }

    func clicked(by touchType: TouchType) {
        let rec = mainController.splineRecognizer(touchType)
        rec.splineRecognizerDelegate = mainController.completeSplineDelegate

        mainController.set(tool: self, for: touchType)
        button.setColor()
    }

    func deselected(by touchType: TouchType) {
        button.setColor()
    }

    func loadButton() {
        button.text = "Pen"
    }

    var isSelectedByFinger: Bool {
        return (mainController.fingerTool as? PenTool) === self
    }

    var isSelectedByPencil: Bool {
        return (mainController.pencilTool as? PenTool) === self
    }
}

class StraightLineTool: Tool {
    var mainController: MainNodalViewController
    var button: ToolSelectorButton!

    init(mainController: MainNodalViewController) {
        self.mainController = mainController
    }

    func clicked(by touchType: TouchType) {
        let rec = mainController.splineRecognizer(touchType)
        rec.splineRecognizerDelegate = mainController.twoPointSplineDelegate

        mainController.fingerTool = self
    }

    func deselected(by touchType: TouchType) {
        button.setColor()
    }

    func loadButton() {
        button.text = "Line"
    }

    var isSelectedByFinger: Bool {
        return (mainController.fingerTool as? StraightLineTool) === self
    }

    var isSelectedByPencil: Bool {
        return (mainController.pencilTool as? StraightLineTool) === self
    }
}

class ScrollTool: Tool {
    var mainController: MainNodalViewController
    var button: ToolSelectorButton!

    init(mainController: MainNodalViewController) {
        self.mainController = mainController
    }

    func clicked(by touchType: TouchType) {
        mainController.scrollView.panGestureRecognizer.touchTypes.append(touchType)
        mainController.splineRecognizer(touchType).isEnabled = false
        mainController.set(tool: self, for: touchType)
        button.setColor()
    }

    func deselected(by touchType: TouchType) {
        mainController.splineRecognizer(touchType).isEnabled = true
        if let i = mainController.scrollView.panGestureRecognizer.touchTypes.firstIndex(of: touchType) {
            mainController.scrollView.panGestureRecognizer.touchTypes.remove(at: i)
        }
        button.setColor()
    }

    var isSelectedByFinger: Bool {
        return (mainController.fingerTool as? ScrollTool) === self
    }

    var isSelectedByPencil: Bool {
        return (mainController.pencilTool as? ScrollTool) === self
    }

    func loadButton() {
        button.text = "Scroll"
    }
}
