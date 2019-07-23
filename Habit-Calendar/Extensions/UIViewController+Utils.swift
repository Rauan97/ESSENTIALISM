//
//  UIViewController+Utils.swift
//  Active
//
//  Created by  Rauan Zhorabek   on 03/02/19.
//  Copyright © 2019  Rauan Zhorabek  . All rights reserved.
//

import UIKit

/// Adds utilities to the view controller class.
extension UIViewController {

    /// The contents (child controller) of this parent controller.
    /// - Note: If the controller is a navigation controller, it returns its
    ///         root vc, otherwise the returned entity is just the
    ///         controller itself.
    var contents: UIViewController {
        if self is UINavigationController {
            return (self as? UINavigationController)?.viewControllers.first ?? self
        } else {
            return self
        }
    }
}
