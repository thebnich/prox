/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import FirebaseRemoteConfig

public enum AppBuildChannel {
    case Debug
    case CurrentLocation
    case MockLocation
    case Release
}

public struct AppConstants {

    public static let isRunningTest = NSClassFromString("XCTestCase") != nil
    
    #if MOZ_CHANNEL_DEBUG
    public static let backgroundFetchInterval: TimeInterval = 1 * 60
    public static let minimumIntervalAtLocationBeforeFetchingEvents: TimeInterval = 1 * 60
    #else
    public static var backgroundFetchInterval: TimeInterval {
        return RemoteConfigKeys.backgroundFetchIntervalMins.value * 60.0
    }
    public static var minimumIntervalAtLocationBeforeFetchingEvents: TimeInterval {
        return RemoteConfigKeys.notificationVisitIntervalMins.value * 60.0
    }
    #endif

    public static var cacheEvents: Bool {
        return RemoteConfigKeys.cacheEvents.value == 1
    }

    public static let timeOfLastLocationUpdateKey = "timeOfLastLocationUpdate"
    public static let ONE_DAY: TimeInterval = (60 * 60) * 24

    /// Build Channel.
    public static let BuildChannel: AppBuildChannel = {
        #if MOZ_CHANNEL_CURRENT_LOCATION
            return AppBuildChannel.CurrentLocation
        #elseif MOZ_CHANNEL_RELEASE
            return AppBuildChannel.Release
        #elseif MOZ_CHANNEL_MOCK_LOCATION
            return AppBuildChannel.MockLocation
        #else
            return AppBuildChannel.Debug
        #endif
    }()

    /// Flag indiciating if we are running in Debug mode or not.
    public static let isDebug: Bool = {
        return BuildChannel == .Debug
    }()

    /// Flag indiciating if we are running in Enterprise mode or not.
    public static let isEnterprise: Bool = {
        return BuildChannel == .CurrentLocation
    }()

    public static let isSimulator: Bool = {
        #if (arch(i386) || arch(x86_64))
            return true
        #else
            return false
        #endif
    }()

    // Enables/disables location faking for Hawaii
    public static let MOZ_LOCATION_FAKING: Bool = {
        return BuildChannel == .MockLocation
    }()

    public static let APIKEYS_PATH = "APIKeys"

    // The root child in the Realtime Firebase database.
    public static let firebaseRoot: String = {
        switch (BuildChannel) {
        case .CurrentLocation, .MockLocation, .Release:
            return "production/"

        case .Debug:
            let configPath = Bundle.main.path(forResource: "LocalConfig", ofType: "plist")!
            let plist = NSDictionary(contentsOfFile: configPath) as! [String: Any]
            return "\(plist["DebugRoot"]!)/"
        }
    }()

    public static let areNotificationsEnabled: Bool = {
        return BuildChannel == .Debug
    }()
}
