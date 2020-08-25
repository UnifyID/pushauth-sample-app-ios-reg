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
    @IBOutlet private weak var pairingCodeTextField: UITextField!
    
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
        let pairingCode = pairingCodeTextField?.text
        let validationResult = validatePushAuthConfig(sdkKey: sdkKey, user: user, pairingCode: pairingCode)
        
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
    
    private func validatePushAuthConfig(sdkKey: String?, user: String?, pairingCode: String?) -> Result<Void,Error> {
        let emptyUser = user == nil || user == ""
        let emptySDKKey = sdkKey == nil || sdkKey == ""
        let emptyPairingCode = pairingCode == nil || pairingCode == ""
        
        switch (emptyUser, emptySDKKey, emptyPairingCode) {
        case (true, true, true):
            return .failure(UnifyConfigurationError.allConfigurationsEmpty)
        case (true, true, false):
            return .failure(UnifyConfigurationError.emptyUserAndSDKKey)
        case (true, false, true):
            return .failure(UnifyConfigurationError.emptyUserAndPairingCode)
        case (false, true, true):
            return .failure(UnifyConfigurationError.emptySDKKeyAndPairingCode)
        case (true, false, false):
            return .failure(UnifyConfigurationError.emptyUser)
        case (false, true, false):
            return .failure(UnifyConfigurationError.emptySDKKey)
        case (false, false, true):
            return .failure(UnifyConfigurationError.emptyPairingCode)
        case (false, false, false):
            break            
        }
        
        guard let nonEmptyKey = sdkKey,
            let nonEmptyUser = user,
            let nonEmptyPairingCode = pairingCode else {
            return .failure(UnifyConfigurationError.allConfigurationsEmpty)
        }
        
        do {
            let _ = try UnifyID(sdkKey: nonEmptyKey, user: nonEmptyUser, challenge: nonEmptyPairingCode)
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
