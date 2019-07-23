//
//  UserDefaults+Login.swift
//  Active
//
//  Created by  Rauan Zhorabek   on 12/02/19.
//  Copyright © 2019  Rauan Zhorabek  . All rights reserved.
//

import Foundation

/// Adds login utilities to UserDefaults.
extension UserDefaults {

    // MARK: Properties

    /// A value indicating if it's the user first launch.
    var isFirstLaunch: Bool {
        return !bool(forKey: "did_launch_already")
    }

    // MARK: Imperatives

    /// Marks that the user already launched the app once.
    func setFirstLaunchPassed() {
        set(true, forKey: "did_launch_already")
    }
}
