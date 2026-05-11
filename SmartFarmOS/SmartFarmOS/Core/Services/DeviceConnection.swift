//
//  DeviceConnection.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import Foundation
import Network
import Combine

@MainActor
public final class DeviceConnection: ObservableObject {
    @Published public var state: NWConnection.State = .waiting(.other("Initial"))
    @Published public var lastError: Error?
    @Published public var parsedState: (any FarmDevice)?
    
    private let connection: NWConnection
    private let parser: (any ParserRegistry)?
    private let queue = DispatchQueue(label: "com.smartfarm.connection", qos: .userInitiated)
    private var receiveBuffer = Data()
    
    public init(ip: String, port: Int, parser: (any ParserRegistry)?) {
        self.parser = parser
        let endpoint = NWEndpoint.hostPort(host: .init(ip), port: .init(integerLiteral: port))
        self.connection = NWConnection(to: endpoint, using: .tcp)
        connection.stateUpdateHandler = { [weak self] newState in
            Task { @MainActor { self?.state = newState } }
            if newState == .ready {
                self?.startReceiving()
            }
        }
    }
    
    public func start() {
        connection.start(queue: queue)
    }
    
    public func stop() {
        connection.stateUpdateHandler = nil
        connection.cancel()
    }
    
    public func sendCommand<T: Encodable>(_ command: T) {
        guard connection.state == .ready,
              let data = try? JSONEncoder().encode(command) else { return }
        
        connection.send(content: data, completion: .contentProcessed { [weak self] error in
            if let error {
                Task { @MainActor { self?.lastError = error } }
            }
        })
    }
    
    private func startReceiving() {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 8192) { [weak self] content, _, isComplete, error in
            guard let self, let content, !content.isEmpty else {
                if isComplete || error != nil {
                    Task { @MainActor { self.state = .failed(error ?? URLError.networkConnectionLost) } }
                }
                return
            }
            
            receiveBuffer.append(content)
            self.processBuffer()
            self.startReceiving() // Рекурсивный вызов для постоянного чтения
        }
    }
    
    private func processBuffer() {
        // ESP32 обычно шлёт JSON, разделённый \n или \r\n
        let delimiter = UInt8(ascii: "\n")
        while let separatorIndex = receiveBuffer.firstIndex(of: delimiter) {
            let packetData = Data(receiveBuffer[..<separatorIndex])
            receiveBuffer.removeSubrange(...separatorIndex)
            
            guard !packetData.isEmpty,
                  let parser = parser,
                  let device = parser.parse(json: packetData) else { continue }
            
            Task { @MainActor { self.parsedState = device } }
        }
    }
}