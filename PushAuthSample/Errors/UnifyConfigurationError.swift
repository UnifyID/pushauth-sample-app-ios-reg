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
    /// The passed challenge token is empty.
    case emptyPairingCode
    /// The  user and SDK key  for UnifyID object creation are empty.
    case emptyUserAndSDKKey
    /// The user and pairing code for UnifyID object creation are empty.
    case emptyUserAndPairingCode
    /// The SDK key and pairing code for UnifyID object creation are empty.
    case emptySDKKeyAndPairingCode
    /// All of the user, SDK key, and pairing code] for UnifyID object creation are empty.
    case allConfigurationsEmpty
    /// No valid device token for push notification found.
    case invalidDeviceToken
    
    // MARK: - Descriptions
    
    var localizedDescription: String {
        switch self {
        case .emptyUser:
            return "User must be provided."
        case .emptySDKKey:
            return "SDK key must be provided."
        case .emptyPairingCode:
            return "Pairing code must be provided."
        case .emptyUserAndSDKKey:
            return "SDK key and user must be provided."
        case .emptyUserAndPairingCode:
            return "User and pairing code must be provided."
        case .emptySDKKeyAndPairingCode:
            return "SDK key and pairing code must be provided."
        case .allConfigurationsEmpty:
            return "User, SDK key, and pairing code must be provided."
        case .invalidDeviceToken:
            return "No valid device token found for Push Notification."
        }
    }
}
