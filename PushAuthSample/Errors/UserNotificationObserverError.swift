//
// Copyright © 2020 UnifyID, Inc. All rights reserved.
// Unauthorized copying or excerpting via any medium is strictly prohibited.
// Proprietary and confidential.
//


import Foundation
import PushAuth

/// Holds error that might received by the UserNotificationObserver.
enum UserNotificationObserverError: Error {
    
    // MARK: - Enum cases
    
    /// Device token registration for push notification fails.
    case deviceTokenRegistrationFailed(underlyingError: Error)
    /// Failed to retrieve user's response for a PushAuthRequest.
    case pushAuthResponseFailed(underlyingError: Error)
    /// Unknown response after asking for PushAuthRequest to the user.
    case pushAuthResponseUnknown
    
    // MARK: - Description
    
    var localizedDescription: String {
        switch self {
        case .deviceTokenRegistrationFailed(let underlyingError):
            guard let pushAuthError = underlyingError as? PushAuthError else {
                return "Failed to register device token: \(underlyingError.localizedDescription)"
            }
            return pushAuthError.localizedDescription
            
        case .pushAuthResponseFailed(let underlyingError):
            guard let pushAuthError = underlyingError as? PushAuthError else {
                return "Failed to retrieve response for PushAuth request from user: \(underlyingError.localizedDescription)"
            }
            return pushAuthError.localizedDescription
            
        case .pushAuthResponseUnknown:
            return "Unknown response found for the PushAuth request."
        }
    }    
}
