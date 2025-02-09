//
//  PermissionsView.swift
//
//  Created by Ananay Arora on 6/29/23.
//

import AVFoundation
import AuthenticationServices
import Contacts
import CoreBluetooth
import CoreLocation
import CoreMotion
import CoreTelephony
import EventKit
import HealthKit
import HomeKit
import Intents
import MediaPlayer
import Photos
import Speech
import SwiftUI
import UserNotifications

enum PermissionStatusInfo: String {
    case granted = "Granted"
    case denied = "Denied"
    case restricted = "Restricted"
    case notDetermined = "Not Determined"
    case limited = "Limited"
    case determined = "Determined"
    case provisional = "Provisional"
    case ephemeral = "Ephemeral"
    case unavailable = "Unavailable"
    case unavailableOldOS = "Unavailable on iOS < 16.0"
    case notApplicable = "N/A"
    case unknown = "Unknown"

    var color: Color {
        switch self {
        case .granted:
            return .green
        case .limited, .determined, .provisional:
            return .yellow
        case .notApplicable, .unavailable, .unavailableOldOS:
            return .primary
        default:
            return .red
        }
    }

    static func fromRawStatus(_ status: String) -> PermissionStatusInfo {
        switch status {
        case "authorized", "allowedAlways", "sharingAuthorized",
            "notRestricted", "authorizedAlways",
            "authorizedWhenInUse":
            return .granted
        case "denied", "sharingDenied":
            return .denied
        case "restricted":
            return .restricted
        case "notDetermined":
            return .notDetermined
        case "limited":
            return .limited
        case "determined":
            return .determined
        case "provisional":
            return .provisional
        case "ephemeral":
            return .ephemeral
        default:
            return .unknown
        }
    }
}

protocol AuthorizationStatus {
    var localizedStatus: PermissionStatusInfo { get }
}

extension AuthorizationStatus {
    var localizedStatus: PermissionStatusInfo {
        let label = String(describing: self)
        return PermissionStatusInfo.fromRawStatus(label)
    }
}

// Conform all status types to AuthorizationStatus
extension AVAuthorizationStatus: AuthorizationStatus {}
extension PHAuthorizationStatus: AuthorizationStatus {}
extension CNAuthorizationStatus: AuthorizationStatus {}
extension CLAuthorizationStatus: AuthorizationStatus {}
extension EKAuthorizationStatus: AuthorizationStatus {}
extension CMAuthorizationStatus: AuthorizationStatus {}
extension HKAuthorizationStatus: AuthorizationStatus {}
extension CBManagerAuthorization: AuthorizationStatus {}
extension CTCellularDataRestrictedState: AuthorizationStatus {}
extension SFSpeechRecognizerAuthorizationStatus: AuthorizationStatus {}
extension MPMediaLibraryAuthorizationStatus: AuthorizationStatus {}
extension UNAuthorizationStatus: AuthorizationStatus {}

// Special case for HomeKit due to iOS version check
extension HMHomeManagerAuthorizationStatus: AuthorizationStatus {
    var localizedStatus: PermissionStatusInfo {
        if #available(iOS 16.0, *) {
            switch self {
            case .authorized:
                return .granted
            case .restricted:
                return .restricted
            case .determined:
                return .determined
            default:
                return .unknown
            }
        } else {
            return .unavailableOldOS
        }
    }
}

struct PermissionStatus: Identifiable {
    let id = UUID()
    let title: String
    let status: PermissionStatusInfo
}

class HomeKitPermissionManager: NSObject, HMHomeManagerDelegate,
    ObservableObject
{
    @Published var authorizationStatus: HMHomeManagerAuthorizationStatus =
        .determined
    private let homeManager = HMHomeManager()

    override init() {
        super.init()
        homeManager.delegate = self
    }

    func homeManagerDidUpdateAuthorization(_ manager: HMHomeManager) {
        if #available(iOS 16.0, *) {
            authorizationStatus = manager.authorizationStatus
        }
    }
}

class NotificationPermissionManager: ObservableObject {
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined

    init() {
        Task {
            await updateAuthorizationStatus()
        }
    }

    func requestAuthorization() async {
        let center = UNUserNotificationCenter.current()
        do {
            try await center.requestAuthorization(options: [
                .alert, .sound, .badge, .provisional,
            ])
            // Update status after requesting authorization
            await updateAuthorizationStatus()
        } catch {
            print("Error requesting notification authorization: \(error)")
        }
    }

    func updateAuthorizationStatus() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        await MainActor.run {
            self.authorizationStatus = settings.authorizationStatus
        }
    }

    // Helper computed property to get a user-friendly status string
    var localizedAuthorizationStatus: PermissionStatusInfo {
        switch authorizationStatus {
        case .authorized:
            return .granted
        case .denied:
            return .denied
        case .notDetermined:
            return .notDetermined
        case .provisional:
            return .provisional
        case .ephemeral:
            return .ephemeral
        @unknown default:
            return .unknown
        }
    }
}

struct PermissionsView: View {
    @StateObject private var homeKitManager = HomeKitPermissionManager()
    @StateObject private var notificationManager =
        NotificationPermissionManager()

    var permissions: [PermissionStatus] {
        [
            PermissionStatus(
                title: "Camera",
                status: AVCaptureDevice.authorizationStatus(for: .video)
                    .localizedStatus),
            PermissionStatus(
                title: "Push Notifications",
                status: notificationManager.localizedAuthorizationStatus),
            PermissionStatus(
                title: "Microphone",
                status: AVCaptureDevice.authorizationStatus(for: .audio)
                    .localizedStatus),
            PermissionStatus(
                title: "Photo Library",
                status: PHPhotoLibrary.authorizationStatus().localizedStatus),
            PermissionStatus(
                title: "Contacts",
                status: CNContactStore.authorizationStatus(for: .contacts)
                    .localizedStatus),
            PermissionStatus(
                title: "Location",
                status: CLLocationManager().authorizationStatus.localizedStatus),
            PermissionStatus(
                title: "Calendar",
                status: EKEventStore.authorizationStatus(for: .event)
                    .localizedStatus),
            PermissionStatus(
                title: "Reminders",
                status: EKEventStore.authorizationStatus(for: .reminder)
                    .localizedStatus),
            PermissionStatus(
                title: "Motion & Fitness",
                status: CMMotionActivityManager.authorizationStatus()
                    .localizedStatus),
            PermissionStatus(
                title: "Health",
                status: HKHealthStore.isHealthDataAvailable()
                    ? HKHealthStore().authorizationStatus(
                        for: .activitySummaryType()
                    ).localizedStatus
                    : .unavailable),
            PermissionStatus(
                title: "HomeKit",
                status: {
                    if #available(iOS 16.0, *) {
                        return HMHomeManager().authorizationStatus
                            .localizedStatus
                    } else {
                        return .unavailableOldOS
                    }
                }()),
            PermissionStatus(
                title: "Bluetooth",
                status: CBManager.authorization.localizedStatus),
            PermissionStatus(
                title: "Cellular Data",
                status: CTCellularData().restrictedState.localizedStatus),
            PermissionStatus(
                title: "Siri & Dictation",
                status: SFSpeechRecognizer.authorizationStatus().localizedStatus
            ),
            PermissionStatus(
                title: "Face ID or Touch ID", status: .notApplicable),
            PermissionStatus(
                title: "Speech Recognition",
                status: SFSpeechRecognizer.authorizationStatus().localizedStatus
            ),
            PermissionStatus(title: "CalDAV & CardDAV", status: .notApplicable),
            PermissionStatus(
                title: "Music Library",
                status: MPMediaLibrary.authorizationStatus().localizedStatus),
            PermissionStatus(title: "Apple Music", status: .notApplicable),
            PermissionStatus(
                title: "Home & Lock Screen Widgets", status: .notApplicable),
        ]
    }

    var body: some View {
        List(permissions) { permission in
            HStack {
                Text(permission.title)
                Spacer()
                Text(permission.status.rawValue)
                    .foregroundColor(permission.status.color)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Permissions")
    }
}
