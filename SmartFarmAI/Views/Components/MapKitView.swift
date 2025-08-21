import SwiftUI
import MapKit

enum DrawingMode {
    case marker
    case polygon
    case rectangle
}

struct MapKitView: UIViewRepresentable {
    @ObservedObject var viewModel: FieldSelectionViewModel
    var mode: DrawingMode

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView(frame: .zero)
        map.delegate = context.coordinator
        map.isRotateEnabled = false
        map.isZoomEnabled = true
        map.isScrollEnabled = true
        map.showsUserLocation = true
        let center = viewModel.mapCenter ?? CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        map.region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        tap.numberOfTapsRequired = 1
        tap.cancelsTouchesInView = false
        map.addGestureRecognizer(tap)
        return map
    }

    func updateUIView(_ map: MKMapView, context: Context) {
        context.coordinator.parent = self
        if let center = viewModel.mapCenter, context.coordinator.isInitialLoad {
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: viewModel.currentZoomLevel, longitudeDelta: viewModel.currentZoomLevel))
            map.setRegion(region, animated: true)
            context.coordinator.isInitialLoad = false
        }
        
        // Handle zoom changes
        if context.coordinator.lastZoomLevel != viewModel.currentZoomLevel {
            let center = map.centerCoordinate
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: viewModel.currentZoomLevel, longitudeDelta: viewModel.currentZoomLevel))
            map.setRegion(region, animated: true)
            context.coordinator.lastZoomLevel = viewModel.currentZoomLevel
        }
        
        refresh(map)
    }

    fileprivate func refresh(_ map: MKMapView) {
        map.removeAnnotations(map.annotations)
        map.removeOverlays(map.overlays)
        for (i, coord) in viewModel.markers.enumerated() {
            let ann = DraggableAnnotation(index: i)
            ann.coordinate = coord
            ann.title = "corner-\(i)"
            map.addAnnotation(ann)
        }
        let polygonCoords: [CLLocationCoordinate2D]
        if !viewModel.polygon.isEmpty {
            polygonCoords = viewModel.polygon
        } else if viewModel.markers.count >= 3 {
            polygonCoords = viewModel.markers
        } else {
            polygonCoords = []
        }
        if polygonCoords.count >= 2 {
            var coords = viewModel.polygon
            if coords.isEmpty { coords = polygonCoords }
            coords.withUnsafeMutableBufferPointer { buf in
                if let base = buf.baseAddress {
                    let poly = MKPolygon(coordinates: base, count: buf.count)
                    map.addOverlay(poly)
                }
            }
        }
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapKitView
        var isInitialLoad = true
        var lastZoomLevel: Double = 0.02
        init(_ parent: MapKitView) { self.parent = parent }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let map = gesture.view as? MKMapView else { return }
            let point = gesture.location(in: map)
            let coord = map.convert(point, toCoordinateFrom: map)
            switch parent.mode {
            case .marker:
                parent.viewModel.markers.append(coord)
            case .polygon:
                parent.viewModel.polygon.append(coord)
            case .rectangle:
                if parent.viewModel.markers.isEmpty {
                    // Seed 4-corner rectangle around tapped point
                    let dLat = 0.003, dLon = 0.003
                    parent.viewModel.markers = [
                        CLLocationCoordinate2D(latitude: coord.latitude + dLat, longitude: coord.longitude - dLon),
                        CLLocationCoordinate2D(latitude: coord.latitude + dLat, longitude: coord.longitude + dLon),
                        CLLocationCoordinate2D(latitude: coord.latitude - dLat, longitude: coord.longitude + dLon),
                        CLLocationCoordinate2D(latitude: coord.latitude - dLat, longitude: coord.longitude - dLon)
                    ]
                    parent.viewModel.polygon = parent.viewModel.markers
                }
            }
            parent.refresh(map)
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polygon = overlay as? MKPolygon {
                let r = MKPolygonRenderer(polygon: polygon)
                r.fillColor = UIColor.systemGreen.withAlphaComponent(0.2)
                r.strokeColor = UIColor.systemGreen
                r.lineWidth = 2
                return r
            }
            return MKOverlayRenderer(overlay: overlay)
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation { return nil }
            let id = "farmMarker"
            let view = (mapView.dequeueReusableAnnotationView(withIdentifier: id) as? MKAnnotationView) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: id)
            view.canShowCallout = false
            view.isDraggable = true
            view.image = farmPinImage()
            view.centerOffset = CGPoint(x: 0, y: -12)
            return view
        }

        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
            guard newState == .ending || newState == .canceling, let ann = view.annotation as? DraggableAnnotation else { return }
            if ann.index < parent.viewModel.markers.count {
                parent.viewModel.markers[ann.index] = ann.coordinate
                if parent.mode == .rectangle || parent.viewModel.markers.count >= 3 {
                    parent.viewModel.polygon = parent.viewModel.markers
                }
                parent.refresh(mapView)
            }
        }
    }
}

final class DraggableAnnotation: MKPointAnnotation {
    let index: Int
    init(index: Int) { self.index = index; super.init() }
}

private func farmPinImage() -> UIImage? {
    let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
    let base = UIImage(systemName: "leaf.fill", withConfiguration: config)?.withTintColor(.white, renderingMode: .alwaysOriginal)
    let size = CGSize(width: 32, height: 40)
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { ctx in
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 16)
        UIColor.systemGreen.setFill(); path.fill()
        base?.draw(in: CGRect(x: 7, y: 8, width: 18, height: 18))
        UIColor.white.setStroke(); UIBezierPath(rect: rect).stroke()
    }
}


