import AVFoundation

enum CameraAuthorizationStatus {
    case authorized, denied, notDetermined, restricted
}

final class CameraService {
    static let shared = CameraService()
    private init() {}

    func authorizationStatus() -> CameraAuthorizationStatus {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: return .authorized
        case .denied: return .denied
        case .notDetermined: return .notDetermined
        case .restricted: return .restricted
        @unknown default: return .denied
        }
    }

    func requestAccess(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async { completion(granted) }
        }
    }
}


