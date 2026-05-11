//
//  TipsEngine.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import Foundation

final class TipsEngine: ObservableObject {
    @Published var currentTip: String = "Инициализация системы..."
    private var tips: [String] = [
        "Проверьте плотность посадки в брудере на 3-й день",
        "Калибруйте датчик CO2 каждые 30 дней",
        "При росте >2.5°C/ч снижайте мощность обогревателя на 10%",
        "Ульи: проверяйте вес каждые 48ч в период главного медосбора",
        "Телятник: вентиляция должна обеспечивать 0.5 м³/ч на 100кг живого веса"
    ]
    private var index = -1
    
    func getNextDaily() -> String {
        index = (index + 1) % tips.count
        currentTip = tips[index]
        return currentTip
    }
    
    func getTipForDay(_ day: Int, type: DeviceType) -> String {
        // Заглушка для календарных советов
        switch type {
        case .brooder: return day > 21 ? "Переведите на естественный свет" : "Контролируйте влажность >60%"
        case .beehive: return "Проверьте летковую щель перед зимой"
        default: return "Следуйте штатному протоколу обслуживания"
        }
    }
}