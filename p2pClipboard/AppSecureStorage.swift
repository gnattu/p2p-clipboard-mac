//
//  AppSecureStorage.swift
//  p2pClipboard
//
//  Created by Gnattu OC on 2/5/24.

import SwiftUI

@propertyWrapper
public struct AppSecureStorage: DynamicProperty {
    private let key: String
    private let accessibility:KeychainItemAccessibility
    
    public var wrappedValue: String? {
        get {
            KeychainWrapper.standard.string(forKey: key, withAccessibility: self.accessibility)
        }
        
        nonmutating set {
            if let newValue, !newValue.isEmpty  {
                KeychainWrapper.standard.set( newValue, forKey: key, withAccessibility: self.accessibility)
            }
            else {
                KeychainWrapper.standard.removeObject(forKey: key, withAccessibility: self.accessibility)
            }
        }
    }
    public init(_ key: String) {
        self.key = key
        self.accessibility = KeychainItemAccessibility.whenUnlocked
    }
}

class PreSharedKeyStore : ObservableObject {
    @AppSecureStorage("PSK") private var psk: String?
    @Published public var inputPsk = ""
    
    init() {
        inputPsk = psk ?? ""
    }
    
    func commitSettings() {
        guard !inputPsk.isEmpty else {
            return
        }
        psk = inputPsk
    }
    
    func resetSettings() {
        inputPsk = ""
        psk = nil
    }
}
