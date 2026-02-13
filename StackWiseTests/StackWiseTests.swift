//
//  StackWiseTests.swift
//  StackWiseTests
//
//  Created by Caden McMann on 9/5/25.
//

import Testing
@testable import StackWise

// MARK: - Main Test Suite
/// This file serves as the entry point for the test suite.
/// Individual test files are organized by category:
///
/// - Models/: UserTests, SupplementTests, IntakeTests
/// - Services/: IntakeLogManagerTests, NetworkManagerTests
/// - ViewModels/: StackViewModelTests, OnboardingViewModelTests, TodayViewModelTests, TrackViewModelTests
/// - Utilities/: ExtensionsTests, APIModelsTests
/// - Mocks/: Mock service implementations
/// - Helpers/: TestHelpers with factory methods

@Suite("StackWise Test Suite")
struct StackWiseTests {
    
    @Test("Test suite is properly configured")
    func testSuiteConfigured() {
        // Verify the test target can access the main module
        #expect(true)
    }
}
