//
//  DummyFactory.swift
//  ActiveTests
//
//  Created by  Rauan Zhorabek   on 23/02/19.
//  Copyright © 2019  Rauan Zhorabek  . All rights reserved.
//

import Foundation
import CoreData

/// Declares the main interface for the dummy factories
/// of each core data entity.
/// - Note: Dummies are only used for testing and seeding.
protocol DummyFactory {

    // MARK: Types

    // The generic entity generated by each factory implementation.
    associatedtype Entity: NSManagedObject

    // MARK: Properties

    /// The container used to generate dummies.
    var context: NSManagedObjectContext { get }

    // MARK: Imperatives

    /// Generates and returns the dummy object.
    func makeDummy() -> Entity
}
