//
// Copyright © 2020 UnifyID, Inc. All rights reserved.
// Unauthorized copying or excerpting via any medium is strictly prohibited.
// Proprietary and confidential.
//


import Foundation
import UnifyID
import PushAuth

/// Error that might happen in HomeViewController.
/// - note: The `localizedDescription` values of these enums are user-readable String.
/// Please unwrap the `underlyingError` for each enum case to get the details for debugging.
enum HomeViewControllerError: Error {
    // MARK: - Enum cases
        
    /// Failed to create UnifyID object.
    case unifyIDCreationFailed(underlyingError: Error)
    /// Failed to respond to a PushAuthRequest.
    case pushAuthRespondFailed(underlyingError: Error)
    
    // MARK: - Description
    
    var localizedDescription: String {
        switch self {
        case .unifyIDCreationFailed(_):
            return "Failed to create UnifyID."
        case .pushAuthRespondFailed(_):
            return "Unable to respond to the PushAuth request."
        }
    }        
}
