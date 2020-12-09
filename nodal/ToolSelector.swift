//
//  ToolSelectorView.swift
//  nodal
//
//  Created by Devin Lehmacher on 6/19/17.
//  Copyright © 2017 Devin Lehmacher. All rights reserved.
//

import UIKit

protocol ToolButtonDelegate {
    // the button that this is a delegate for
    // must be unique; the model is one delegate per tool
    // the delegate determines the behavior when
    // using the button; and the button provides the API
    // for manipulating its own appearances
    // set when used as a delegate; thus implicitly unwrapped
    var button: ToolSelectorButton! { get set }

    func clicked(by touchType: TouchType)
    func loadButton()

    var isSelectedByFinger: Bool { get }
    var isSelectedByPencil: Bool { get }
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

    // initialize tools based on the array of tool specifications,
    // the first tool is selected as the default tool
    init(tools: [ToolButtonDelegate]) {
        super.init()

        for tool in tools {
            let button = ToolSelectorButton(delegate: tool)
            buttons.append(button)
            stackView.addArrangedSubview(button)
        }

        self.addSubview(stackView)
        stackView.equalConstraints(to: self)
    }

    // init with empty tool array
    convenience override init() {
        fatalError("are you sure this is what you wanted to do?")
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
        rec.allowedTouchTypes = [UITouch.TouchType.direct.rawValue as NSNumber]
        rec.delegate = allowSimultaneousDelegate
        return rec
    }()

    let pencilRecognizer: UIGestureRecognizer = {
        let rec = UITapGestureRecognizer()
        rec.numberOfTapsRequired = 1
        rec.allowedTouchTypes = [UITouch.TouchType.stylus.rawValue as NSNumber]
        rec.delegate = allowSimultaneousDelegate
        return rec
    }()

    var text: String? {
        get {
            return textView.text
        }
        set {
            textView.text = newValue
        }
    }

    let textView: UILabel = {
        let tv = UILabel()
        tv.textColor = .white
        return tv
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

    var isSelectedByPencil: Bool {
        return delegate?.isSelectedByPencil ?? false
    }

    var isSelectedByFinger: Bool {
        return delegate?.isSelectedByFinger ?? false
    }

    var delegate: ToolButtonDelegate? {
        willSet {
            delegate?.button = nil
        }
        didSet {
            delegate?.button = self
        }
    }

    convenience init(delegate: ToolButtonDelegate) {
        self.init()
        self.delegate = delegate
    }

    override convenience init() {
        backgroundColor = .black

        delegate?.loadButton()

        self.addSubview(textView)
        self.equalConstraints(to: textView)
        textView.backgroundColor = .clear

        fingerRecognizer.addTarget(self, action: #selector(tapped(_:)))
        pencilRecognizer.addTarget(self, action: #selector(tapped(_:)))
        self.addGestureRecognizer(fingerRecognizer)
        self.addGestureRecognizer(pencilRecognizer)
        print(fingerRecognizer)
    }

    @objc func tapped(_ recognizer: UIGestureRecognizer) {
        print("got a tap")
        assert(recognizer === fingerRecognizer || recognizer === pencilRecognizer)
        delegate?.clicked(by: recognizer === fingerRecognizer ? .finger : .pencil)
    }
}
