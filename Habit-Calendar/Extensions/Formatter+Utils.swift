//
//  Formatter+Utils.swift
//  Active
//
//  Created by  Rauan Zhorabek   on 17/08/19.
//  Copyright © 2019  Rauan Zhorabek  . All rights reserved.
//

import Foundation

extension DateFormatter {

    /// The short styled formatter configure with the current settings (calendar, time zone, and locale).
    static var shortCurrent: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.calendar = Calendar.current
        formatter.locale = Locale.current
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.dateFormat = "hh:mm a"
        return formatter
    }

    /// Creates a new DateFormatter used to display notification fire times.
    /// - Returns: The FireTime date formatter.
    static var fireTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.timeStyle = .short
        //formatter.setLocalizedDateFormatFromTemplate("HH:mm a")
        formatter.dateFormat = "hh:mm a"
        return formatter
    }
}

extension NumberFormatter {

    /// The local ordinal formatter.
    static var localOrdinal: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        formatter.locale = .current
        return formatter
    }
}
