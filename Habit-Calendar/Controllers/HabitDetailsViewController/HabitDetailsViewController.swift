//
//  HabitDetailsViewController.swift
//  Active
//
//  Created by  Rauan Zhorabek   on 02/02/19.
//  Copyright © 2019  Rauan Zhorabek  . All rights reserved.
//

import UIKit
import CoreData
import JTAppleCalendar
import UserNotifications

class HabitDetailsViewController: UIViewController {

    // MARK: Properties

    /// The habit presented by this controller.
    weak var habit: HabitMO! {
        didSet {
            habitColor = habit.getColor().uiColor

            // Store the initial and final calendar dates.
            startDate = habit.createdAt ?? Date()

            // The final date or is the last day of the habit or today, depending on which date is higher.
            let today = Date().getBeginningOfDay()
            let lastHabitDayDate = habit.getFutureDays().compactMap { $0.day?.date }.sorted().last

            if lastHabitDayDate != nil && today.compare(lastHabitDayDate!) == .orderedAscending {
                finalDate = lastHabitDayDate!
            } else {
                finalDate = today
            }
        }
    }

    /// The current habit's color.
    var habitColor: UIColor!

    /// The habit's ordered challenge entities to be displayed.
    /// - Note: This array mustn't be empty. The existence of challenges is ensured
    ///         in the habit's creation and edition process.
    var challenges: [DaysChallengeMO]!

    /// The initial calendar date.
    internal var startDate: Date!

    /// The final calendar date.
    internal var finalDate: Date!

    /// The habit storage used to manage the controller's habit.
    var habitStorage: HabitStorage!

    /// The habit day storage used to create an entity associated to today.
    var habitDayStorage: HabitDayStorage!

    /// The persistent container used by this store to manage the provided habit.
    weak var container: NSPersistentContainer!

    /// The shortcuts manager used to add a new shortcut when the habit is displayed.
    var shortcutsManager: HabitsShortcutItemsManager!

    /// The edit segue identifier taking to the HabitCreationViewController.
    private let editSegueIdentifier = "Edit the habit"

    /// The identifier of the "new challenge" segue taking to the HabitDaysSelectionViewController.
    private let newChallengeSegueIdentifier = "Add new challenge to the habit"

    /// The identifier of the segue taking to the FireTimesSelectionController.
    private let newFireTimesSegueIdentifier = "Add fire times to habit"

    /// The cell's reusable identifier.
    internal let cellIdentifier = "challenge day cell id"

    /// The calendar view showing the habit days.
    /// - Note: The collection view will show a range with
    ///         the Habit's first days until the last ones.
    @IBOutlet weak var calendarView: JTAppleCalendarView!

    /// The month header view, with the month label and next/prev buttons.
    @IBOutlet weak var monthHeaderView: MonthHeaderView! {
        didSet {
            monthTitleLabel = monthHeaderView.monthLabel
            nextMonthButton = monthHeaderView.nextButton
            previousMonthButton = monthHeaderView.previousButton
        }
    }

    /// The month title label in the calendar's header.
    internal weak var monthTitleLabel: UILabel!

    /// The next month header button.
    internal weak var nextMonthButton: UIButton! {
        didSet {
            nextMonthButton.addTarget(self, action: #selector(goNext), for: .touchUpInside)
        }
    }

    /// The previous month header button.
    internal weak var previousMonthButton: UIButton! {
        didSet {
            previousMonthButton.addTarget(self, action: #selector(goPrevious), for: .touchUpInside)
        }
    }

    /// The notificationStorage used to get the notifications for the current day.
    var notificationStorage: NotificationStorage!

    /// The notificationScheduler used to unschedule the current day's notifications, in case it's marked as executed.
    var notificationScheduler: NotificationScheduler!

    /// The current challenge header.
    @IBOutlet weak var challengeHeaderStackView: UIStackView!

    /// The label displaying the current challenge's from and to dates.
    @IBOutlet weak var currentChallengeDurationLabel: UILabel!

    /// The view holding the prompt for the current day.
    /// - Note: This view is only displayed if today is a challenge day to be accounted.
    @IBOutlet weak var promptContentView: UIView!

    /// The title displaying what challenge's day is today.
    @IBOutlet weak var currentDayTitleLabel: UILabel!

    /// The switch the user uses to mark the current habit's day as executed.
    @IBOutlet weak var wasExecutedSwitch: UISwitch!

    /// The supporting label informing the user that the activity was executed.
    @IBOutlet weak var promptAnswerLabel: UILabel!

    /// The view holding the habit's current active challenge's progress section.
    /// - Note: This view is only displayed if there's an active challenge for the habit.
    @IBOutlet weak var challengeProgressContentView: UIView!

    /// The label displaying how many days to finish the current days' challenge.
    @IBOutlet weak var daysToFinishLabel: UILabel!

    /// The label displaying how many days were executed in the current days' challenge.
    @IBOutlet weak var executedDaysLabel: UILabel!

    /// The label displaying how many days were missed in the current days' challenge.
    @IBOutlet weak var missedDaysLabel: UILabel!

    /// The bar view displaying the current challenge's progress.
    @IBOutlet weak var progressBar: ProgressView!

    /// The view holding the "No active challenge" section.
    @IBOutlet weak var noChallengeContentView: UIView!

    /// The new challenge button displayed for the habits that don't have an active days'
    /// challenge at the moment.
    @IBOutlet weak var newChallengeButton: RoundedButton!

    /// The notification manager used to get the authorization status.
    var notificationManager: UserNotificationManager!

    /// The view containing the fire time labels.
    @IBOutlet weak var fireTimesContentView: UIView!

    /// The label displaying the number of selected fire times.
    @IBOutlet weak var fireTimesAmountLabel: UILabel!

    /// The label displaying the habit's fire times.
    @IBOutlet weak var fireTimesLabel: UILabel!

    /// The view containing information for when there are no fire times set for the habit.
    @IBOutlet weak var noFireTimesContentView: UIView!

    /// The content view showing that notifications aren't authorized by the user.
    @IBOutlet weak var notificationsAuthContentView: UIView!

    /// The button that takes to the fire times controller.
    @IBOutlet weak var newFireTimesButton: RoundedButton!

    // MARK: Deinitializers

    deinit {
        stopObserving()
    }

    // MARK: ViewController Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        checkDependencies()
        startObserving()

        // Refresh the current entity, so it's always in sync with the store. The habit entity might be changed
        // from a notification content extension, and the controller should reflect the user's choice.
        if let context = habit.managedObjectContext {
            context.performAndWait {
                context.refresh(habit!, mergeChanges: true)
            }
        }

        // Get the habit's challenges to display in the calendar.
        challenges = getChallenges(from: habit)

        // Configure the calendar.
        calendarView.calendarDataSource = self
        calendarView.calendarDelegate = self

        title = habit.name
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Show the current date in the calendar.
        let today = Date().getBeginningOfDay()
        calendarView.scrollToDate(today)

        // Display the initial state of the sections.
        displaySections()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        /// Every time a habit is displayed, add an app shortcut for it.
        if habit != nil {
            shortcutsManager.addApplicationShortcut(for: habit)
        }
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case editSegueIdentifier:
            guard let editionController = segue.destination as? HabitCreationTableViewController else {
                assertionFailure("Error: Couldn't get the HabitCreationController.")
                return
            }

            editionController.habitHandlerViewModel = HabitHandlerViewModel(
                habit: habit,
                habitStorage: habitStorage,
                userStorage: UserStorage(),
                container: container,
                shortcutsManager: shortcutsManager
            )
            editionController.notificationManager = notificationManager

        case newChallengeSegueIdentifier:
            guard let daysSelectionController = segue.destination as? HabitDaysSelectionViewController else {
                assertionFailure("Error: Couldn't get the HabitDaysSelectionController")
                return
            }
            daysSelectionController.themeColor = habitColor
            daysSelectionController.delegate = self

        case newFireTimesSegueIdentifier:
            guard let fireTimesSelectionController = segue.destination as? FireTimesSelectionViewController else {
                assertionFailure("Error: Couldn't get the FireTimesSelectionController")
                return
            }
            fireTimesSelectionController.delegate = self
            fireTimesSelectionController.container = container
            fireTimesSelectionController.fireTimesStorage = FireTimeStorage()
            fireTimesSelectionController.themeColor = habitColor

        default:
            break
        }
    }

    // MARK: Actions

    /// Makes the calendar display the next month.
    @objc private func goNext() {
        goToNextMonth()
    }

    /// Makes the calendar display the previous month.
    @objc private func goPrevious() {
        goToPreviousMonth()
    }

    // MARK: Imperatives

    /// Asserts on the values of the main controller's dependencies.
    private func checkDependencies() {
        // Assert on the required properties to be injected
        // (habit, habitStorage, container and the calendar header views):
        assert(
            habit != nil,
            "Error: the needed habit wasn't injected."
        )
        assert(
            habitStorage != nil,
            "Error: the needed habitStorage wasn't injected."
        )
        assert(
            habitDayStorage != nil,
            "Error: the habit day storage must be injected."
        )
        assert(
            container != nil,
            "Error: the needed container wasn't injected."
        )
        assert(
            monthTitleLabel != nil,
            "Error: the month title label wasn't set."
        )
        assert(
            nextMonthButton != nil,
            "Error: the next month button wasn't set."
        )
        assert(
            previousMonthButton != nil,
            "Error: the previous month button wasn't set."
        )
        assert(
            notificationManager != nil,
            "Error: the notification manager wasn't injected."
        )
        assert(
            notificationStorage != nil,
            "Error: the notification storage wasn't injected."
        )
        assert(
            notificationScheduler != nil,
            "Error: the notification scheduler wasn't injected."
        )
        assert(
            shortcutsManager != nil,
            "Error: the shortcuts manager must be injected."
        )
    }

    /// Updates and handles the display of each controller's section.
    func displaySections() {
        // Configure the appearance of the prompt section.
        displayPromptView()

        // Configure the appearance of the challenge's progress section.
        displayProgressSection()

        // Display the no challenge view, if there's no active challenge for the habit.
        displayNoChallengesView()

        // Display the fire times section.
        displayFireTimesSection()
    }

    /// Gets the challenges from the passed habit ordered by the fromDate property.
    /// - Returns: The habit's ordered challenges.
    func getChallenges(from habit: HabitMO) -> [DaysChallengeMO] {
        // Declare and configure the fetch request.
        let request: NSFetchRequest<DaysChallengeMO> = DaysChallengeMO.fetchRequest()
        request.predicate = NSPredicate(format: "habit = %@", habit)
        request.sortDescriptors = [NSSortDescriptor(key: "fromDate", ascending: true)]

        // Fetch the results.
        let results = (try? container.viewContext.fetch(request)) ?? []

        return results
    }

    /// Gets the challenge matching a given date.
    /// - Note: The challenge is found if the date is in between or is it's begin or final.
    /// - Returns: The challenge entity, if any.
    func getChallenge(from date: Date) -> DaysChallengeMO? {
        // Try to get the matching challenge by filtering through the habit's fetched ones.
        // The challenge matches when the passed date or is in between,
        // or is one of the challenge's limit dates (begin or end).
        let filteredChallenges = challenges.filter {
            let fromDate = $0.fromDateInCurrentTimeZone
            let toDate = $0.toDateInCurrentTimeZone

            return date.isInBetween(fromDate, toDate) ||
                date.compare(fromDate) == .orderedSame ||
                date.compare(toDate) == .orderedSame
        }

        // If there's more than one challenge, filter by the ones that are open.
        if filteredChallenges.count > 1 {
            return filteredChallenges.filter { !$0.isClosed }.first
        } else {
            return filteredChallenges.last
        }
    }
}
