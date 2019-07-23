//
//  FireTimeFactory.swift
//  Active
//
//  Created by  Rauan Zhorabek   on 22/02/19.
//  Copyright © 2019  Rauan Zhorabek  . All rights reserved.
//

import CoreData

/// Factory in charge of generating HabitDayMO dummies.
struct FireTimeFactory: DummyFactory {

    // MARK: Types

    // This factory generates entities of the FireTimeMO class.
    typealias Entity = FireTimeMO

    // MARK: Properties

    var context: NSManagedObjectContext

    // MARK: Imperatives

    /// Generates a new empty FireTimeMO entity.
    /// - Returns: the generated FireTime.
    func makeDummy() -> FireTimeMO {
        let fireTime = FireTimeMO(context: context)
        fireTime.id = UUID().uuidString
        fireTime.createdAt = Date()
        fireTime.hour = Int16(Int.random(0..<24))
        // Get a minute value that's or 30 or 00.

        let randomMinute = arc4random_uniform(2) == 0 ? 0 : 30
        fireTime.minute = Int16(randomMinute)

        // Associate the notification entity.
        let notificationFactory = NotificationFactory(context: context)
        fireTime.notification = notificationFactory.makeDummy()

        return fireTime
    }
}
