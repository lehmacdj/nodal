//
//  ToolSelectorView.swift
//  nodal
//
//  Created by Devin Lehmacher on 6/19/17.
//  Copyright © 2017 Devin Lehmacher. All rights reserved.
//

import UIKit

struct Tool {
    typealias Action = () -> ()
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

    var selected: ToolSelectorButton? {
        willSet {
            selected?.isSelected = false
            newValue?.isSelected = true
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
            selected = first
        }

        self.addSubview(stackView)
        stackView.equalConstraints(to: self)
    }

    convenience override init() {
        self.init(tools: [])
    }

    func createActionFor(control: ToolSelectorButton, tool: Tool) -> Tool.Action {
        return {
            switch tool.actionType {
            case .instant:
                break
            case .focus:
                self.selected = control
            }
            tool.action()
        }
    }
}


class ToolSelectorButton: BaseView {
    var action: Tool.Action?
    var isSelected = false {
        didSet {
            backgroundColor = isSelected ? .gray : .black;
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

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapRecognizer)
    }

    override convenience init() {
        self.init(text: "")
    }

    func tapped(_ recognizer: UIGestureRecognizer) {
        action?()
    }
}
