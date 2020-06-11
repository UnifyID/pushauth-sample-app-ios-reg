//
// Copyright © 2020 UnifyID, Inc. All rights reserved.
// Unauthorized copying or excerpting via any medium is strictly prohibited.
// Proprietary and confidential.
//


import Foundation
import UnifyID
import PushAuth

/// Error that might happen in HomeViewController.
enum HomeViewControllerError: Error {
    
    // MARK: - Enum cases
    
    /// One of the configuration required to create the UnifyID object is unavailable.
    case incompleteConfiguration
    
    /// Failed to create UnifyID object.
    case unifyIDCreationFailed(underlyingError: Error)
    
    /// Received device token for push notification has invalid format.
    case invalidDeviceTokenFormat
    
    /// Failed to present PushAuthRequest as an alert.
    case pushAuthAlertFailed(underlyingError: Error)
    
    // MARK: - Description
    
    var localizedDescription: String {
        
        switch self {
        case .incompleteConfiguration:
            return "No valid SDK Key and/or user set for UnifyID configuration."
            
        case .unifyIDCreationFailed(let underlyingError):
            
            guard let unifyIDError = underlyingError as? UnifyIDError else {
                return "Failed to create UnifyID: \(underlyingError.localizedDescription)"
            }
            
            return unifyIDError.localizedDescription
            
        case .invalidDeviceTokenFormat:
            return "Device token has invalid format."
            
        case .pushAuthAlertFailed(let underlyingError):
            
            guard let pushAuthError = underlyingError as? PushAuthError else {
                return "Error when presenting PushAuth request as alert: \(underlyingError.localizedDescription)"
            }
            
            return pushAuthError.localizedDescription
        }
    }
    
    
}
