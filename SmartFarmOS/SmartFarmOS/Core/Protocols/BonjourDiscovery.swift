//
//  BonjourDiscovery.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import Foundation
import Combine
import Network

@MainActor
public final class BonjourDiscovery: ObservableObject {
    @Published public var discoveredDevices: [DiscoveredDevice] = []
    
    public struct DiscoveredDevice: Identifiable, Hashable, Sendable {
        public let id = UUID()
        public let name: String
        public let ipAddress: String
        public let port: Int
        public let deviceType: DeviceType
    }
    
    private var browser: NetServiceBrowser?
    private var pendingResolutions: [String: NetService] = [:]
    
    public init() {}
    
    public func startSearching() {
        stopSearching()
        browser = NetServiceBrowser()
        browser?.delegate = self
        browser?.searchForServices(ofType: "_smartfarm._tcp", inDomain: "local.")
    }
    
    public func stopSearching() {
        browser?.stop()
        browser?.delegate = nil
        browser = nil
        pendingResolutions.removeAll()
        Task { @MainActor in discoveredDevices.removeAll() }
    }
    
    deinit { stopSearching() }
}

// MARK: - NetServiceBrowserDelegate
extension BonjourDiscovery: NetServiceBrowserDelegate {
    public func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        pendingResolutions[service.name] = service
        service.delegate = self
        service.resolve(withTimeout: 4.0)
    }
    
    public func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        pendingResolutions.removeValue(forKey: service.name)
        Task { @MainActor in discoveredDevices.removeAll { $0.name == service.name } }
    }
}

// MARK: - NetServiceDelegate
extension BonjourDiscovery: NetServiceDelegate {
    public func netServiceDidResolveAddress(_ sender: NetService) {
        pendingResolutions.removeValue(forKey: sender.name)
        guard let addressData = sender.addresses?.first else { return }
        
        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
        addressData.withUnsafeBytes {
            guard let base = $0.baseAddress else { return }
            _ = getnameinfo(base, socklen_t($0.count), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST)
        }
        let ip = String(cString: hostname)
        let port = sender.port
        
        // Извлечение типа устройства из TXT записей (ESP32 должен публиковать key="type")
        let txtDict = NetService.dictionary(fromTXTRecord: sender.txtRecordData())
        let typeData = txtDict["type"] ?? txtDict["deviceType"]
        let rawType = typeData.flatMap { String(data: $0, encoding: .utf8) }
        let deviceType = rawType.flatMap { DeviceType(rawValue: $0) } ?? .unknown
        
        Task { @MainActor in
            let new = DiscoveredDevice(name: sender.name, ipAddress: ip, port: port, deviceType: deviceType)
            if !discoveredDevices.contains(where: { $0.ipAddress == ip && $0.port == port }) {
                discoveredDevices.append(new)
            }
        }
    }
    
    public func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        pendingResolutions.removeValue(forKey: sender.name)
    }
}