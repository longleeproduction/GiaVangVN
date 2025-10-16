//
//  String+Ext.swift
//
import Foundation

extension String {
    func percentEncoded() -> String {
        let allowed = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~")
        return self.addingPercentEncoding(withAllowedCharacters: allowed) ?? self
    }
}
