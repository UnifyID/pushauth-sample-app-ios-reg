//
// Copyright © 2020 UnifyID, Inc. All rights reserved.
// Unauthorized copying or excerpting via any medium is strictly prohibited.
// Proprietary and confidential.
//

import UIKit

/// This class is responsible for requesting the user to enable the Push Notification for the app.
class OnboardingPushNotifViewController: BaseViewController {

    // MARK: - Private properties
    
    private let userNotificationCenter = UNUserNotificationCenter.current()
    
    // MARK: - UIViewController methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDeviceTokenObserver()
        setupAppForegroundTransitionObserver()
    }
    
    // MARK: - IBActions
    
    @IBAction private func requestPushNotifAuthorization(_ sender: Any) {
        userNotificationCenter.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.setupUserNotification(basedOn: settings)
            }
        }
    }
    
    // MARK: - Private methods
    
    private func setupDeviceTokenObserver() {
        let registerTokenSelector = #selector(navigateToHomeScreen)
        let notificationName = AppDelegate.didReceiveDeviceToken
        
        NotificationCenter.default.addObserver(self, selector: registerTokenSelector, name: notificationName, object: nil)
    }
    
    @objc private func navigateToHomeScreen() {
        let bundle = Bundle(for: type(of: self))
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        
        let viewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController")
        
        let currentlyPresentingAlert = self.presentedViewController != nil
        guard currentlyPresentingAlert else {
            navigationController?.setViewControllers([ viewController ], animated: true)
            return
        }

        // Dismiss the alert first, then go to the next page.
        dismiss(animated: true) { [weak self] in
            self?.navigationController?.setViewControllers([ viewController ], animated: true)
        }
    }
    
    private func setupAppForegroundTransitionObserver() {
        let selector = #selector(checkIfPushNotifAllowedThroughSettings)
        let notificationName = UIApplication.didBecomeActiveNotification
        
        NotificationCenter.default.addObserver(self, selector: selector, name: notificationName, object: nil)
    }
    
    @objc private func checkIfPushNotifAllowedThroughSettings() {
        userNotificationCenter.getNotificationSettings { settings in
            guard settings.alertSetting == .enabled else {
                return
            }
            
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    private func setupUserNotification(basedOn settings: UNNotificationSettings) {
        
        switch (settings.alertSetting) {
        case .enabled:
            UIApplication.shared.registerForRemoteNotifications()
            
        case .disabled, .notSupported:
            userNotificationCenter
                .requestAuthorization(options: [.sound, .alert]) { [weak self] (authorized, error) in 
                    guard let self = self else {
                        return
                    }
                    
                    if let validError = error {
                        log("Failed to authorize for receiving push notificaiton, error: \(validError)")
                        let wrappingError = NotificationAuthError.failed(underlyingError: validError)
                        self.handleError(wrappingError)
                    } else if !authorized {
                        let unauthorizedError = NotificationAuthError.denied
                        self.handleError(unauthorizedError)
                    } else {
                        self.requestPushNotifAuthorization(self) // check if it's enabled now.
                    }
            }
            
        @unknown default:
            let unknownError = NotificationAuthError.unknownSettings
            
            handleError(unknownError)
        }
    }
    
    private func handleError(_ error: Error) {
        log(error.localizedDescription)        
        DispatchQueue.main.async { [weak self] in
            self?.presentAlert(for: error)
        }
    }
}
