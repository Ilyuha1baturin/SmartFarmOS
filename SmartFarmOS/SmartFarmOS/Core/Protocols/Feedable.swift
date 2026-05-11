//
//  Feedable.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import Foundation

/// Устройства с системой кормления
public protocol Feedable {
    var feedLevel: Double { get set }           // 0.0 (пуст) ... 1.0 (полн)
    var feedSchedule: [DateComponents] { get set }
}