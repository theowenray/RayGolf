import SwiftUI
import SwiftData

@main
struct RayGolfApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Round.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Check if there's a completed round from widget
                    checkForCompletedRound()
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    private func checkForCompletedRound() {
        let store = ActiveRoundStore.shared
        if store.isComplete {
            // Round was completed via widget, will be saved when user opens app
            // We'll handle this in RoundsListView
        }
    }
}
