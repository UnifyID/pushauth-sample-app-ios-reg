//
// Copyright © 2020 UnifyID, Inc. All rights reserved.
// Unauthorized copying or excerpting via any medium is strictly prohibited.
// Proprietary and confidential.
//

import UIKit
import UnifyID
import PushAuth

extension UIViewController {
    
    /// Presents a basic UIAlertController for the passed `Error` object,
    /// with the `localizedDescription` as the body and OK as button to dismiss.
    func presentAlert(for error: Error) {
        
        let errorMessage = getErrorMessage(for: error)
        
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        present(alert, animated: true)
    }
    
    private func getErrorMessage(for error: Error) -> String {
        switch error {
        case let castedError as UserNotificationObserverError:
            return castedError.localizedDescription
            
        case let castedError as HomeViewControllerError:
            return castedError.localizedDescription
            
        case let castedError as UnifyConfigurationError:
            return castedError.localizedDescription
            
        case let castedError as NotificationAuthError:
            return castedError.localizedDescription
            
        case let castedError as UnifyIDError:
            return castedError.localizedDescription
            
        case let castedError as PushAuthError:
            return castedError.localizedDescription
            
        default:
            return error.localizedDescription
        }
    }
}
