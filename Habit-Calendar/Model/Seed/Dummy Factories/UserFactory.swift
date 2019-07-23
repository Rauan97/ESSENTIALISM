//
//  UserDummyFactory.swift
//  ActiveTests
//
//  Created by  Rauan Zhorabek   on 23/02/19.
//  Copyright © 2019  Rauan Zhorabek  . All rights reserved.
//

import Foundation
import CoreData

/// Factory in charge of generating UserMO dummies.
struct UserFactory: DummyFactory {

    // MARK: Types

    // This factory generates entities of the User class.
    typealias Entity = UserMO

    // MARK: Properties

    var context: NSManagedObjectContext

    // MARK: Imperatives

    /// Creates an User entity object.
    func makeDummy() -> UserMO {
        // Create the entity.
        let user = UserMO(context: context)

        // Configure it's properties.
        user.id = UUID().uuidString
        user.createdAt = Date()

        return user
    }
}
