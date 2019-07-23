//
//  Notification.swift
//  Active
//
//  Created by  Rauan Zhorabek   on 01/02/19.
//  Copyright © 2019  Rauan Zhorabek  . All rights reserved.
//

import CoreData
import UserNotifications

/// The Notification model entity.
/// - Note: Alongside with the entity, an specific UserNotification is scheduled.
class NotificationMO: NSManagedObject {

    // MARK: Properties

    /// The associated and scheduled request for a user notification.
    var request: UNNotificationRequest?
}
