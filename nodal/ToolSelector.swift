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
    // the effect on the state of the window, when pressing the tool
    typealias Effect = (TouchType) -> ()
    let effect:  Effect

    enum Display {
        // case image(UIImage)
        case text(String)
    }
    let displayStyle: Display

    // does the effect focus the pressed tool or not?
    enum EffectType {
        case instant
        case focus
    }
    let effectType: EffectType
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
                button.effect = createEffectFor(control: button, tool: tool)
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

    func createEffectFor(control: ToolSelectorButton, tool: Tool) -> Tool.Effect {
        return { tt in
            switch tool.effectType {
            case .instant:
                // don't do anything if tool is instant
                // in the future we may want an animation here
                break
            case .focus:
                // we need to focus, the tool and set the tool
                // based on whatever focused the touch
                switch tt {
                case .pencil:
                    self.selectedByPencil = control
                case .finger:
                    self.selectedByFinger = control
                }
            }
            tool.effect(tt)
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
    
    // we need to knot the button together given the cyclic dependency
    // between the closure and the button
    var effect: Tool.Effect?

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

    @objc func tapped(_ recognizer: UIGestureRecognizer) {
        print("got a tap")
        assert(recognizer === fingerRecognizer || recognizer === pencilRecognizer)
        effect?(recognizer === fingerRecognizer ? .finger : .pencil)
    }
}
