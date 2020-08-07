//
// Copyright © 2020 UnifyID, Inc. All rights reserved.
// Unauthorized copying or excerpting via any medium is strictly prohibited.
// Proprietary and confidential.
//

import Foundation

/// Holds error related to authorization of app's Push Notification capability.
/// - note: The `localizedDescription` values of these enums are user-readable String.
/// When avialable, please unwrap the `underlyingError` for each enum case to get the details for debugging.
enum NotificationAuthError: Error {
    // MARK: - Enum cases
    /// User denies authorization for the app to receive push notification.
    case denied
    /// Authorization process for push notification failed for anything else than user's response.
    case failed(underlyingError: Error)
    /// Unknown push notification settings after asking for user's authorization.
    case unknownSettings
    
    // MARK: - Description    
    var localizedDescription: String {
        switch self {
        case .denied:
            return "Push notification authorization denied. Please go to Settings > PushAuth Sample > Notifications and allow the app to receive notifications."
        case .unknownSettings:
            return "Unknown settings found for Push Notification."
        case .failed(_):
            return "Failed to authorize for receiving push notification. Please kill the app to try again."
        }
    }
}
