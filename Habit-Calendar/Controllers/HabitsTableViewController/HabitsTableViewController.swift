//
//  HabitsTableViewController.swift
//  Active
//
//  Created by  Rauan Zhorabek   on 06/02/19.
//  Copyright © 2019  Rauan Zhorabek  . All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

/// Controller in charge of displaying the list of tracked habits.
class HabitsTableViewController: UITableViewController {

    // MARK: Types

    /// The segments displayed by this controller, which show habits in progress and habits that are daily.
    // MARK: Properties

    /// The identifier for the habit creation controller's segue.
    let newHabitSegueIdentifier = "Create a new habit"

    /// The identifier for the habit details controller's segue.
    let detailsSegueIdentifier = "Show habit details"

    /// The in progress habit cell's reuse identifier.
    let inProgressHabitCellIdentifier = "In progress habit table view cell"

    /// The daily habit cell's reuse identifier.
    let dailyHabitCellIdentifier = "Daily habit table view cell"

    /// The used persistence container.
    weak var container: NSPersistentContainer!

    /// The Habit storage used to fetch the tracked habits.
    var habitStorage: HabitStorage!

    /// The user notification manager used to check or request the user's authorization.
    var notificationManager: UserNotificationManager!

    /// The shortcuts manager to be injected in the creation and details controllers.
    var shortcutsManager: HabitsShortcutItemsManager!

    /// The segmented control used to change the habits being displayed, based on its stage (daily or in progress).

    /// The variable holding the current(related to today) fetchedResultsController for the habits that are in progress.
    /// - Note: To re-initialize this property, only set it to nil, and use the getter.
    private var _progressfetchedResultsController: NSFetchedResultsController<HabitMO>?

    /// The fetched results controller used to get the habits that are in progress and display them with the tableView.
    var progressfetchedResultsController: NSFetchedResultsController<HabitMO> {
        if _progressfetchedResultsController == nil {
            let fetchedController = habitStorage.makeFetchedResultsController(context: container.viewContext)
            fetchedController.delegate = self
            _progressfetchedResultsController = fetchedController
        }

        return _progressfetchedResultsController!
    }

    /// The variable holding the current(related to today) fetchedResultsController for the daily habits.
    /// - Note: To re-initialize this property, only set it to nil, and use the getter.
    private var _dailyfetchedResultsController: NSFetchedResultsController<HabitMO>?

    /// The fetched results controller used to get the habits that are daily and display them with the tableView.
    var dailyfetchedResultsController: NSFetchedResultsController<HabitMO> {
        if _dailyfetchedResultsController == nil {
            let fetchedController = habitStorage.makeDailyFetchedResultsController(context: container.viewContext)
            fetchedController.delegate = self
            _dailyfetchedResultsController = fetchedController
        }

        return _dailyfetchedResultsController!
    }

    /// The currently selected segment.
    /// The fetched results controller for the selected segment (in progress or daily habits).
    /// - Note: This is the fetched results controller used by the tableView's data source, which is chosen based
    ///         on the currently selected segmented.
    var selectedFetchedResultsController: NSFetchedResultsController<HabitMO> {
        return progressfetchedResultsController
    }

    /// The empty state view showing the controller's initial states (no habits, or no habits in the segments)
    private var emptyStateView: EmptyStateView!

    // MARK: Deinitialization

    deinit {
        stopObserving()
    }

    // MARK: ViewController Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Assert if the dependencies were properly injected.
        assert(container != nil, "The persistent container must be injected.")
        assert(habitStorage != nil, "The habit storage must be injected.")
        assert(notificationManager != nil, "The notification manager must be injected.")
        assert(shortcutsManager != nil, "The shortcuts manager must be injected.")

        startObserving()

        // Configure the nav bar.
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barTintColor = UIColor(red:0.27, green:0.33, blue:0.41, alpha:1.0)
        navigationController?.navigationBar.backgroundColor = UIColor(red:0.27, green:0.33, blue:0.41, alpha:1.0)
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        // Remove the empty separators from the table view.
        tableView.tableFooterView = UIView()

        // Load the empty state view and add it as the tableView's background view.
        emptyStateView = makeEmptyStateView()
        emptyStateView.callToActionButton.addTarget(self, action: #selector(createNewHabit), for: .touchUpInside)

        tableView.backgroundView = emptyStateView
        self.tableView.backgroundColor = UIColor(red:0.27, green:0.33, blue:0.41, alpha:1.0)

        displayPresentationIfNeeded()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateList()
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case newHabitSegueIdentifier:
            // Inject the controller's habit storage, user storage,
            // and persistent container.
            if let habitCreationController = segue.destination as? HabitCreationTableViewController {
                habitCreationController.habitHandlerViewModel = HabitHandlerViewModel(
                    habit: nil,
                    habitStorage: habitStorage,
                    userStorage: UserStorage(),
                    container: container,
                    shortcutsManager: shortcutsManager
                )
                habitCreationController.notificationManager = notificationManager
            } else {
                assertionFailure(
                    "Error: Couldn't get the habit creation controller."
                )
            }
        case detailsSegueIdentifier:
            // Inject the controller's habit, habit storage and container.
            if let habitDetailsController = segue.destination as? HabitDetailsViewController {
                habitDetailsController.container = container
                habitDetailsController.habitStorage = habitStorage
                habitDetailsController.habitDayStorage = HabitDayStorage(calendarDayStorage: DayStorage())
                habitDetailsController.notificationManager = notificationManager
                habitDetailsController.notificationStorage = NotificationStorage()
                habitDetailsController.notificationScheduler = NotificationScheduler(
                    notificationManager: notificationManager
                )
                habitDetailsController.shortcutsManager = shortcutsManager

                // Get the selected habit for injection.
                guard let indexPath = tableView.indexPathForSelectedRow else {
                    assertionFailure("Error: couldn't get the user's selected row.")
                    return
                }
                let selectedHabit = selectedFetchedResultsController.object(at: indexPath)

                // Inject the selected habit.
                habitDetailsController.habit = selectedHabit
            } else {
                assertionFailure(
                    "Error: Couldn't get the habit details controller."
                )
            }
        default:
            break
        }
    }

    // MARK: Actions

    @IBAction func switchSegment(_ sender: UISegmentedControl) {
        updateList()
    }

    @objc private func createNewHabit() {
        performSegue(withIdentifier: newHabitSegueIdentifier, sender: self)
    }

    // MARK: Imperatives

    /// Updates the list to take the today's date as a fetch parameter.
    func refreshListDate() {
        self._progressfetchedResultsController = nil
    }

    /// Updates the controller's list of habits.
    func updateList() {
        do {
            try selectedFetchedResultsController.performFetch()
            displayEmptyStateIfNeeded()
            tableView.reloadData()
        } catch {
            present(
                UIAlertController.make(
                    title: NSLocalizedString("Error", comment: "The alert title in the habits listing controller."),
                    message: NSLocalizedString(
                        "An error occurred while listing your habits. Please contact the developer.",
                        comment: "The message displayed when the habits couldn't be fetched."
                    )
                ),
                animated: true
            )
            assertionFailure("An error occurred while performing the fetch for habits.")
        }
    }

    /// Instantiates a new EmptyStateView for usage.
    /// - Returns: The instantiated EmptyStateView.
    private func makeEmptyStateView() -> EmptyStateView {
        // Load the nib, get its root view and return it.
        let nibContents = Bundle.main.loadNibNamed("EmptyStateView", owner: nil, options: nil)

        guard let emptyStateView = nibContents!.first as? EmptyStateView else {
            assertionFailure("Couldn't load the empty state view from the nib file.")
            return EmptyStateView()
        }

        return emptyStateView
    }

    /// Display the controller's empty state depending on the user's added habits.
    func displayEmptyStateIfNeeded() {
        // Check if the user has any habits, if he doesn't, display the empty state.
        if let count = try? container.viewContext.count(for: HabitMO.fetchRequest()), count == 0 {
            emptyStateView.isHidden = false
            emptyStateView.callToActionButton.isHidden = false
            emptyStateView.emptyLabel.text = NSLocalizedString(
                "You don't have any habits yet. Let's begin by adding a new one!",
                comment: "Message displayed when the user doesn't have any habit."
            )

            return
        }

        // Check if the selected segment has habits, if it doesn't, display an appropriated message.
        if selectedFetchedResultsController.fetchedObjects?.count == 0 {
            emptyStateView.isHidden = false
            emptyStateView.callToActionButton.isHidden = true
            emptyStateView.emptyLabel.text = NSLocalizedString(
                "You don't have any habits in progress at the moment, what do you think of new challenges?",
                comment: "Message displayed when the user doesn't have any habit in progress."
            )
            emptyStateView.callToActionButton.isHidden = false
            return
        }

        // If there're habits, just hide the empty state view.
        emptyStateView.isHidden = true
    }

    /// Displays the onBoarding controllers if necessary (Is it first login? Is the environment dev?).
    private func displayPresentationIfNeeded() {
        guard UserDefaults.standard.isFirstLaunch else { return }
        // Get the controller from the storyboard.
        guard let presentationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(
            withIdentifier: "On Boarding"
            ) as? OnBoardingViewController else {
                assertionFailure("Couldn't get the onBoarding controller.")
                return
        }
        presentationController.notificationManager = notificationManager

        // Present it on top of the window's root controller.
        present(presentationController, animated: true)
    }
}
