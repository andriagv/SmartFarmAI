Smart Farm AI (iOS)

Requirements
- Xcode 15+
- iOS 16+

Features
- Yield Prediction & Planner (Swift Charts, CSV/PDF export)
- Smart Pest Detection (camera, mock AI, Core Data history)
- Water & Fertilizer Optimization (recommendations, scheduling, notifications)
- Onboarding, Settings, Tutorial, Share

Setup
1. Open the project in Xcode.
2. In Signing & Capabilities, add your team.
3. Add permissions to Info.plist:
   - NSCameraUsageDescription
   - NSPhotoLibraryAddUsageDescription
   - NSUserTrackingUsageDescription (optional)
4. Run on iOS 16+ device/simulator.

Notes
- AI is mocked via simple heuristics; integrate Core ML in AIService.
- Notifications require user permission; test on device for delivery.

Testing
- Unit tests under Tests/. Press Cmd+U to run.


