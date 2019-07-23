//
//  HabitStorage.swift
//  Active
//
//  Created by  Rauan Zhorabek   on 06/02/19.
//  Copyright © 2019  Rauan Zhorabek  . All rights reserved.
//

import Foundation
import CoreData

/// Class in charge of managing the storage of Habit entities.
struct HabitStorage {

    // MARK: - Properties

    /// The Notification storage used to create Notification entities
    /// associated with a given habit.
    private let notificationStorage: NotificationStorage

    /// The days challenge storage used to create new challenges.
    private let daysChallengeStorage: DaysChallengeStorage

    /// The user notifications scheduler.
    private let notificationScheduler: NotificationScheduler

    /// The fire time used to create and associate the FireTimeMO entities.
    private let fireTimeStorage: FireTimeStorage

    // MARK: - Initializers

    /// Creates a new HabitStorage class using the provided persistent container.
    /// - Parameters:
    ///     - daysChallengeStorage: The storage used to manage the habit's challenges.
    ///     - notificationStorage: The notification storage used to edit the entities' notifications.
    ///     - notificationScheduler: The scheduler in charge of scheduling the user notifications for the habit.
    ///     - fireTimeStorage: The storage in charge of creating the fire time entities.
    init(daysChallengeStorage: DaysChallengeStorage,
         notificationStorage: NotificationStorage,
         notificationScheduler: NotificationScheduler,
         fireTimeStorage: FireTimeStorage
    ) {
        self.daysChallengeStorage = daysChallengeStorage
        self.notificationStorage = notificationStorage
        self.notificationScheduler = notificationScheduler
        self.fireTimeStorage = fireTimeStorage
    }

    // MARK: - Imperatives

    /// Creates a NSFetchedResultsController for fetching daily habit instances
    /// ordered by the creation date and score of each habit.
    /// - Note: Daily habits are habits that don't have any active challenge of
    ///         days. All challenges were completed.
    /// - Parameter context: The context used to fetch the habits.
    /// - Returns: The created fetched results controller.
    func makeDailyFetchedResultsController(context: NSManagedObjectContext) -> NSFetchedResultsController<HabitMO> {
        // Filter for habits that don't have an active challenge of days
        // (aren't closed yet or date is not in between the challenge).
        let dailyPredicate = NSPredicate(
            format: """
SUBQUERY(challenges, $challenge,
    $challenge.isClosed == false AND $challenge.fromDate <= %@ AND %@ <= $challenge.toDate
).@count == 0
""",
            Date().getBeginningOfDay() as NSDate,
            Date().getBeginningOfDay() as NSDate
        )
        let request: NSFetchRequest<HabitMO> = HabitMO.fetchRequest()
        request.predicate = dailyPredicate
        // The request should order the habits by the creation date and score.
        request.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]

        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        return controller
    }

    /// Creates a NSFetchedResultsController for fetching in progress habit instances
    /// ordered by the creation date and score of each habit.
    /// - Note: Habits in progress are habits that have an active days' challenge.
    /// - Parameter context: The context used to fetch the habits.
    /// - Returns: The created fetched results controller.
    func makeFetchedResultsController(context: NSManagedObjectContext) -> NSFetchedResultsController<HabitMO> {
        // Filter for habits that have an active days' challenge.
        let inProgressPredicate = NSPredicate(
            format: """
SUBQUERY(challenges, $challenge,
    $challenge.isClosed == false AND $challenge.fromDate <= %@ AND %@ <= $challenge.toDate
).@count > 0
""",
            Date().getBeginningOfDay() as NSDate,
            Date().getBeginningOfDay() as NSDate
        )
        let request: NSFetchRequest<HabitMO> = HabitMO.fetchRequest()
        request.predicate = inProgressPredicate
        // The request should order the habits by the creation date and score.
        request.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]

        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        return controller
    }

    /// Creates and persists a new Habit instance with the provided info.
    /// - Parameter context: The context used to write the new habit into.
    /// - Parameter name: The name of the habit entity.
    /// - Parameter days: The dates for the DaysChallenge associated with the habit being created.
    /// - Parameter notifications: The fire dates of each notification object
    ///                            to be added to the habit.
    /// - Returns: The created Habit entity object.
    func create(using context: NSManagedObjectContext,
                user: UserMO,
                name: String,
                color: HabitMO.Color,
                days: [Date]? = nil,
                and notificationFireTimes: [DateComponents]? = nil) -> HabitMO {
        // Declare a new habit instance.
        let habit = HabitMO(context: context)
        habit.id = UUID().uuidString
        habit.name = treatName(name)
        habit.createdAt = Date()
        habit.color = color.rawValue

        // Associate its user.
        habit.user = user

        // Create the challenge.
        if let days = days {
            _ = daysChallengeStorage.create(
                using: context,
                daysDates: days,
                and: habit
            )
        }

        // Create and associate the notifications to the habit being created.
        if let fireTimes = notificationFireTimes {
            // Create and associate the FireTimeMO entities with the habit.
            for fireTime in fireTimes {
                _ = fireTimeStorage.create(
                    using: context,
                    components: fireTime,
                    andHabit: habit
                )
            }

            // Create and schedule the notifications.
            _ = notificationStorage.createNotificationsFrom(habit: habit, using: context)
            notificationScheduler.scheduleNotifications(for: habit)
        }

        return habit
    }

    /// Fetches the habit with the passed id, if it exists.
    /// - Parameters:
    ///     - context: NSManagedObjectContext executing the fetch.
    ///     - identifier: The id of the habit to be fetched.
    /// - Returns: The habitMO with the provided id, if found.
    func habit(using context: NSManagedObjectContext, and identifier: String) -> HabitMO? {
        // Declare the filter predicate and the request.
        let filterPredicate = NSPredicate(format: "id = %@", identifier)
        let request: NSFetchRequest<HabitMO> = HabitMO.fetchRequest()
        request.predicate = filterPredicate

        let result = try? context.fetch(request)

        return result?.first
    }

    /// Edits the passed habit instance with the provided info.
    /// - Parameter habit: The Habit entity to be changed.
    /// - Parameter context: The context used to change the habit and the associated entities.
    /// - Parameter name: The new name of the passed habit.
    /// - Parameter days: The dates of the new DaysChallenge to be added to the entity.
    /// - Parameter notifications: The new dates of each notification object
    ///                            to be added to the habit.
    func edit(
        _ habit: HabitMO,
        using context: NSManagedObjectContext,
        name: String? = nil,
        color: HabitMO.Color? = nil,
        days: [Date]? = nil,
        andFireTimes notificationFireTimes: [DateComponents]? = nil
    ) -> HabitMO {
        if let name = name {
            habit.name = treatName(name)
        }

        if let color = color {
            habit.color = color.rawValue
        }

        if let days = days {
            editDaysChallenge(days, ofHabit: habit)
        }

        if let fireTimes = notificationFireTimes {
            editFireTimes(fireTimes, ofHabit: habit)
        }

        // If or the name or the fire times were changed, the notifications need to be rescheduled.
        if name != nil || notificationFireTimes != nil {
            notificationScheduler.unscheduleNotifications(from: habit)
            notificationScheduler.scheduleNotifications(for: habit)
        }

        return habit
    }

    /// Edits the habit's daysChallenge by closing the current and adding a new one.
    /// - Parameters:
    ///     - days: The days to be added.
    ///     - habit: The habit to be edited.
    private func editDaysChallenge(_ days: [Date], ofHabit habit: HabitMO) {
        assert(!days.isEmpty, "HabitStorage -- edit: days argument shouldn't be empty.")

        guard let context = habit.managedObjectContext else {
            assertionFailure("The habit being edited must have a context.")
            return
        }

        // Close the current habit's days' challenge:
        if let currentChallenge = habit.getCurrentChallenge() {
            currentChallenge.close()
        }

        // Add a new challenge.
        _ = daysChallengeStorage.create(
            using: context,
            daysDates: days,
            and: habit
        )
    }

    /// Edits the habit's fire times by removing the old entities and adding the new ones.
    /// - Parameters:
    ///     - fireTimes: The fire times to be added.
    ///     - habit: The habit to be edited.
    private func editFireTimes(_ fireTimes: [DateComponents], ofHabit habit: HabitMO) {
        guard let context = habit.managedObjectContext else {
            assertionFailure("The habit being edited must have a context.")
            return
        }

        // Remove the current fire time entities associated with the habit and unschedule the pending requests.
        if let currentFireTimes = habit.fireTimes as? Set<FireTimeMO> {
            notificationScheduler.unscheduleNotifications(from: habit)
            for fireTime in currentFireTimes {
                habit.removeFromFireTimes(fireTime)
                context.delete(fireTime)
            }
        }

        // Create and associate the FireTimeMO entities with the habit.
        for fireTime in fireTimes {
            _ = fireTimeStorage.create(
                using: context,
                components: fireTime,
                andHabit: habit
            )
        }
        // Create the notification entities and associate them to the habit and fire time entities.
        _ = notificationStorage.createNotificationsFrom(habit: habit, using: context)
    }

    /// Removes the passed habit from the database.
    /// - Parameter context: The context used to delete the habit from.
    func delete(_ habit: HabitMO, from context: NSManagedObjectContext) {
        notificationScheduler.unscheduleNotifications(from: habit)
        context.delete(habit)
    }

    /// Returns the treated name string.
    /// - Parameter name: The name to be treated.
    /// - Returns: The treated name.
    private func treatName(_ name: String) -> String {
        return name.trimmingCharacters(in: .whitespacesAndNewlines).capitalized
    }
}
