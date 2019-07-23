//
//  HabitDetailsViewController+NotificationObserver.swift
//  Habit-Calendar
//
//  Created by  Rauan Zhorabek   on 25/02/19.
//  Copyright © 2019  Rauan Zhorabek  . All rights reserved.
//

import UIKit
import CoreData

extension HabitDetailsViewController: NotificationObserver {

    func startObserving() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleContextChanges(_:)),
            name: Notification.Name.NSManagedObjectContextDidSave,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleActivationEvent(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    func stopObserving() {
        NotificationCenter.default.removeObserver(self)
    }
}

extension HabitDetailsViewController: AppActiveObserver {
    @objc func handleActivationEvent(_ notification: Notification) {
        // Make sure the habit was injected before doing anything.
        guard habit != nil else { return }

        calendarView.reloadData()
        displaySections()

        displayNotificationAvailability()
    }
}

extension HabitDetailsViewController: ManagedContextChangeObserver {

    /// Listens to any saved changes happening in other contexts and refreshes
    /// the viewContext.
    /// - Parameter notification: The thrown notification
    @objc func handleContextChanges(_ notification: Notification) {
        // If there's an update in the habit being displayed, update the controller's view.
        if (notification.userInfo?["updated"] as? Set<NSManagedObject>) != nil {
            DispatchQueue.main.async {
                // Update the title, if changed.
                if self.title != self.habit.name {
                    self.title = self.habit.name
                }

                // Update the habit's color.
                self.habitColor = self.habit.getColor().uiColor

                // Update the challenges.
                self.challenges = self.getChallenges(from: self.habit)

                // Update the calendar.
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                    self.calendarView.reloadData()
                    self.calendarView.scrollToDate(
                        Date().getBeginningOfDay() // Today
                    )
                }

                // Update the sections.
                self.displaySections()
            }
        }

        // Merge the changes from the habit's edition.
        container.viewContext.mergeChanges(fromContextDidSave: notification)
    }
}
