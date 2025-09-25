import Foundation

/// Utility for redacting sensitive information from event data
enum DataSanitizer {
    private static let sensitiveKeys: [String] = [
        "password", "passcode", "pwd", "otp", "pin",
        "token", "secret", "apikey", "api_key", "auth",
        "ssn", "social", "credit", "card", "cvv", "iban",
        "email", "phone", "phonenumber"
    ]
    
    static func sanitizeElementEventData(_ data: [String: Any]) -> [String: Any] {
        var sanitized: [String: Any] = [:]
        for (key, value) in data {
            let lowerKey = key.lowercased()
            if sensitiveKeys.contains(where: { lowerKey.contains($0) }) {
                sanitized[key] = "[REDACTED]"
                continue
            }
            if let stringValue = value as? String {
                if containsSensitiveHint(in: stringValue) {
                    sanitized[key] = "[REDACTED]"
                } else {
                    sanitized[key] = stringValue
                }
            } else if let dict = value as? [String: Any] {
                sanitized[key] = sanitizeElementEventData(dict)
            } else if let array = value as? [Any] {
                sanitized[key] = array.map { (item) -> Any in
                    if let s = item as? String { return containsSensitiveHint(in: s) ? "[REDACTED]" : s }
                    if let d = item as? [String: Any] { return sanitizeElementEventData(d) as Any }
                    return item
                }
            } else {
                sanitized[key] = value
            }
        }
        return sanitized
    }
    
    private static func containsSensitiveHint(in text: String) -> Bool {
        let lower = text.lowercased()
        return sensitiveKeys.contains(where: { lower.contains($0) })
    }
}


