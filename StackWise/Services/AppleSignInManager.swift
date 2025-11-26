import Foundation
import AuthenticationServices

// MARK: - Apple Sign In Credentials
public struct AppleSignInCredentials {
    let identityToken: String
    let authorizationCode: String?
    let email: String?
    let firstName: String?
    let lastName: String?
}

// MARK: - Apple Sign In Error
public enum AppleSignInError: Error, LocalizedError {
    case invalidCredential
    case missingIdentityToken
    case tokenEncodingFailed
    case cancelled
    case unknown(Error)
    
    public var errorDescription: String? {
        switch self {
        case .invalidCredential:
            return "Invalid Apple credential received"
        case .missingIdentityToken:
            return "Identity token not found in Apple credential"
        case .tokenEncodingFailed:
            return "Failed to encode identity token"
        case .cancelled:
            return "Sign in with Apple was cancelled"
        case .unknown(let error):
            return "Apple Sign In failed: \(error.localizedDescription)"
        }
    }
}

// MARK: - AppleSignInManager
public class AppleSignInManager: NSObject {
    
    private var continuation: CheckedContinuation<AppleSignInCredentials, Error>?
    
    /// Start the Sign in with Apple flow
    /// - Returns: AppleSignInCredentials containing the identity token and user info
    public func startSignIn() async throws -> AppleSignInCredentials {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            
            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AppleSignInManager: ASAuthorizationControllerDelegate {
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            continuation?.resume(throwing: AppleSignInError.invalidCredential)
            continuation = nil
            return
        }
        
        // Extract identity token
        guard let identityTokenData = appleIDCredential.identityToken else {
            continuation?.resume(throwing: AppleSignInError.missingIdentityToken)
            continuation = nil
            return
        }
        
        guard let identityToken = String(data: identityTokenData, encoding: .utf8) else {
            continuation?.resume(throwing: AppleSignInError.tokenEncodingFailed)
            continuation = nil
            return
        }
        
        // Extract authorization code (optional)
        var authorizationCode: String? = nil
        if let authCodeData = appleIDCredential.authorizationCode {
            authorizationCode = String(data: authCodeData, encoding: .utf8)
        }
        
        // Extract email (only provided on first sign in)
        let email = appleIDCredential.email
        
        // Extract name components (only provided on first sign in)
        let firstName = appleIDCredential.fullName?.givenName
        let lastName = appleIDCredential.fullName?.familyName
        
        let credentials = AppleSignInCredentials(
            identityToken: identityToken,
            authorizationCode: authorizationCode,
            email: email,
            firstName: firstName,
            lastName: lastName
        )
        
        continuation?.resume(returning: credentials)
        continuation = nil
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        if let authError = error as? ASAuthorizationError {
            switch authError.code {
            case .canceled:
                continuation?.resume(throwing: AppleSignInError.cancelled)
            default:
                continuation?.resume(throwing: AppleSignInError.unknown(error))
            }
        } else {
            continuation?.resume(throwing: AppleSignInError.unknown(error))
        }
        continuation = nil
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AppleSignInManager: ASAuthorizationControllerPresentationContextProviding {
    
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // Get the key window from the first connected scene
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            // Fallback: create a new window if needed
            return UIWindow()
        }
        return window
    }
}

