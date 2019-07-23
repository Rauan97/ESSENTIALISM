//
//  NotificationFactory.swift
//  ActiveTests
//
//  Created by  Rauan Zhorabek   on 23/02/19.
//  Copyright © 2019  Rauan Zhorabek  . All rights reserved.
//

import Foundation
import CoreData

/// Factory in charge of generating NotificationMO dummies.
struct NotificationFactory: DummyFactory {

    // MARK: Types

    // This factory generates entities of the Notification class.
    typealias Entity = NotificationMO

    // MARK: Properties

    var context: NSManagedObjectContext

    // MARK: Imperatives

    /// Generates a Notification (entity) dummy.
    /// - Note: The generated Notification dummy is empty, it doesn't have
    ///         an assciated habit object, and it doesn't have a user
    ///         notification id.
    /// - Returns: A generated Notification dummy as a NSManagedObject.
    func makeDummy() -> NotificationMO {
        // Declare the Notification entity.
        let notification = NotificationMO(context: context)

        // Associate its properties.
        notification.id = UUID().uuidString
        notification.userNotificationId = UUID().uuidString

        assert(notification.id != nil, "Id must be set.")
        assert(notification.userNotificationId != nil, "User notification id must be set.")

        return notification
    }
}
