import Foundation
import CoreLocation

final class FieldSelectionViewModel: ObservableObject {
    @Published var markers: [CLLocationCoordinate2D] = []
    @Published var polygon: [CLLocationCoordinate2D] = []
    @Published var mapCenter: CLLocationCoordinate2D?
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var currentZoomLevel: Double = 0.02

    func update(markers: [[Double]], polygon: [[Double]]) {
        self.markers = markers.map { CLLocationCoordinate2D(latitude: $0[0], longitude: $0[1]) }
        self.polygon = polygon.map { CLLocationCoordinate2D(latitude: $0[0], longitude: $0[1]) }
    }

    var areaHectares: Double {
        guard polygon.count >= 3 else { return 0 }
        // Approximate using shoelace on lat/lon scaled by a rough factor
        // Convert degrees to meters using simple equirectangular projection around centroid
        let meanLat = polygon.map { $0.latitude }.reduce(0, +) / Double(polygon.count)
        let metersPerDegLat = 111_320.0
        let metersPerDegLon = 111_320.0 * cos(meanLat * .pi / 180)
        var sum = 0.0
        for i in 0..<polygon.count {
            let p1 = polygon[i]
            let p2 = polygon[(i + 1) % polygon.count]
            let x1 = p1.longitude * metersPerDegLon
            let y1 = p1.latitude * metersPerDegLat
            let x2 = p2.longitude * metersPerDegLon
            let y2 = p2.latitude * metersPerDegLat
            sum += (x1 * y2 - x2 * y1)
        }
        let areaMeters2 = abs(sum) / 2.0
        return areaMeters2 / 10_000.0
    }
    
    func zoomIn() {
        currentZoomLevel = max(0.001, currentZoomLevel * 0.7)
    }
    
    func zoomOut() {
        currentZoomLevel = min(0.5, currentZoomLevel * 1.4)
    }
}


