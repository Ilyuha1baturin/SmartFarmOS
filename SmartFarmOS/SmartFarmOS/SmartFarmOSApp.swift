import SwiftUI
import SwiftData

@main
struct SmartFarmOSApp: App {
    // Инициализация единого контейнера SwiftData для всей экосистемы
    let modelContainer: ModelContainer
    
    init() {
        let schema = Schema([DeviceEntity.self, TelemetryReading.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        
        do {
            modelContainer = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("❌ Failed to setup SwiftData: \(error.localizedDescription)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(modelContainer)
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            // Заглушки для будущих Features
            Features.FarmDashboardView()
                .tabItem { Label("Ферма", systemImage: "building.columns.fill") }
            
            Features.DeviceRegistryView()
                .tabItem { Label("Устройства", systemImage: "cpu") }
            
            Features.AIChatView()
                .tabItem { Label("ИИ-чат", systemImage: "brain.fill") }
            
            Features.SettingsView()
                .tabItem { Label("Настройки", systemImage: "gearshape.fill") }
        }
    }
}

// MARK: - Временные заглушки для компиляции (заменятся на реальные Feature-модули)
enum Features {
    struct FarmDashboardView: View { var body: some View { Text("🌾 Дашборд фермы").font(.largeTitle) } }
    struct DeviceRegistryView: View { var body: some View { Text("📡 Список устройств").font(.largeTitle) } }
    struct AIChatView: View { var body: some View { Text("🤖 ИИ-ассистент").font(.largeTitle) } }
    struct SettingsView: View { var body: some View { Text("⚙️ Настройки").font(.largeTitle) } }
}
