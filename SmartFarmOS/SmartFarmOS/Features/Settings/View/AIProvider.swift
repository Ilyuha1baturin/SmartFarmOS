//
//  AIProvider.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import SwiftUI
import Security

enum AIProvider: String, CaseIterable { case deepseek, qwen, openai, custom }

struct SettingsView: View {
    @AppStorage("aiProvider") var selectedProvider: String = AIProvider.qwen.rawValue
    @State private var apiKey = ""
    
    var body: some View {
        Form {
            Section("ИИ-ассистент") {
                Picker("Провайдер", selection: $selectedProvider) {
                    ForEach(AIProvider.allCases, id: \.self) {
                        Text($0.rawValue.capitalized).tag($0.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                
                SecureField("API Key", text: $apiKey)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onAppear { loadKeychainKey() }
                    .onChange(of: apiKey) { _, newVal in saveKeychainKey(newVal) }
            }
            
            Section("О системе") {
                Text("SmartFarmOS v1.0 • ESP32 • SwiftData")
                Text("Дата билда: 12.05.2026")
            }
        }
        .navigationTitle("Настройки")
        .background(Color(.systemBackground))
    }
    
    private func saveKeychainKey(_ key: String) {
        let data = Data(key.utf8)
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: "SmartFarmOS.AIKey",
                                    kSecValueData as String: data]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    private func loadKeychainKey() {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: "SmartFarmOS.AIKey",
                                    kSecReturnData as String: true,
                                    kSecMatchLimit as String: kSecMatchLimitOne]
        var result: AnyObject?
        if SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
           let data = result as? Data {
            apiKey = String(data: data, encoding: .utf8) ?? ""
        }
    }
}