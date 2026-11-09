import SwiftUI

struct RootView: View {
    @EnvironmentObject var store: Store

    var body: some View {
        TabView {
            WatchlistView()
                .tabItem { Label("الأسعار", systemImage: "chart.line.downtrend.xyaxis") }
            OffersView()
                .tabItem { Label("العروض", systemImage: "gift") }
            SettingsView()
                .tabItem { Label("الإعدادات", systemImage: "gearshape") }
        }
        .task {
            store.requestNotificationPermission()
            await store.refreshFX()
        }
    }
}
