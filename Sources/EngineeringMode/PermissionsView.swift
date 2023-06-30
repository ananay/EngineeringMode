import SwiftUI
import AVFoundation
import Photos
import Contacts
import CoreLocation
import EventKit
import CoreMotion
import HealthKit
import HomeKit
import CoreBluetooth
import CoreTelephony
import Intents
import Speech
import AuthenticationServices
import MediaPlayer

struct PermissionStatus: Identifiable {
    let id = UUID()
    let title: String
    let status: String
}

struct PermissionsView: View {
    let permissions: [PermissionStatus] = [
        PermissionStatus(title: "Camera", status: AVCaptureDevice.authorizationStatus(for: .video).localizedStatus),
        PermissionStatus(title: "Microphone", status: AVCaptureDevice.authorizationStatus(for: .audio).localizedStatus),
        PermissionStatus(title: "Photo Library", status: PHPhotoLibrary.authorizationStatus().localizedStatus),
        PermissionStatus(title: "Contacts", status: CNContactStore.authorizationStatus(for: .contacts).localizedStatus),
        PermissionStatus(title: "Location", status: CLLocationManager.authorizationStatus().localizedStatus),
        PermissionStatus(title: "Calendar", status: EKEventStore.authorizationStatus(for: .event).localizedStatus),
        PermissionStatus(title: "Reminders", status: EKEventStore.authorizationStatus(for: .reminder).localizedStatus),
        PermissionStatus(title: "Motion & Fitness", status: CMMotionActivityManager.authorizationStatus().localizedStatus),
        PermissionStatus(title: "Health", status: HKHealthStore.isHealthDataAvailable() ? HKHealthStore().authorizationStatus(for: .activitySummaryType()).localizedStatus : "Unavailable"),
//        PermissionStatus(title: "HomeKit", status: HMHomeManager().authorizationStatus.localizedStatus),
        PermissionStatus(title: "Bluetooth", status: CBPeripheralManager.authorizationStatus().localizedStatus),
        PermissionStatus(title: "Cellular Data", status: CTCellularData().restrictedState.localizedStatus),
        PermissionStatus(title: "Push Notifications", status: "N/A"),
        PermissionStatus(title: "Siri & Dictation", status: SFSpeechRecognizer.authorizationStatus().localizedStatus),
        PermissionStatus(title: "Face ID or Touch ID", status: "N/A"),
        PermissionStatus(title: "Speech Recognition", status: SFSpeechRecognizer.authorizationStatus().localizedStatus),
        PermissionStatus(title: "CalDAV & CardDAV", status: "N/A"),
        PermissionStatus(title: "Music Library", status: MPMediaLibrary.authorizationStatus().localizedStatus),
        PermissionStatus(title: "Apple Music", status: "N/A"),
        PermissionStatus(title: "Home & Lock Screen Widgets", status: "N/A")
    ]

    var body: some View {
        List(permissions) { permission in
            HStack {
                Text(permission.title)
                Spacer()
                Text(permission.status)
                    .foregroundColor(permission.status == "Granted" ? .green : .red)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Permissions")
    }
}

extension AVAuthorizationStatus {
    var localizedStatus: String {
        switch self {
        case .authorized:
            return "Granted"
        case .denied:
            return "Denied"
        case .restricted:
            return "Restricted"
        case .notDetermined:
            return "Not Determined"
        default:
            return "Unknown"
        }
    }
}

extension PHAuthorizationStatus {
    var localizedStatus: String {
        switch self {
        case .authorized:
            return "Granted"
        case .denied:
            return "Denied"
        case .restricted:
            return "Restricted"
        case .notDetermined:
            return "Not Determined"
        case .limited:
            return "Limited"
        default:
            return "Unknown"
        }
    }
}

extension CNAuthorizationStatus {
    var localizedStatus: String {
        switch self {
        case .authorized:
            return "Granted"
        case .denied:
            return "Denied"
        case .restricted:
            return "Restricted"
        case .notDetermined:
            return "Not Determined"
        default:
            return "Unknown"
        }
    }
}

extension CLAuthorizationStatus {
    var localizedStatus: String {
        switch self {
        case .authorizedAlways, .authorizedWhenInUse:
            return "Granted"
        case .denied:
            return "Denied"
        case .restricted:
            return "Restricted"
        case .notDetermined:
            return "Not Determined"
        default:
            return "Unknown"
        }
    }
}

extension EKAuthorizationStatus {
    var localizedStatus: String {
        switch self {
        case .authorized:
            return "Granted"
        case .denied:
            return "Denied"
        case .restricted:
            return "Restricted"
        case .notDetermined:
            return "Not Determined"
        default:
            return "Unknown"
        }
    }
}

extension CMAuthorizationStatus {
    var localizedStatus: String {
        switch self {
        case .authorized:
            return "Granted"
        case .denied:
            return "Denied"
        case .restricted:
            return "Restricted"
        case .notDetermined:
            return "Not Determined"
        default:
            return "Unknown"
        }
    }
}

extension HKAuthorizationStatus {
    var localizedStatus: String {
        switch self {
        case .sharingAuthorized:
            return "Granted"
        case .sharingDenied:
            return "Denied"
        case .notDetermined:
            return "Not Determined"
        default:
            return "Unknown"
        }
    }
}

extension HMHomeManagerAuthorizationStatus {
    var localizedStatus: String {
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
    }
}

extension CBPeripheralManagerAuthorizationStatus {
    var localizedStatus: String {
        switch self {
        case .authorized:
            return "Granted"
        case .denied:
            return "Denied"
        case .restricted:
            return "Restricted"
        case .notDetermined:
            return "Not Determined"
        default:
            return "Unknown"
        }
    }
}

extension CTCellularDataRestrictedState {
    var localizedStatus: String {
        switch self {
        case .restricted:
            return "Restricted"
        case .notRestricted:
            return "Not Restricted"
        default:
            return "Unknown"
        }
    }
}

extension SFSpeechRecognizerAuthorizationStatus {
    var localizedStatus: String {
        switch self {
        case .authorized:
            return "Granted"
        case .denied:
            return "Denied"
        case .restricted:
            return "Restricted"
        case .notDetermined:
            return "Not Determined"
        default:
            return "Unknown"
        }
    }
}

extension MPMediaLibraryAuthorizationStatus {
    var localizedStatus: String {
        switch self {
        case .authorized:
            return "Granted"
        case .denied:
            return "Denied"
        case .restricted:
            return "Restricted"
        case .notDetermined:
            return "Not Determined"
        default:
            return "Unknown"
        }
    }
}
