//
// Copyright © 2020 UnifyID, Inc. All rights reserved.
// Unauthorized copying or excerpting via any medium is strictly prohibited.
// Proprietary and confidential.
//

import UIKit
import UnifyID
import PushAuth

/// View controller instance where user will receive their PushAuth notification.
class HomeViewController: BaseViewController {
        
    // MARK: - Private properties
    
    @IBOutlet private weak var userLabel: UILabel!
    
    /// Observer for incoming user notification, including PushAuthRequest notifications.
    private var userNotificationObserver: UserNotificationObserver? {
        didSet {
            oldValue?.deregisterHandlers()
        }
    }
    
    // MARK: - Overridden methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUserLabel()
        setupUserNotificationObserver()
        setupAppForegroundTransitionObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)        
        checkPushNotifAuthorization()
    }
    
    override func configScreenUpdateSucceeded() {
        super.configScreenUpdateSucceeded()
        
        setupUserLabel()
        setupUserNotificationObserver()
    }
    
    // MARK: - Setup methods
    
    private func setupUserLabel() {
        let user = UnifyConfigurationStore.getConfig(key: .user) ?? "N/A"
        userLabel.text = "User: \(user)"
    }
    
    /// Sets up notification observer for this instance.
    /// - note: This method will utilize the configuration stored in `UnifyConfigurationStore`.
    /// Please make sure it has the correct value beforehand, e.g. by assigning it from ConfigViewController.
    private func setupUserNotificationObserver() {
        guard let sdkKey = UnifyConfigurationStore.getConfig(key: .sdkKey),
            let user = UnifyConfigurationStore.getConfig(key: .user) else {
                let error = UnifyConfigurationError.emptyUserAndSDKKey
                presentAlert(for: error)
                return
        }
        
        let unifyID: UnifyID
        
        do {
            unifyID = try UnifyID(sdkKey: sdkKey, user: user, challenge: "")
        } catch {
            let wrappingError = HomeViewControllerError.unifyIDCreationFailed(underlyingError: error)
            presentAlert(for: wrappingError)
            return
        }
        
        guard let deviceToken = UnifyConfigurationStore.getConfig(key: .deviceToken) else {
            let error = UnifyConfigurationError.invalidDeviceToken
            presentAlert(for: error)
            return
        }
        
        userNotificationObserver = createUserNotificationObserver(unifyID: unifyID)
        userNotificationObserver?.registerDeviceTokenForNotification(deviceToken: deviceToken)
    }
    
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
                self?.presentAlert(for: error)
            }
        }
                
        return observer
    }
    
    private func setupAppForegroundTransitionObserver() {
        let selector = #selector(checkPushNotifAuthorization)
        let notificationName = UIApplication.didBecomeActiveNotification
        
        NotificationCenter.default.addObserver(self, selector: selector, name: notificationName, object: nil)
    }
    
    @objc private func checkPushNotifAuthorization() {
        
        userNotificationObserver?.userNotificationCenter
            .getNotificationSettings { [weak self] settings in
                DispatchQueue.main.async {
                    if settings.alertSetting == .enabled {
                        self?.userNotificationObserver?.requestPendingPushAuthRequests()
                    } else {
                        self?.presentAlert(for: NotificationAuthError.denied)
                    }
                }
        }
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
            self.presentAlert(for: wrappingError)
            
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
        
        present(alert, animated: true)
    }    
    
}
