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
                let error = HomeViewControllerError.incompleteConfiguration
                presentError(error)
                return
        }
        
        let unifyID: UnifyID
        
        do {
            unifyID = try UnifyID(sdkKey: sdkKey, user: user, challenge: "")
        } catch {
            let wrappingError = HomeViewControllerError.unifyIDCreationFailed(underlyingError: error)
            presentError(wrappingError)
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
            let error = HomeViewControllerError.invalidDeviceTokenFormat
            presentError(error)
            
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
                self?.presentGeneralNotification(notification)
            }
        }
        
        observer.errorHandler = { [weak self] error in
            DispatchQueue.main.async {
                self?.presentError(error)
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
            let wrappingError = HomeViewControllerError.pushAuthAlertFailed(underlyingError: error)
            presentError(wrappingError)
            
        case .success(let response):
            log("Successfully handled push auth as alert, user's response: \(response)")
        }
    }
    
    private func presentGeneralNotification(_ notification: UNNotification) {
        dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
        
        let requestBody = notification.request.content.body
        
        let alert = UIAlertController(title: "General Notification", message: requestBody, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func presentError(_ error: Error) {
        
        let errorMessage = getErrorMessage(error: error)
        
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func getErrorMessage(error: Error) -> String {
        
        if let observerError = error as? UserNotificationObserverError {
            return observerError.localizedDescription
        } else if let homeError = error as? HomeViewControllerError {
            return homeError.localizedDescription
        } else {
            return error.localizedDescription
        }
    }
}
