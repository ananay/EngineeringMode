//
//  NotificationsView.swift
//  
//
//  Created by Ananay Arora on 6/29/23.
//

import SwiftUI

/**
 * Formats the Trigger Description
 */
func triggerDescriptionFormatter(_ trigger: UNNotificationTrigger) -> String {
    if let calendarTrigger = trigger as? UNCalendarNotificationTrigger {
        let date = calendarTrigger.nextTriggerDate()
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return "Calendar Trigger: \(formatter.string(from: date ?? Date()))"
    } else if let intervalTrigger = trigger as? UNTimeIntervalNotificationTrigger {
        return "Time Interval Trigger: \(intervalTrigger.timeInterval) seconds"
    } else if let locationTrigger = trigger as? UNLocationNotificationTrigger {
        return "Location Trigger"
    } else {
        return "Unknown Trigger"
    }
}

/**
 * Returns all pending notifications
 */
func listAllNotifications() async -> [UNNotificationRequest] {
    return await withCheckedContinuation { continuation in
        UNUserNotificationCenter.current().getPendingNotificationRequests { pendingNotifications in
            continuation.resume(returning: pendingNotifications)
        }
    }
}


@available(iOS 15.0, *)
struct NotificationsView: View {
    
    @State private var pendingNotificationRequests: [UNNotificationRequest] = []
    
    var body: some View {
        VStack {
            if (pendingNotificationRequests.count == 0) {
                Spacer()
                HStack() {
                    Spacer()
                    Text("No pending notifications.")
                    Spacer()
                }
                Spacer()
            } else {
                List(pendingNotificationRequests, id: \.identifier) { request in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(request.content.title)
                            .font(.headline)
                        Text(request.content.body)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Identifier: \(request.identifier)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        if let trigger = request.trigger {
                            Text("Trigger: \(triggerDescriptionFormatter(trigger))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .task {
            pendingNotificationRequests = await listAllNotifications()
        }
    }
}
