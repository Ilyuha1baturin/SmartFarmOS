//
//  FarmDevice.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import Foundation
import SwiftUI

// MARK: - Протоколы (для контекста, обычно вынесены в Core/Protocols)
protocol FarmDevice: AnyObject {
    var id: UUID { get }
    var name: String { get set }
    var isConnected: Bool { get set }
}
protocol ClimateControllable {
    var currentTemp: Double { get }
    var targetTemp: Double { get set }
    var currentHumidity: Double { get }
    var targetHumidity: Double { get set }
    func setTargetTemp(_ temp: Double)
    func setTargetHumidity(_ hum: Double)
}
protocol RelayControllable {
    var relayStates: [Bool] { get }
    func setRelay(index: Int, state: Bool)
}

// MARK: - Устройство
final class BrooderDevice: ObservableObject, FarmDevice, ClimateControllable, RelayControllable {
    let id: UUID
    @Published var name: String
    @Published var isConnected: Bool = false
    
    @Published var currentTemp: Double = 0
    @Published var targetTemp: Double = 33.0
    @Published var currentHumidity: Double = 0
    @Published var targetHumidity: Double = 65.0
    @Published var lux: Int = 0
    @Published var co2: Int = 0
    @Published var nh3Delta: Int = 0
    @Published var iaq: Int = 0
    @Published var isWaterOk: Bool = true
    @Published var isLidClosed: Bool = true
    @Published var isDoorClosed: Bool = true
    @Published var isPanic: Bool = false
    @Published var fanSpeedPercent: Int = 0
    @Published var isAutoMode: Bool = true
    @Published var ageDays: Int = 1
    @Published var ageOffset: Int = 0
    @Published var breedIndex: Int = 0
    @Published var relayStates: [Bool] = Array(repeating: false, count: 5)
    @Published var alarmActive: Bool = false
    @Published var tips: BrooderParser.TipsContent = .init(current: nil, past: nil, future: nil, rotating: nil)
    
    private let connection: DeviceConnection
    
    init(id: UUID, name: String, connection: DeviceConnection) {
        self.id = id
        self.name = name
        self.connection = connection
    }
    
    // MARK: - Обновление состояния
    func update(from dto: BrooderStateDTO) {
        DispatchQueue.main.async {
            if let t = dto.t { self.currentTemp = t }
            if let tt = dto.tt { self.targetTemp = tt }
            if let h = dto.h { self.currentHumidity = h }
            if let th = dto.th { self.targetHumidity = Double(th) }
            if let l = dto.l { self.lux = l }
            if let co2 = dto.co2 { self.co2 = co2 }
            if let nh3 = dto.nh3 { self.nh3Delta = nh3 }
            if let iaq = dto.iaq { self.iaq = iaq }
            if let w = dto.w { self.isWaterOk = w }
            if let lid = dto.lid { self.isLidClosed = lid }
            if let door = dto.door { self.isDoorClosed = door }
            if let p = dto.p { self.isPanic = p }
            if let fan = dto.fan { self.fanSpeedPercent = Int(Double(fan) / 2.55) }
            if let mode = dto.mode { self.isAutoMode = mode }
            if let age = dto.age { self.ageDays = age }
            if let offset = dto.ageOffset { self.ageOffset = offset }
            if let breed = dto.breed { self.breedIndex = breed }
            if let relays = dto.r { self.relayStates = relays }
            if let alarm = dto.a { self.alarmActive = alarm }
            self.isConnected = true
        }
    }
    
    func updateTips(from content: BrooderParser.TipsContent) {
        DispatchQueue.main.async { self.tips = content }
    }
    
    // MARK: - ClimateControllable
    func setTargetTemp(_ temp: Double) {
        targetTemp = temp
        connection.send(command: "setTemp", value: temp)
    }
    
    func setTargetHumidity(_ hum: Double) {
        targetHumidity = hum
        connection.send(command: "setHum", value: Int(hum))
    }
    
    // MARK: - RelayControllable
    func setRelay(index: Int, state: Bool) {
        guard index >= 0 && index < 5 else { return }
        if isAutoMode { return } // Блокировка в авто-режиме
        relayStates[index] = state
        connection.send(command: "setRelay", id: index, value: state)
    }
    
    // MARK: - Дополнительные команды
    func setMode(_ auto: Bool) {
        isAutoMode = auto
        connection.send(command: "setMode", value: auto)
    }
    
    func setAgeOffset(_ offset: Int) {
        ageOffset = offset
        connection.send(command: "setAge", value: offset)
    }
    
    func setBreed(_ index: Int) {
        breedIndex = index
        connection.send(command: "setBreed", value: index)
    }
    
    func calibrateCO2() { connection.send(raw: "{\"cmd\":\"calCO2\"}") }
    func calibrateNH3() { connection.send(raw: "{\"cmd\":\"calNH3\"}") }
    func resetStartDate() { connection.send(raw: "{\"cmd\":\"resetStart\"}") }
}

// MARK: - DeviceConnection (заглушка/интерфейс из Core)
protocol DeviceConnection: AnyObject {
    func send(command: String, value: Any?)
    func send(command: String, id: Int?, value: Bool?)
    func send(raw: String)
}