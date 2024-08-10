//
//  scheduleLocalNotification.swift
//  Note001
//
//  Created by Sophors Pheng on 7/21/24.
//

import UserNotifications

func scheduleLocalNotification() {
    let center = UNUserNotificationCenter.current()

    let content = UNMutableNotificationContent()
    content.title = "Title"
    content.body = "Body"
    content.sound = UNNotificationSound.default

    // Configure the trigger for a specific date and time.
    var dateComponents = DateComponents()
    dateComponents.calendar = Calendar.current
//    dateComponents.hour = 10
    dateComponents.second = 5
//    dateComponents.minute = 30

    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

    // Create the request
    let uuidString = UUID().uuidString
    let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)

    // Schedule the request with the system.
    center.add(request) { (error) in
        if error != nil {
            // Handle any errors.
        }
    }
}
