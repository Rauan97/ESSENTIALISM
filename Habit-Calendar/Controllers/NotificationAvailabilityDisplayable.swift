//
//  NotificationAvailabilityDisplayable.swift
//  Active
//
//  Created by  Rauan Zhorabek   on 28/08/19.
//  Copyright © 2019  Rauan Zhorabek  . All rights reserved.
//

import Foundation

/// Adds the interface for displaying whether user notifications are allowed or not.
protocol NotificationAvailabilityDisplayable: AppActiveObserver {

    // MARK: Imperatives

    /// The notification manager used to get the authorization status.
    var notificationManager: UserNotificationManager! { get set }

    // MARK: Imperatives

    /// Displays information about the local user notifications authorization status.
    func displayNotificationAvailability()
}
