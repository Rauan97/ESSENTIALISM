//
//  FireTimeMO.swift
//  Active
//
//  Created by  Rauan Zhorabek   on 21/02/19.
//  Copyright © 2019  Rauan Zhorabek  . All rights reserved.
//

import CoreData

/// Entity representing the fire times for the user notifications
/// configured by the user.
class FireTimeMO: NSManagedObject {

    // MARK: Imperatives

    /// Gets the fire time hour and minute as date components.
    /// - Returns: The date components related to the fire time entity.
    func getFireTimeComponents() -> DateComponents {
        return DateComponents(
            calendar: Calendar.current,
            timeZone: TimeZone.current,
            hour: Int(hour),
            minute: Int(minute)
        )
    }
}
