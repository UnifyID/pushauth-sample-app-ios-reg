//
// Copyright © 2020 UnifyID, Inc. All rights reserved.
// Unauthorized copying or excerpting via any medium is strictly prohibited.
// Proprietary and confidential.
//

import UIKit

/// A LaunchScreen-like View Controller that decides which screen should go next based on the stored configuration.
class InitialRoutingViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigateToNextScreen()
    }
    
    private func navigateToNextScreen() {
        let shouldNavigateToConfig = UnifyConfigurationStore.getConfig(key: .sdkKey) == nil ||
            UnifyConfigurationStore.getConfig(key: .user) == nil
        
        let shouldNavigateToPushNotif = UnifyConfigurationStore.getConfig(key: .deviceToken) == nil
    
        if (shouldNavigateToConfig) {
            navigateToViewController(withIdentifier: "OnboardingConfigViewController")
        } else if (shouldNavigateToPushNotif) {
            navigateToViewController(withIdentifier: "OnboardingPushNotifViewController")
        } else {
            navigateToHomeViewController()
        }
    }
    
    private func navigateToHomeViewController() {
        // At this point, we need to re-retrieve the device token, just in case Apple gives us new device token.
        // We don't need to re-do the the PushNotif request.        
        let selector = #selector(navigateToHome(notification:))
        let notificationName = AppDelegate.didReceiveDeviceToken
        
        NotificationCenter.default.addObserver(self, selector: selector, name: notificationName, object: nil)
        
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    @objc func navigateToHome(notification: Notification) {
        navigateToViewController(withIdentifier: "HomeViewController")
    }
    
    private func navigateToViewController(withIdentifier identifier: String) {
        dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
        
        let bundle = Bundle(for: type(of: self))
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
               
        let viewController = storyboard.instantiateViewController(withIdentifier: identifier)
        let navController = UINavigationController(rootViewController: viewController)
            
        navigateTo(viewController: navController)
    }
    
    private func navigateTo(viewController: UIViewController) {
        guard let keyWindow = UIApplication.shared.keyWindow else {
            return
        }
        
        keyWindow.rootViewController = viewController
        
        UIView.transition(
            with: keyWindow,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: {}
        )
    }
}
