import XCTest
@testable import SmartFarmAI

final class SmartFarmAITests: XCTestCase {
    func testYieldPredictionFormValidation() {
        let vm = YieldPredictionViewModel()
        vm.farmSizeText = "abc"
        XCTAssertFalse(vm.isFormValid)
        vm.farmSizeText = "10"
        vm.soilQuality = 3
        XCTAssertTrue(vm.isFormValid)
    }

    func testOptimizationRecommendations() {
        let vm = OptimizationViewModel()
        vm.soilMoisture = 20
        vm.recentRainfallMm = 0
        vm.growthStage = .vegetative
        vm.calculate()
        XCTAssertTrue(vm.recommendations.contains(where: { $0.text.contains("Irrigate") }))
    }
}
