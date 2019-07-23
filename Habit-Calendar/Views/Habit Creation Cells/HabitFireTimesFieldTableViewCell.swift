//
//  HabitFireTimesFieldTableViewCell.swift
//  Habit-Calendar
//
//  Created by  Rauan Zhorabek   on 13/02/19.
//  Copyright © 2019  Rauan Zhorabek  . All rights reserved.
//

import UIKit

/// This table view cell displays a field informing the selected fire times for a habit.
class HabitFireTimesFieldTableViewCell: UITableViewCell {

    // MARK: Properties

    /// The label displaying the title of the field.
    @IBOutlet var titleLabel: UILabel!

    /// The label displaying the number of selected fire times.
    @IBOutlet var fireTimesAmountLabel: UILabel!

    /// The label displaying the hour and minute of some fire times.
    @IBOutlet var fireTimesLabel: UILabel!

    var themeColor: UIColor? {
        didSet {
            if let color = themeColor {
                fireTimesAmountLabel.textColor = color
                fireTimesLabel.textColor = color
            }
        }
    }

    // MARK: Impertives

    override func prepareForReuse() {
        super.prepareForReuse()

        fireTimesAmountLabel.text = ""
        fireTimesLabel.text = ""
    }
}
