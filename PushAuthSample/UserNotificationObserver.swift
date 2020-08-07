//
// Copyright © 2020 UnifyID, Inc. All rights reserved.
// Unauthorized copying or excerpting via any medium is strictly prohibited.
// Proprietary and confidential.
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
    /// Callback that gets called when this instance gets any error.
    var errorHandler: ((Error) -> Void)?
    
    // MARK: - Public methods
    
    /// Constructor for this class.
    init(unifyID: UnifyID, userNotificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()) {
        self.unifyID = unifyID
        self.userNotificationCenter = userNotificationCenter
        
        super.init()
        userNotificationCenter.delegate = self
    }
    
    /// Requests the pending PushAuth requests to the server, which will trigger this instance's `pushAuthRequestHandler`.
    func requestPendingPushAuthRequests() {
        unifyID.pushAuth.getPendingAuthenticationRequests { [weak self] result in
            switch result {
            case .failure(let error):
                self?.errorHandler?(error)
            case .success(let pendingRequests):
                for request in pendingRequests {
                    self?.pushAuthRequestHandler?(request)
                }
            }
        }
    }
    
    /// Registers the passed `deviceToken` so current app could receive proper PushAuth notifications.
    /// - note: The given `deviceToken` should come from UIApplicationDelegate's `application(_:didRegisterForRemoteNotificationsWithDeviceToken:)` method.
    func registerDeviceTokenForNotification(deviceToken: String) {
        unifyID.pushAuth.registerPushToken(deviceToken) { [weak self] (error: PushAuthError?) in
            guard let validError = error else {
                return
            }
            
            log("Failed to register device token for PushAuth, error: \(validError)")
            let wrappingError = UserNotificationObserverError.deviceTokenRegistrationFailed(underlyingError: validError)
            self?.errorHandler?(wrappingError)
        }
    }
    
    /// De-registers all blocks that used as handlers of this instance.
    func deregisterHandlers() {
        pushAuthRequestHandler = nil
        generalNotificationHandler = nil
        errorHandler = nil        
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
                guard let validError = error else {
                    log("Succeeded asking user's response to push auth: \(pushAuthResponse)")
                    return
                }
                log("Failed to send response to PushAuth request, error: \(validError)")
                
                let wrappingError = UserNotificationObserverError.pushAuthResponseFailed(underlyingError: validError)
                self.errorHandler?(wrappingError)
            }
        @unknown default:
            let unknownError = UserNotificationObserverError.pushAuthResponseUnknown
            
            self.errorHandler?(unknownError)
            log(unknownError.localizedDescription)
        }
    }
}
