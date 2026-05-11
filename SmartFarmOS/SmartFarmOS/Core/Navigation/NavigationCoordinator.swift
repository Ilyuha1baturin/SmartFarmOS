//
//  NavigationCoordinator.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import Foundation
import SwiftUI

@MainActor
@Observable
final class NavigationCoordinator {
    enum AppTab: String, CaseIterable { case farm, devices, ai, settings }
    
    var activeTab: AppTab = .farm
    var selectedDevice: FarmDevice?
    
    func navigate(to device: FarmDevice) { selectedDevice = device }
    func navigateBack() { selectedDevice = nil }
}