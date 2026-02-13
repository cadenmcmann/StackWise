import Foundation
import Security

enum SecureStorageKeys {
    static let authToken = "auth_token"
    static let currentUser = "current_user"
    static let currentStack = "current_stack"
}

final class SecureStorage {
    static let shared = SecureStorage()

    private let serviceName: String

    private init(serviceName: String = Bundle.main.bundleIdentifier ?? "com.deltaic.StackWise") {
        self.serviceName = serviceName
    }

    func setString(_ value: String, for key: String) {
        guard let data = value.data(using: .utf8) else { return }
        setData(data, for: key)
    }

    func getString(for key: String) -> String? {
        guard let data = getData(for: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func setCodable<T: Codable>(_ value: T, for key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        setData(data, for: key)
    }

    func getCodable<T: Codable>(_ type: T.Type, for key: String) -> T? {
        guard let data = getData(for: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    func deleteValue(for key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }

    private func setData(_ data: Data, for key: String) {
        deleteValue(for: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        #if DEBUG
        if status != errSecSuccess {
            print("SecureStorage set failed for key \(key): \(status)")
        }
        #endif
    }

    private func getData(for key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess else { return nil }
        return item as? Data
    }
}
