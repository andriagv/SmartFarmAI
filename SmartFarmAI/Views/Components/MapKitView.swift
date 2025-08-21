import SwiftUI
import MapKit

enum DrawingMode {
    case marker
    case polygon
}

struct MapKitView: UIViewRepresentable {
    @ObservedObject var viewModel: FieldSelectionViewModel
    var mode: DrawingMode

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView(frame: .zero)
        map.delegate = context.coordinator
        map.isRotateEnabled = false
        map.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        )
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        map.addGestureRecognizer(tap)
        return map
    }

    func updateUIView(_ map: MKMapView, context: Context) {
        context.coordinator.parent = self
        refresh(map)
    }

    fileprivate func refresh(_ map: MKMapView) {
        map.removeAnnotations(map.annotations)
        map.removeOverlays(map.overlays)
        for coord in viewModel.markers {
            let ann = MKPointAnnotation()
            ann.coordinate = coord
            map.addAnnotation(ann)
        }
        if viewModel.polygon.count >= 2 {
            var coords = viewModel.polygon
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
    }
}


