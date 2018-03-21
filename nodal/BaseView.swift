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

    convenience required init?(coder aDecoder: NSCoder) {
        fatalError("subclasses of BaseView do not support coding")
    }
}

extension UIView {
    // make this view have equal constraints to another view
    func equalConstraints(to view: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false

        self.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        self.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    func scaledConstraint(to view: UIView,
                          attribute: NSLayoutAttribute,
                          multiplier: CGFloat,
                          constant: CGFloat = 0.0) {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: attribute,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: attribute,
                                            multiplier: multiplier,
                                            constant: constant)
        view.addConstraint(constraint)
    }
}
