//
//  ToolSelectorView.swift
//  nodal
//
//  Created by Devin Lehmacher on 6/19/17.
//  Copyright © 2017 Devin Lehmacher. All rights reserved.
//

import UIKit

enum TouchType {
    case finger
    case pencil
}

struct Tool {
    typealias Action = (TouchType) -> ()
    let action:  Action

    enum Display {
        // case image(UIImage)
        case text(String)
    }
    let displayStyle: Display

    enum ActionType {
        case instant
        case focus
    }
    let actionType: ActionType
}

class ToolSelectorView: BaseView {
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()

    var buttons = [ToolSelectorButton]()

    var selectedByPencil: ToolSelectorButton? {
        willSet {
            selectedByPencil?.isSelectedByPencil = false
            newValue?.isSelectedByPencil = true
        }
    }

    var selectedByFinger: ToolSelectorButton? {
        willSet {
            selectedByFinger?.isSelectedByFinger = false
            newValue?.isSelectedByFinger = true
        }
    }

    // initialize tools based on the array of tool specifications,
    // the first tool is selected as the default tool
    init(tools: [Tool]) {
        super.init()

        for tool in tools {
            switch tool.displayStyle {
            case .text(let text):
                let button = ToolSelectorButton(text: text)
                button.action = createActionFor(control: button, tool: tool)
                buttons.append(button)
                stackView.addArrangedSubview(button)
                print(text)
            }
        }

        if let first = buttons.first {
            selectedByFinger = first
            selectedByPencil = first
        }

        self.addSubview(stackView)
        stackView.equalConstraints(to: self)
    }

    // init with empty tool array
    convenience override init() {
        fatalError("are you sure this is what you wanted to do?")
    }

    func createActionFor(control: ToolSelectorButton, tool: Tool) -> Tool.Action {
        return { tt in
            switch tool.actionType {
            case .instant:
                break
            case .focus:
                switch tt {
                case .pencil:
                    self.selectedByPencil = control
                case .finger:
                    self.selectedByFinger = control
                }
            }
            tool.action(tt)
        }
    }
}

fileprivate class AllowSimultaneouslyDelegate: NSObject, UIGestureRecognizerDelegate {
    func gestureRecognizer(_ rec: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool {
        return true
    }
}

fileprivate let allowSimultaneousDelegate = AllowSimultaneouslyDelegate()

class ToolSelectorButton: BaseView {
    let fingerRecognizer: UIGestureRecognizer = {
        let rec = UITapGestureRecognizer()
        rec.numberOfTapsRequired = 1
        rec.allowedTouchTypes = [UITouchType.direct.rawValue as NSNumber]
        rec.delegate = allowSimultaneousDelegate
        return rec
    }()

    let pencilRecognizer: UIGestureRecognizer = {
        let rec = UITapGestureRecognizer()
        rec.numberOfTapsRequired = 1
        rec.allowedTouchTypes = [UITouchType.stylus.rawValue as NSNumber]
        rec.delegate = allowSimultaneousDelegate
        return rec
    }()

    var action: Tool.Action?

    func setColor() {
        if isSelectedByPencil && isSelectedByFinger {
            backgroundColor = UIColor.purple
        } else if isSelectedByPencil {
            backgroundColor = UIColor.red
        } else if isSelectedByFinger {
            backgroundColor = UIColor.blue
        } else {
            backgroundColor = UIColor.black
        }
        setNeedsDisplay()
    }

    var isSelectedByPencil = false {
        didSet {
            setColor()
        }
    }

    var isSelectedByFinger = false {
        didSet {
            setColor()
        }
    }

    init(text: String) {
        super.init()

        backgroundColor = .black

        let textView = UILabel()
        textView.text = text
        textView.textColor = .white
        self.addSubview(textView)
        self.equalConstraints(to: textView)
        textView.backgroundColor = .clear

        fingerRecognizer.addTarget(self, action: #selector(tapped(_:)))
        pencilRecognizer.addTarget(self, action: #selector(tapped(_:)))
        self.addGestureRecognizer(fingerRecognizer)
        self.addGestureRecognizer(pencilRecognizer)
        print(fingerRecognizer)
    }

    override convenience init() {
        self.init(text: "")
    }

    func tapped(_ recognizer: UIGestureRecognizer) {
        print("got a tap")
        assert(recognizer === fingerRecognizer || recognizer === pencilRecognizer)
        action?(recognizer === fingerRecognizer ? .finger : .pencil)
    }
}
