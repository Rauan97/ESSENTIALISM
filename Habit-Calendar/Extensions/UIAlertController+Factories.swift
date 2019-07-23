//
//  UIAlertController+Factories.swift
//  Habit-Calendar
//
//  Created by  Rauan Zhorabek   on 25/02/19.
//  Copyright © 2019  Rauan Zhorabek  . All rights reserved.
//

import UIKit

extension UIAlertController {

    // MARK: Factories

    /// Creates and configures a new alert controller with the passed title, message and main button title.
    /// - Parameters:
    ///     - title: the string to be displayed as the title
    ///     - message: the string to be displayed as the message label
    ///     - mainButtonTitle: the string to be displayed as the title of the default button
    ///     - buttonHandler: The closure to be called when the main button is tapped.
    /// - Returns: the alert controller with the configured parameters.
    static func make(
        title: String,
        message: String,
        mainButtonTitle: String = "Ok",
        buttonHandler: (() -> Void)? = nil
    ) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: mainButtonTitle, style: .default) { _ in buttonHandler?() })

        return alert
    }
}
