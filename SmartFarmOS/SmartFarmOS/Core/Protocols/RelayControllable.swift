//
//  RelayControllable.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import Foundation

/// Устройства с релейными выходами (нагреватели, свет, клапаны)
public protocol RelayControllable {
    var relayStates: [Bool] { get set }
}