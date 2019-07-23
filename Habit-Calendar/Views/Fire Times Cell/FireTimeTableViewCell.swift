//
//  FireTimeTableViewCell.swift
//  Habit-Calendar
//
//  Created by  Rauan Zhorabek   on 30/02/19.
//  Copyright © 2019  Rauan Zhorabek  . All rights reserved.
//

import UIKit

/// TableViewCell displaying a fire time, which might be blocked or not.
/// - Note: This cell has a default state showing the free fire time and it also has a state showing a blocked
///         fire time. If the fire time is blocked, the name of the habit is displayed, with a line on top of
///         the fire time label.
class FireTimeTableViewCell: UITableViewCell {

    // MARK: Properties

    /// The label displaying the fire time.
    @IBOutlet weak var fireTimeLabel: UILabel!

    /// The label displaying the habit name, in case the fire time is already blocked by it.
    @IBOutlet weak var habitNameLabel: UILabel!

    /// The flag indicating if the fire time is blocked or not.
    var isFireTimeBlocked: Bool = false {
        didSet {
            // If the fire time is blocked, the user can't interact with it.
            isUserInteractionEnabled = !isFireTimeBlocked

            // Configure which views to display / hide.
            habitNameLabel?.isHidden = !isFireTimeBlocked
            blockedView?.isHidden = !isFireTimeBlocked

            // Configure the text color.
            fireTimeLabel.textColor = isFireTimeBlocked ? UIColor("#EFEFF4") : .white
            contentView.backgroundColor =  UIColor(red:0.27, green:0.33, blue:0.41, alpha:1.0)
        }
    }

    /// The color applied to the habit name label, to the blocked state view, and to the background view,
    /// in case the cell is selected or not.
    var habitColor: UIColor? {
        didSet {
            if let color = habitColor {
                habitNameLabel.textColor = color
                blockedView.color = color
            } else {
                habitNameLabel.textColor = .black
                blockedView.color = .black
            }
        }
    }

    /// A view used to indicate that the fire time is blocked or not.
    @IBOutlet weak var blockedView: BlockedDisplayView!

    // MARK: Life Cycle

    override func prepareForInterfaceBuilder() {
        setNeedsLayout()
        setNeedsDisplay()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        habitNameLabel.text = ""
        fireTimeLabel.text = ""
        isFireTimeBlocked = false
        habitColor = nil
        showDefaultState()
    }

    // MARK: Imperatives

    private func showDefaultState() {
        fireTimeLabel.textColor = .white
        contentView.backgroundColor = UIColor(red:0.27, green:0.33, blue:0.41, alpha:1.0)
    }

    /// Shows the selected state for the current cell.
    func select() {
        isFireTimeBlocked = false
        contentView.backgroundColor = habitColor
        fireTimeLabel.textColor = .white
    }

    /// Deselects the view and shows the default state of the cell.
    func deselect() {
        showDefaultState()
    }
}
