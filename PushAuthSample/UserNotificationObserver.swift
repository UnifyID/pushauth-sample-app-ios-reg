//
//  UserNotificationObserver.swift
//  PushAuthSample
//
//  Created by Ricardo Suranta on 6/9/20.
//  Copyright © 2020 UnifyID. All rights reserved.
//

import UIKit
import UnifyID
import PushAuth

/// Responsible for observing UNUserNotifications.
/// - note: This class is responsible to process the incoming notification into PushAuth requests.
class UserNotificationObserver: NSObject {
    
    // MARK: - Public properties
    
    /// The UnifyID object that's used to listen to the PushAuth.
    let unifyID: UnifyID
    
    /// Notification center object that provides incoming notifcation object.
    let userNotificationCenter: UNUserNotificationCenter
    
    /// Callback that gets called when this instance receives a PushAuthRequest.
    var pushAuthRequestHandler: ((PushAuthRequest) -> Void)?
    
    /// Callback that gets called when this instance receives a general user notification.
    var generalNotificationHandler: ((UNNotification) -> Void)?
    
    // MARK: - Public methods
    
    /// Constructor for this class.
    init(unifyID: UnifyID, userNotificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()) {
        self.unifyID = unifyID
        self.userNotificationCenter = userNotificationCenter
        
        super.init()
        userNotificationCenter.delegate = self
    }
    
    /// Requests current user's permission for current app to receive remote notifications.
    /// - note: Upon proper request, the app might receive device token in UIApplicationDelegate's `application(_:didRegisterForRemoteNotificationsWithDeviceToken:)`.
    ///         Please pass the received token string to this instance's `registerDeviceTokenForNotification(deviceToken:)` method.
    func requestUserNotificationPermission() {
        userNotificationCenter.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.setupUserNotification(basedOn: settings)
            }
        }
    }
    
    /// Registers the passed `deviceToken` so current app could receive proper PushAuth notifications.
    /// - note: The given `deviceToken` should come from UIApplicationDelegate's `application(_:didRegisterForRemoteNotificationsWithDeviceToken:)` method.
    func registerDeviceTokenForNotification(deviceToken: String) {
        unifyID.pushAuth.registerPushToken(deviceToken) { (error: PushAuthError?) in
            if let validError = error {
                // TODO: SDK-2282 present this error with proper UI.
                print("Error when registering Push Auth: \(validError.localizedDescription)")
            }
        }
    }
    
    // MARK: - Private methods
    
    private func setupUserNotification(basedOn settings: UNNotificationSettings) {
        
        switch (settings.alertSetting) {
        case .enabled:
            UIApplication.shared.registerForRemoteNotifications()
            
        case .disabled, .notSupported:
            
            userNotificationCenter
                .requestAuthorization(options: [.sound, .alert]) { [weak self] (authorized, error) in
                    
                    if let validError = error {
                        // TODO: SDK-2282 present this error with proper UI.
                        print("Error when requesting user notification authorization: \(validError.localizedDescription)")
                    } else if !authorized {
                        // TODO: SDK-2282 present this error with proper UI.
                        print("User did not authorize the notification observing request.")
                    } else {
                        self?.requestUserNotificationPermission() // check if it's enabled now.
                    }
            }
            
        @unknown default:
            // TODO: SDK-2282 present this error with proper UI.
            print("Invalid alert settings response: \(settings.alertSetting)")
        }
    }
    
}

// MARK: - UNUserNotificationCenterDelegate extension

extension UserNotificationObserver: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        defer {
            completionHandler(UNNotificationPresentationOptions())
        }
        
        guard let pushAuthRequest = unifyID.pushAuth.pushAuthRequest(notification) else {
            generalNotificationHandler?(notification)
            return
        }
        
        pushAuthRequestHandler?(pushAuthRequest)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        defer {
            completionHandler()
        }
           
        guard let pushAuthRequest = unifyID.pushAuth.pushAuthRequest(response) else {
            return
        }
        
        let pushAuthResponse = pushAuthRequest.userResponse
        
        switch pushAuthResponse {
        case .unknown:
            pushAuthRequestHandler?(pushAuthRequest)
            
        case .accept, .decline: // User responding to a notification
            
            pushAuthRequest.respond(pushAuthResponse) { (error: PushAuthError?) in
                
                if let validError = error {
                    // TODO: SDK-2282 present this error with proper UI.
                    print("Error found when asking user's response to push auth: \(validError)")
                } else {
                    // TODO: SDK-2282 present this error with proper UI.
                    print("Succeeded asking user's response to push auth: \(pushAuthResponse)")
                }
                
            }
            
        @unknown default:
            // TODO: SDK-2282 present this error with proper UI.
            print("Invalid push auth response: \(pushAuthResponse)")
        }
    }
}
