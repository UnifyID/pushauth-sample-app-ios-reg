//
// Copyright © 2020 UnifyID, Inc. All rights reserved.
// Unauthorized copying or excerpting via any medium is strictly prohibited.
// Proprietary and confidential.
//

import Foundation

/// Static storage for UnifyID-related configuration.
/// - note: This class uses a simple storage for implementation, you might want to have a more secure one in your app.
class UnifyConfigurationStore {
    
    // MARK: - Custom enum
    
    enum Key {
        case sdkKey, user, deviceToken, pairingCode
    }
    
    // MARK: - Private properties
    
    private static var storage = UserDefaults.standard
    
    // MARK: - Public methods
    
    /// Returns stored configuration based on the passed `key`.
    /// Will return `nil` if none is available.
    static func getConfig(key: Key) -> String? {
        let keyString = getKeyString(key: key)
        return storage.value(forKey: keyString) as? String
    }
    
    /// Sets the passed `value` for the corresponding configuration `key`.
    static func setConfig(key: Key, value: String) {
        let keyString = getKeyString(key: key)
        storage.set(value, forKey: keyString)
    }
    
    // MARK: - Private methods
    
    private static func getKeyString(key: Key) -> String {
        switch key {
        case .sdkKey: return "sdk_key"
        case .user: return "user"
        case .deviceToken: return "deviceToken"
        case .pairingCode: return "pairingCode"
        }
    }
    
    /// Private constructor to prevent object creation.
    private init() {}
    
}
