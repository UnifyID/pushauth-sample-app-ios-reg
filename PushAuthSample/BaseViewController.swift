//
// Copyright © 2020 UnifyID, Inc. All rights reserved.
// Unauthorized copying or excerpting via any medium is strictly prohibited.
// Proprietary and confidential.
//

import UIKit

// This class provides the base setup and functionality of the
// navigaton bar across the app.
class BaseViewController: UIViewController {

    // MARK: - Public methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBarTitle()
        setupNavigationBarConfigButton()
    }
    
    /// Stub method that gets called when the `ConfigViewController` gets dismissed because of a successful update.
    /// - note: The subclass of this class could override this method to do custom actions
    /// after the new configuration has been saved.
    func configScreenUpdateSucceeded() {
        log("The config screen just dismissed after a successful update!")
    }
    
    // MARK: - Private methods
    
    private func setupNavigationBarTitle() {
        let logo = UIImage(named: "unifyid-logo")
        let imageView = UIImageView(image: logo)
        
        navigationItem.titleView = imageView
    }
    
    private func setupNavigationBarConfigButton() {
        let gearImage = UIImage(named: "gear-blue")
        let barButton = UIBarButtonItem(image: gearImage, style: .plain, target: self, action: #selector(showConfigPage))        
            
        navigationItem.rightBarButtonItem = barButton
    }
    
    @objc private func showConfigPage() {
        let bundle = Bundle(for: type(of: self))
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        
        let viewController = storyboard.instantiateViewController(withIdentifier: "ConfigScreen")
        
        present(viewController, animated: true)
    }
}
