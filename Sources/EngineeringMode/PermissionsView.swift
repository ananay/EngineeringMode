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

protocol AuthorizationStatus {
    var localizedStatus: String { get }
}

extension AuthorizationStatus {
    var localizedStatus: String {
        let label = String(describing: self)

        switch label {
        case "authorized", "allowedAlways", "sharingAuthorized",
            "notRestricted", "authorizedAlways",
            "authorizedWhenInUse":
            return "Granted"
        case "denied", "sharingDenied":
            return "Denied"
        case "restricted":
            return "Restricted"
        case "notDetermined":
            return "Not Determined"
        case "limited":
            return "Limited"
        case "determined":
            return "Determined"
        default:
            return "Unknown"
        }
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
    var localizedStatus: String {
        if #available(iOS 16.0, *) {
            switch self {
            case .authorized:
                return "Granted"
            case .restricted:
                return "Restricted"
            case .determined:
                return "Determined"
            default:
                return "Unknown"
            }
        } else {
            return "Unknown"
        }
    }
}

struct PermissionStatus: Identifiable {
    let id = UUID()
    let title: String
    let status: String
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
        updateAuthorizationStatus()
    }

    func updateAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
            }
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
                status: notificationManager.authorizationStatus.localizedStatus),
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
                    : "Unavailable"),
            PermissionStatus(
                title: "HomeKit",
                status: {
                    if #available(iOS 16.0, *) {
                        return HMHomeManager().authorizationStatus
                            .localizedStatus
                    } else {
                        return "Unavailable on iOS < 16.0"
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
            PermissionStatus(title: "Face ID or Touch ID", status: "N/A"),
            PermissionStatus(
                title: "Speech Recognition",
                status: SFSpeechRecognizer.authorizationStatus().localizedStatus
            ),
            PermissionStatus(title: "CalDAV & CardDAV", status: "N/A"),
            PermissionStatus(
                title: "Music Library",
                status: MPMediaLibrary.authorizationStatus().localizedStatus),
            PermissionStatus(title: "Apple Music", status: "N/A"),
            PermissionStatus(
                title: "Home & Lock Screen Widgets", status: "N/A"),
        ]
    }

    var body: some View {
        List(permissions) { permission in
            HStack {
                Text(permission.title)
                Spacer()
                Text(permission.status)
                    .foregroundColor(
                        permission.status == "Granted" ? .green : .red)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Permissions")
    }
}
