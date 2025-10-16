//
//  ApiDecryptor.swift
//  GiaVangVN
//
//  Created by L7 Mobile on 16/10/25.
//


import Foundation
import CommonCrypto

/// Decrypt base64-encoded AES/CBC/PKCS7 strings returned by the
/// https://giavang.pro/services/v1/dashboard/gold-price endpoint.
///
/// Usage examples:
///   GoldPriceDecryptor.decryptValue("BASE64_STRING")
///   GoldPriceDecryptor.decryptJSONFile(at: "payload.json")

class ApiDecryptor {
    // MARK: - Constants
    private static let key = "EEXnqn9tFQPsznmRz87nz85ESNhybsfp".data(using: .utf8)!
    private static let iv = "jSfDXMJC53AMB75g".data(using: .utf8)!
    private static let blockSize = kCCBlockSizeAES128
    
    // MARK: - Errors
    enum DecryptionError: Error, LocalizedError {
        case emptyPayload
        case invalidPadding
        case corruptedPadding
        case inputIsNil
        case decryptionFailed
        case invalidBase64
        case invalidJSON
        case missingDataObject
        
        var errorDescription: String? {
            switch self {
            case .emptyPayload:
                return "Decryption returned empty payload."
            case .invalidPadding:
                return "Invalid PKCS7 padding."
            case .corruptedPadding:
                return "Corrupted PKCS7 padding."
            case .inputIsNil:
                return "Input value is nil."
            case .decryptionFailed:
                return "Decryption failed."
            case .invalidBase64:
                return "Invalid base64 string."
            case .invalidJSON:
                return "Invalid JSON format."
            case .missingDataObject:
                return "JSON payload must contain a top-level 'data' object."
            }
        }
    }
    
    // MARK: - PKCS7 Padding
    private static func pkcs7Unpad(_ data: Data) throws -> Data {
        guard !data.isEmpty else {
            throw DecryptionError.emptyPayload
        }
        
        let padLen = Int(data[data.count - 1])
        
        guard padLen > 0, padLen <= data.count else {
            throw DecryptionError.invalidPadding
        }
        
        let paddingStartIndex = data.count - padLen
        let padding = data[paddingStartIndex...]
        
        guard padding.allSatisfy({ $0 == UInt8(padLen) }) else {
            throw DecryptionError.corruptedPadding
        }
        
        return data[..<paddingStartIndex]
    }
    
    // MARK: - AES Decryption
    private static func aesDecrypt(data: Data, key: Data, iv: Data) throws -> Data {
        let bufferSize = data.count + kCCBlockSizeAES128
        var buffer = Data(count: bufferSize)
        var numBytesDecrypted: size_t = 0
        
        let cryptStatus = buffer.withUnsafeMutableBytes { bufferBytes in
            data.withUnsafeBytes { dataBytes in
                key.withUnsafeBytes { keyBytes in
                    iv.withUnsafeBytes { ivBytes in
                        CCCrypt(
                            CCOperation(kCCDecrypt),
                            CCAlgorithm(kCCAlgorithmAES),
                            CCOptions(kCCOptionPKCS7Padding),
                            keyBytes.baseAddress, key.count,
                            ivBytes.baseAddress,
                            dataBytes.baseAddress, data.count,
                            bufferBytes.baseAddress, bufferSize,
                            &numBytesDecrypted
                        )
                    }
                }
            }
        }
        
        guard cryptStatus == kCCSuccess else {
            throw DecryptionError.decryptionFailed
        }
        
        return buffer[..<numBytesDecrypted]
    }
    
    // MARK: - Public Methods
    
    /// Decrypt a single base64-encoded field
    static func decryptValue(_ cipherText: String?) throws -> String {
        guard let cipherText = cipherText else {
            throw DecryptionError.inputIsNil
        }

        let trimmed = cipherText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            return ""
        }

        guard let cipherData = Data(base64Encoded: trimmed) else {
            throw DecryptionError.invalidBase64
        }

        // CCCrypt with kCCOptionPKCS7Padding automatically handles padding removal
        let decryptedData = try aesDecrypt(data: cipherData, key: key, iv: iv)

        guard let plainText = String(data: decryptedData, encoding: .utf8) else {
            throw DecryptionError.decryptionFailed
        }

        return plainText
    }
    
    static func decrypt(_ cipherText: String?) -> String? {
        do {
            return try decryptValue(cipherText)
        } catch {
            return nil
        }
    }

}
