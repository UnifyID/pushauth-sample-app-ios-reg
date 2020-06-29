//
// Copyright © 2020 UnifyID, Inc. All rights reserved.
// Unauthorized copying or excerpting via any medium is strictly prohibited.
// Proprietary and confidential.
//

import UIKit

/// This class is responsible for onboarding user how to use the Config screen.
class OnboardingConfigViewController: BaseViewController {

    override func configScreenUpdateSucceeded() {
        super.configScreenUpdateSucceeded()
        
        let bundle = Bundle(for: type(of: self))
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        
        let viewController = storyboard.instantiateViewController(withIdentifier: "OnboardingPushNotifViewController")
        
        navigationController?.setViewControllers([ viewController ], animated: true)                
    }
}
