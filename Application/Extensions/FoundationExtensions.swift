//
//  FoundationExtensions.swift
//  OBAKit
//
//  Created by Aaron Brethorst on 1/22/19.
//  Copyright © 2019 OneBusAway. All rights reserved.
//

import Foundation

public extension Bundle {

    private func string(for key: String) -> String {
        object(forInfoDictionaryKey: key) as! String //swiftlint:disable:this force_cast
    }

    var appName: String {
        string(for: "CFBundleDisplayName")
    }

    var copyright: String {
        string(for: "NSHumanReadableCopyright")
    }

    /// A helper method for accessing the app's version number. e.g. `"19.1.0"`
    var appVersion: String {
        return object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String //swiftlint:disable:this force_cast
    }

    /// A helper method for easily accessing the bundle's `CFBundleIdentifier`.
    var bundleIdentifier: String {
        return object(forInfoDictionaryKey: "CFBundleIdentifier") as! String //swiftlint:disable:this force_cast
    }

    /// A helper method for easily accessing the bundle's `NSUserActivityTypes`.
    var userActivityTypes: [String]? {
        return object(forInfoDictionaryKey: "NSUserActivityTypes") as? [String]
    }

    /// A helper method for accessing the bundle's `DeepLinkServerBaseAddress`
    var deepLinkServerBaseAddress: URL? {
        guard let address = object(forInfoDictionaryKey: "DeepLinkServerBaseAddress") as? String else { return nil }
        return URL(string: address)
    }

    /// A helper method for accessing the bundle's privacy policy URL
    var privacyPolicyURL: URL? {
        guard let address = object(forInfoDictionaryKey: "PrivacyPolicyURL") as? String else { return nil }
        return URL(string: address)
    }

    var appDevelopersEmailAddress: String? {
        return object(forInfoDictionaryKey: "AppDevelopersEmailAddress") as? String
    }
}

public extension Sequence where Element == String {

    /// Performs a localized case insensitive sort on the receiver.
    ///
    /// - Returns: A localized, case-insensitive sorted Array.
    func localizedCaseInsensitiveSort() -> [Element] {
        return sorted { (s1, s2) -> Bool in
            return s1.localizedCaseInsensitiveCompare(s2) == .orderedAscending
        }
    }
}

// From https://stackoverflow.com/a/55619708/136839
public extension String {

    /// true if the string consists of the characters 0-9 exclusively, and false otherwise.
    var isNumeric: Bool {
        guard self.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self).isSubset(of: nums)
    }
}

public extension UserDefaults {

    enum UserDefaultsError: Error {
        case typeMismatch
    }

    /// Returns a typed object for `key`, if it exists.
    ///
    /// - Parameters:
    ///   - type: The type of the object to return.
    ///   - key: The key for the object.
    /// - Returns: The object, if it exists in the user defaults. Otherwise `nil`.
    /// - Throws: `UserDefaultsError.typeMismatch` if you passed in the wrong type `T`.
    func object<T>(type: T.Type, forKey key: String) throws -> T? {
        guard let obj = object(forKey: key) else {
            return nil
        }

        if let typedObj = obj as? T {
            return typedObj
        }
        else {
            throw UserDefaultsError.typeMismatch
        }
    }

    /// A simple way to check if this object contains a value for `key`.
    ///
    /// - Parameter key: The key to check if a value exists for.
    /// - Returns: `true` if the value exists, and `false` if it does not.
    func contains(key: String) -> Bool {
        return object(forKey: key) != nil
    }
}
