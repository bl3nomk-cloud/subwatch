import SwiftUI

@main
struct SubWatchApp: App {
    @StateObject private var store = Store()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .environment(\.layoutDirection, .rightToLeft)
                .environment(\.locale, Locale(identifier: "ar_SA"))
                .preferredColorScheme(.dark)
                .tint(Color(red: 0.55, green: 0.42, blue: 1.0))
        }
    }
}
