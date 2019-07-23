//
//  HCPersistentContainer.swift
//  Habit-Calendar
//
//  Created by  Rauan Zhorabek   on 24/02/19.
//  Copyright © 2019  Rauan Zhorabek  . All rights reserved.
//

import CoreData

class HCPersistentContainer: NSPersistentContainer {
  
    override class func defaultDirectoryURL() -> URL {
        guard let appGroupContainerUrl = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.essentialism"
            ) else {
                assertionFailure("Couldn't get the url of the shared container.")
                return super.defaultDirectoryURL().appendingPathComponent("HabitCalendar")
        }
        return appGroupContainerUrl.appendingPathComponent("HabitCalendar")
    }

}
