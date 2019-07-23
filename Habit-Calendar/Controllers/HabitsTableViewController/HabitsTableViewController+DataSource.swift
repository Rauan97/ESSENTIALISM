//
//  HabitsTableViewController+DataSource.swift
//  Habit-Calendar
//
//  Created by  Rauan Zhorabek   on 15/02/19.
//  Copyright © 2019  Rauan Zhorabek  . All rights reserved.
//

import UIKit

extension HabitsTableViewController {

    // MARK: DataSource Methods

    override func numberOfSections(in tableView: UITableView) -> Int {
        return selectedFetchedResultsController.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = selectedFetchedResultsController.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        }

        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?

        // Get the current habit object.
        let habit = selectedFetchedResultsController.object(at: indexPath)
        cell = tableView.dequeueReusableCell(
            withIdentifier: inProgressHabitCellIdentifier,
            for: indexPath
        )
        if let cell = cell as? ProgressHabitTableViewCell {
            // Display the habit properties:
            // Its name.
            cell.nameLabel?.text = habit.name
            // And its progress.
            let progress = habit.getCurrentChallenge()?.getCompletionProgress() ?? (0, 0)
            cell.progressLabel?.text = String.localizedStringWithFormat(
                NSLocalizedString(
                    "%0.0f%% completed.",
                    comment: "The percentage indicating the completion of the challenge."
                ),
                (Double(progress.0) / Double(progress.1)) * 100.0
            )
            cell.progressBar.tint = habit.getColor().uiColor
            // Change the bar's progress (past days / total).
            cell.progressBar.progress = CGFloat(Double(progress.0) / Double(progress.1))
        }
        return cell!
    }

    // MARK: Delegate methods

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return 145
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: detailsSegueIdentifier, sender: self)
    }
}
