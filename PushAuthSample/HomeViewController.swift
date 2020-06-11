//
// Copyright © 2020 UnifyID, Inc. All rights reserved.
// Unauthorized copying or excerpting via any medium is strictly prohibited.
// Proprietary and confidential.
//

import UIKit
import UnifyID
import PushAuth

/// View controller instance where user will receive their PushAuth notification.
class HomeViewController: UIViewController {
        
    // MARK: - Private properties
    
    /// Observer for incoming user notification, including PushAuthRequest notifications.
    var userNotificationObserver: UserNotificationObserver?
    
    // MARK: - Public methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDeviceTokenObserver()
    }
    
    /// Sets up notification observer for this instance.
    /// - note: This method will utilize the configuration stored in `UnifyConfigurationStore`.
    /// Please make sure it has the correct value beforehand, e.g. by assigning it from ConfigViewController.
    func setupUserNotificationObserver() {
        
        guard let sdkKey = UnifyConfigurationStore.getConfig(key: .sdkKey),
            let user = UnifyConfigurationStore.getConfig(key: .user) else {
                // TODO: SDK-2282 present this error with proper UI.
                print("No valid SDK Key and/or user set for UnifyID configuration.")
                return
        }
        
        let unifyID: UnifyID
        
        do {
            unifyID = try UnifyID(sdkKey: sdkKey, user: user, challenge: "")
        } catch {
            // TODO: SDK-2282 present this error with proper UI.
            print("Failed to create UnifyID, error: \(error)")
            return
        }
        
        userNotificationObserver = createUserNotificationObserver(unifyID: unifyID)
        userNotificationObserver?.requestUserNotificationPermission()
    }
    
    // MARK: - Device token-related methods
    
    private func setupDeviceTokenObserver() {
        let registerTokenSelector = #selector(registerDeviceToken(notification:))
        let notificationName = AppDelegate.didReceiveDeviceToken
        
        NotificationCenter.default.addObserver(self, selector: registerTokenSelector, name: notificationName, object: nil)
    }
    
    @objc private func registerDeviceToken(notification: Notification) {
        
        guard let deviceToken = notification.object as? String else {
            // TODO: SDK-2282 present this error with proper UI.
            print("Token format error: \(notification.object.debugDescription)")
            return
        }
        
        userNotificationObserver?.registerDeviceTokenForNotification(deviceToken: deviceToken)
    }
    
    // MARK: - User notification-related methods
    
    private func createUserNotificationObserver(unifyID: UnifyID) -> UserNotificationObserver {
    
        let observer = UserNotificationObserver(unifyID: unifyID)
        
        observer.pushAuthRequestHandler = { [weak self] request in
            DispatchQueue.main.async {
                self?.presentPushAuthRequest(request)
            }
        }
        
        observer.generalNotificationHandler = { [weak self] notification in
            DispatchQueue.main.async {
                self?.presentGeneralNotification(notification: notification)
            }
        }
                
        return observer
    }
    
    // MARK: - Notification-presenting methods
        
    private func presentPushAuthRequest(_ request: PushAuthRequest) {
        dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
        
        request.presentAsAlert(self) { [weak self] result in
            DispatchQueue.main.async {
                self?.handlePushAuthResult(result)
            }
        }
    }
    
    private func handlePushAuthResult(_ result: Result<UserResponse, PushAuthError>) {
        dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
        
        switch result {
            
        case .failure(let error):
            // TODO: SDK-2282 present this error with proper UI.
            print("Error when presenting push auth as alert: \(error)")
            
        case .success(let response):
            // TODO: SDK-2282 subject to discussion, but it's better to show a proper UI for this.
            print("Successfully handled push auth as alert, user's response: \(response)")
        }
    }
    
    private func presentGeneralNotification(notification: UNNotification) {
        dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
        
        let requestBody = notification.request.content.body
        
        let alert = UIAlertController(title: "General Notification", message: requestBody, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
