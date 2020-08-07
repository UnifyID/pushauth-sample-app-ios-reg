//
// Copyright © 2020 UnifyID, Inc. All rights reserved.
// Unauthorized copying or excerpting via any medium is strictly prohibited.
// Proprietary and confidential.
//


import Foundation
import PushAuth

/// Holds error that might received by the UserNotificationObserver.
/// - note: The `localizedDescription` values of these enums are user-readable String.
/// Please unwrap the `underlyingError` for each enum case to get the details for debugging.
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
        case .deviceTokenRegistrationFailed(_):
            return "Failed to register device token, please restart the app to try again."
        case .pushAuthResponseFailed(_):
            return "Unable to respond to the PushAuth request."
        case .pushAuthResponseUnknown:
            return "Unknown response found for the PushAuth request."
        }
    }    
}
