//
//  NotificationService.swift
//  Notifications
//
//  Created by Dániel Zolnai on 26/07/2024.
//

import UserNotifications
import Tiqr

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    private let appGroup = Bundle.main.object(forInfoDictionaryKey: "TIQRAppGroup") as! String

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        // We do not modify the notification, we just read the payload
        let payload = bestAttemptContent?.userInfo
        let challenge = payload?["challenge"]
        let authenticationTimeout = payload?["authenticationTimeout"]
        let serviceName = payload?["serviceName"] as? String
        RecentNotifications(appGroup: appGroup).onNewNotification(timeOut: authenticationTimeout,
                                                                  challenge: challenge,
                                                                  serviceName: serviceName,
                                                                  notificationId: request.identifier)
        contentHandler(bestAttemptContent ?? UNMutableNotificationContent())
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
