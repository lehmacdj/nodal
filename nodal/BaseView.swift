//
//  BaseView.swift
//  nodal
//
//  Created by Devin Lehmacher on 6/19/17.
//  Copyright © 2017 Devin Lehmacher. All rights reserved.
//

import UIKit

// a set of common configurations for UIView subclasses
class BaseView: UIView {
    init() {
        super.init(frame: CGRect.zero)
        translatesAutoresizingMaskIntoConstraints = false
    }

    // warning: this initializer ignores the frame as this class is
    // intended to only be used with autolayout
    convenience override init(frame: CGRect) {
        self.init()
    }

    convenience required init?(coder aDecoder: NSCoder) {
        fatalError("subclasses of BaseView do not support coding")
    }
}
