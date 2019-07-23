//
//  HabitHandlerViewModelContract.swift
//  Habit-Calendar
//
//  Created by  Rauan Zhorabek   on 05/02/19.
//  Copyright © 2019  Rauan Zhorabek  . All rights reserved.
//

import CoreData

/// Protocol defining the interface of any view models to be used with the HabitCreationViewController.
protocol HabitHandlerViewModelContract {

    // MARK: Properties

    /// Flag indicating if the habit is being edited.
    var isEditing: Bool { get }

    /// Flag indicating if the creation/edition operations are valid.
    var isValid: Bool { get }

    /// Flag indicating if the deletion operation is available.
    var canDeleteHabit: Bool { get }

    /// The container used by the view model.
    var container: NSPersistentContainer { get }

    /// The delegate of this view model.
    var delegate: HabitHandlingViewModelDelegate? { get set }

    // MARK: Initializers

    init(habit: HabitMO?,
         habitStorage: HabitStorage,
         userStorage: UserStorage,
         container: NSPersistentContainer,
         shortcutsManager: HabitsShortcutItemsManager)

    // MARK: Imperatives

    /// Deletes the habit, if deletable (The controller only shows the deletion option in case the habit
    /// is being edited).
    func deleteHabit()

    /// Saves the habit, if valid.
    func saveHabit()

    /// Returns the name of the habit to be displayed to the user, if set.
    func getHabitName() -> String?

    /// Sets the name of the habit.
    mutating func setHabitName(_ name: String)

    /// Returns the color of the habit, if set.
    func getHabitColor() -> HabitMO.Color?

    /// Sets the color of the habit.
    mutating func setHabitColor(_ color: HabitMO.Color)

    /// Returns the days selected for a challenge of days, if set.
    func getSelectedDays() -> [Date]?

    /// Sets the selected days for the challenge.
    mutating func setDays(_ days: [Date])

    /// Returns a text describing how many days were selected so far.
    func getDaysDescriptionText() -> String

    /// Returns the first date text from the sorted selected days.
    func getFirstDateDescriptionText() -> String?

    /// Returns the last date text from the sorted selected days.
    func getLastDateDescriptionText() -> String?

    /// Returns the selected fire times components, if set.
    func getFireTimeComponents() -> [DateComponents]?

    /// Sets the selected fire time components.
    mutating func setSelectedFireTimes(_ fireTimes: [DateComponents])

    /// Returns a text describing how many fire times were selected.
    func getFireTimesAmountDescriptionText() -> String

    /// Returns a text describing the selected fire times.
    func getFireTimesDescriptionText() -> String?
}

extension HabitHandlerViewModelContract {
    var canDeleteHabit: Bool {
        return isEditing
    }
}

protocol HabitHandlingViewModelDelegate: class {
    /// Handles the errors that might happen while saving the habits.
    func didReceiveSaveError(_ error: Error)
}
