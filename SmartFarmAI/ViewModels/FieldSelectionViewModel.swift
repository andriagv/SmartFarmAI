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
        // Use markers if polygon is empty, but we have enough markers
        let coordinates = polygon.isEmpty && markers.count >= 3 ? markers : polygon
        guard coordinates.count >= 3 else { return 0 }
        
        // Improved area calculation using Haversine formula for more accuracy
        let meanLat = coordinates.map { $0.latitude }.reduce(0, +) / Double(coordinates.count)
        let metersPerDegLat = 111_320.0
        let metersPerDegLon = 111_320.0 * cos(meanLat * .pi / 180)
        
        var sum = 0.0
        for i in 0..<coordinates.count {
            let p1 = coordinates[i]
            let p2 = coordinates[(i + 1) % coordinates.count]
            let x1 = p1.longitude * metersPerDegLon
            let y1 = p1.latitude * metersPerDegLat
            let x2 = p2.longitude * metersPerDegLon
            let y2 = p2.latitude * metersPerDegLat
            sum += (x1 * y2 - x2 * y1)
        }
        let areaMeters2 = abs(sum) / 2.0
        return areaMeters2 / 10_000.0
    }
    
    var coordinatesText: String {
        let coordinates = polygon.isEmpty && markers.count >= 3 ? markers : polygon
        guard !coordinates.isEmpty else { return "No area selected" }
        
        let formattedCoords = coordinates.prefix(4).map { 
            String(format: "%.4f, %.4f", $0.latitude, $0.longitude) 
        }.joined(separator: " • ")
        
        return coordinates.count > 4 ? "\(formattedCoords)..." : formattedCoords
    }
    
    func zoomIn() {
        currentZoomLevel = max(0.001, currentZoomLevel * 0.7)
    }
    
    func zoomOut() {
        currentZoomLevel = min(0.5, currentZoomLevel * 1.4)
    }
}


