//
// Copyright © 2020 UnifyID, Inc. All rights reserved.
// Unauthorized copying or excerpting via any medium is strictly prohibited.
// Proprietary and confidential.
//

import UIKit
import UnifyID

class ConfigViewController: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet private weak var sdkKeyTextField: UITextField!
    @IBOutlet private weak var userTextField: UITextField!
    
    // MARK: - UIViewController
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sdkKeyTextField.text = UnifyConfigurationStore.getConfig(key: .sdkKey)
        userTextField.text = UnifyConfigurationStore.getConfig(key: .user)
    }
    
    // MARK: - IBActions
        
    @IBAction private func dismissPage(_ sender: Any) {
        presentingViewController?.dismiss(animated: true)
    }    
    
    @IBAction private func applyNewConfiguration(_ sender: Any) {
        let sdkKey = sdkKeyTextField?.text
        let user = userTextField?.text
        let validationResult = validatePushAuthConfig(sdkKey: sdkKey, user: user)
        
        if case .failure(let error) = validationResult {
            presentAlert(for: error)
            return
        }
        
        // At this point, the sdk key and user must be valid - they're not empty.
        UnifyConfigurationStore.setConfig(key: .sdkKey, value: sdkKey!)
        UnifyConfigurationStore.setConfig(key: .user, value: user!)
                
        let presentingVC = presentingViewController
        
        presentingVC?.dismiss(animated: true) { [weak self, weak presentingVC] in
            guard let self = self, let presentingVC = presentingVC else {
                return
            }
            self.triggerUpdateMethod(for: presentingVC)
        }
    }
    
    private func validatePushAuthConfig(sdkKey: String?, user: String?) -> Result<Void,Error> {
        let emptySDKKey = sdkKey == nil || sdkKey == ""
        let emptyUser = user == nil || user == ""
        
        if emptyUser && emptySDKKey {
            return .failure(UnifyConfigurationError.emptyUserAndSDKKey)
        } else if emptyUser {
            return .failure(UnifyConfigurationError.emptyUser)
        } else if emptySDKKey {
            return .failure(UnifyConfigurationError.emptySDKKey)
        }
        
        guard let nonEmptyKey = sdkKey, let nonEmptyUser = user else {
            return .failure(UnifyConfigurationError.emptyUserAndSDKKey)
        }
        
        do {
            let _ = try UnifyID(sdkKey: nonEmptyKey, user: nonEmptyUser, challenge: "")
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    private func triggerUpdateMethod(for presentingViewController: UIViewController) {
        if let baseViewController = presentingViewController as? BaseViewController {
            baseViewController.configScreenUpdateSucceeded()
            return
        }
        
        if let navController = presentingViewController as? UINavigationController,
            let baseViewController = navController.viewControllers.last as? BaseViewController {
            baseViewController.configScreenUpdateSucceeded()
            return
        }
    }
}
