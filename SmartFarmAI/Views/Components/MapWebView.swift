import SwiftUI
import WebKit

struct MapWebView: UIViewRepresentable {
    @ObservedObject var viewModel: FieldSelectionViewModel

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.userContentController.add(context.coordinator, name: "mapBridge")
        let webView = WKWebView(frame: .zero, configuration: config)
        if let url = Bundle.main.url(forResource: "MapWebView", withExtension: "html", subdirectory: "SmartFarmAI/Views/Components") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        } else if let url = Bundle.main.url(forResource: "MapWebView", withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKScriptMessageHandler {
        let parent: MapWebView
        init(_ parent: MapWebView) { self.parent = parent }
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.name == "mapBridge", let body = message.body as? String, let data = body.data(using: .utf8) else { return }
            struct Payload: Decodable { let markers: [[Double]]; let polygon: [[Double]] }
            if let payload = try? JSONDecoder().decode(Payload.self, from: data) {
                parent.viewModel.update(markers: payload.markers, polygon: payload.polygon)
            }
        }
    }
}

#Preview() {
    MapView()
}


