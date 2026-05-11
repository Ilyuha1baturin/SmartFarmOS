//
//  Weighable.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import Foundation

/// Устройства с весами (телята, ульи, инкубаторы)
public protocol Weighable {
    var currentWeight: Double { get set }       // кг
}