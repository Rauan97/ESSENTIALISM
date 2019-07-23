//
//  OnBoardingViewController.swift
//  Active
//
//  Created by  Rauan Zhorabek   on 11/02/19.
//  Copyright © 2019  Rauan Zhorabek  . All rights reserved.
//

import UIKit

class OnBoardingViewController: UIViewController {

    // MARK: Parameters

    /// The notification manager used to get the user's authorization.
    var notificationManager: UserNotificationManager!

    // MARK: Imperatives

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red:0.27, green:0.33, blue:0.41, alpha:1.0)
        assert(notificationManager != nil, "The notification manager must be injected.")
    }

    // MARK: Actions

    @IBAction func closeController(_ sender: RoundedButton) {
        dismiss(animated: true) {
            UserDefaults.standard.setFirstLaunchPassed()
            // Request the user's authorization to schedule local notifications.
            self.notificationManager.requestAuthorization { authorized in
                print("User \(authorized ? "authorized" : "denied").")
            }
        }
    }
  }
