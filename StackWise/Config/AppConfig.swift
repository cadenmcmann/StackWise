import Foundation

/// App configuration loaded from xcconfig files via Info.plist
///
/// To use this:
/// 1. Add the xcconfig files to your Xcode project
/// 2. In Project → Info → Configurations, set Debug to use Debug.xcconfig and Release to use Release.xcconfig
/// 3. Add the API_BASE_URL key to Info.plist with value $(API_BASE_URL)
///
/// For development before xcconfig is linked, falls back to a default URL.
public enum AppConfig {
    public static let termsOfServiceURLString = "https://stackwise-legal-20260213105358-21950.s3.amazonaws.com/terms/index.html"
    public static let privacyPolicyURLString = "https://stackwise-legal-20260213105358-21950.s3.amazonaws.com/privacy/index.html"
    public static let safetyDisclaimersURLString = "https://stackwise-legal-20260213105358-21950.s3.amazonaws.com/safety/index.html"
    public static let supportPageURLString = "https://stackwise-legal-20260213105358-21950.s3.amazonaws.com/support/index.html"
    public static let supportEmailAddress = "support@stackwise-app.com"
    
    /// The base URL for all API requests
    /// Reads from Info.plist which gets its value from the active xcconfig file
    public static var apiBaseURL: String {
        // Try to read from Info.plist (set via xcconfig)
        if let url = Bundle.main.infoDictionary?["API_BASE_URL"] as? String, !url.isEmpty {
            return url
        }
        
        // Fallback for development (before xcconfig is linked in Xcode)
        #if DEBUG
        return "https://9f8skioo9f.execute-api.us-east-1.amazonaws.com/"
        #else
        fatalError("API_BASE_URL not configured in Info.plist. Please link xcconfig files in Xcode.")
        #endif
    }
    
    /// Whether the app is running in debug mode
    public static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    public static var termsOfServiceURL: URL? {
        URL(string: termsOfServiceURLString)
    }

    public static var privacyPolicyURL: URL? {
        URL(string: privacyPolicyURLString)
    }

    public static var safetyDisclaimersURL: URL? {
        URL(string: safetyDisclaimersURLString)
    }

    public static var supportPageURL: URL? {
        URL(string: supportPageURLString)
    }
}

