//
// Copyright © 2020 UnifyID, Inc. All rights reserved.
// Unauthorized copying or excerpting via any medium is strictly prohibited.
// Proprietary and confidential.
//

import Foundation

enum UnifyConfigurationError: Error {
    
    // MARK: - Enum cases
    
    /// The passed user is empty.
    case emptyUser
    /// The passed SDK key is empty.
    case emptySDKKey
    /// Either the SDK key or user for UnifyID object creation are empty.
    case emptyUserAndSDKKey    
    /// No valid device token for push notification found.
    case invalidDeviceToken
    
    // MARK: - Descriptions
    
    var localizedDescription: String {
        switch self {
        case .emptyUser:
            return "User must be provided."
        case .emptySDKKey:
            return "SDK key must be provided."
        case .emptyUserAndSDKKey:
            return "SDK key and user must be provided."
        case .invalidDeviceToken:
            return "No valid device token found for Push Notification."
        }
    }
}
