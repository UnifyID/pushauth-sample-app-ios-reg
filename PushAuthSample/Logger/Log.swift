//
// Copyright © 2020 UnifyID, Inc. All rights reserved.
// Unauthorized copying or excerpting via any medium is strictly prohibited.
// Proprietary and confidential.
//

import Foundation

/// Logs the passed text.
func log(_ text: String) {
    #if DEBUG
    NSLog(text)
    #endif
}
