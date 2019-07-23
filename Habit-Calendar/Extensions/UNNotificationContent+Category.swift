//
//  UNNotificationContent+Category.swift
//  Active
//
//  Created by  Rauan Zhorabek   on 04/02/19.
//  Copyright © 2019  Rauan Zhorabek  . All rights reserved.
//

import Foundation
import UserNotifications

extension UNNotificationCategory {
    // MARK: Types

    /// The possible categories of an user notification.
    enum Kind {
        case dayPrompt(habitId: String?)

        // MARK: Properties

        /// The category's identifier.
        var identifier: String {
            switch self {
            case .dayPrompt:
                return "HABIT_DAY_PROMPT"
            }
        }

        // MARK: Imperatives

        /// Gets the action identifiers for each kind of category, if set.
        func getActionIdentifiers() -> (String, String) {
            switch self {
            case .dayPrompt:
                return (yes: "YES_ACTION", no: "NO_ACTION")
            }
        }
    }
}

extension UNNotificationContent {

    // MARK: Imperatives

    /// Gets the content's associated category.
    func getCategory() -> UNNotificationCategory.Kind? {
        if let identifier = userInfo["habitIdentifier"] as? String {
            // The default is the day prompt.
            return UNNotificationCategory.Kind.dayPrompt(habitId: identifier)
        } else {
            return nil
        }
    }
}
