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
    
    // MARK: - IBActions
        
    @IBAction private func dismissPage(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }    
    
    @IBAction private func applyNewCredentials(_ sender: Any) {
        guard let sdkKey = sdkKeyTextField?.text,
            let user = userTextField?.text else {
                return
        }
        
        // TODO: SDK-2261 Utilize the SDK Key and user values to integrate the PushAuth SDK.
        
        print("Input for SDK Key: \(sdkKey), user: \(user)")
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
