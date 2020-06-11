//
// Copyright © 2020 UnifyID, Inc. All rights reserved.
// Unauthorized copying or excerpting via any medium is strictly prohibited.
// Proprietary and confidential.
//

import UIKit

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
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }    
    
    @IBAction private func applyNewConfiguration(_ sender: Any) {
        guard let sdkKey = sdkKeyTextField?.text,
            let user = userTextField?.text else {
                return
        }
        
        UnifyConfigurationStore.setConfig(key: .sdkKey, value: sdkKey)
        UnifyConfigurationStore.setConfig(key: .user, value: user)
        
        let presentingViewController = self.presentingViewController
        
        presentingViewController?.dismiss(animated: true, completion: { [weak presentingViewController] in
            
            if let homeViewController = presentingViewController as? HomeViewController {
                homeViewController.setupUserNotificationObserver()
            }            
        })
    }
}
