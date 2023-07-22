//
//  EngineeringModeMainView.swift
//
//  Created by Ananay Arora on 6/29/23.
//

import SwiftUI

struct EngineeringModeMainView: View {
    let bundle = Bundle.main
    

    var body: some View {
        List {
            Section(header: Text("App Information")) {
                KeyValueRow(key: "Name", value: bundle.displayName ?? "")
                KeyValueRow(key: "Version", value: bundle.version ?? "")
                KeyValueRow(key: "Build Number", value: bundle.buildNumber ?? "")
                KeyValueRow(key: "Bundle Identifier", value: bundle.bundleIdentifier ?? "")
                KeyValueRow(key: "Minimum OS Version", value: bundle.minimumOSVersion ?? "")
                KeyValueRow(key: "Device Family", value: bundle.deviceFamilyDescription ?? "")
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

struct KeyValueRow: View {
    let key: String
    let value: String

    var body: some View {
        HStack {
            Text(key)
                .fontWeight(.bold)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

extension Bundle {
    var displayName: String? {
        return infoDictionary?["CFBundleDisplayName"] as? String
    }

    var version: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }

    var buildNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }

    var minimumOSVersion: String? {
        return infoDictionary?["MinimumOSVersion"] as? String
    }

    var deviceFamilyDescription: String? {
        guard let deviceFamily = infoDictionary?["UIDeviceFamily"] as? [Int] else {
            return nil
        }

        var description = ""
        for family in deviceFamily {
            switch family {
            case 1: description += "iPhone, "
            case 2: description += "iPad, "
            case 3: description += "iPod touch, "
            case 4: description += "Apple TV, "
            case 5: description += "Apple Watch, "
            case 6: description += "CarPlay, "
            case 7: description += "Mac, "
            default: break
            }
        }

        if !description.isEmpty {
            description.removeLast(2) // Remove the trailing comma and space
        }

        return description
    }
}


@available(iOS 15, *)
struct EngineeringModeMainView_Previews: PreviewProvider {
    @available(iOS 15.0, *)
    static var previews: some View {
        EngineeringModeMainView()
    }
}
