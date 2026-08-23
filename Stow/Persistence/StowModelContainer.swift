import Foundation
import SwiftData

/// Central place that defines the SwiftData schema and builds containers.
///
/// The model is intentionally CloudKit-compatible (every property optional or
/// defaulted, all relationships optional with inverses, no unique constraints),
/// so enabling iCloud sync later is a one-line change — see `cloudKitDatabase`
/// below — plus adding the iCloud capability in Xcode (needs the paid Apple
/// Developer Program).
enum StowModelContainer {
    static let schema = Schema([
        BaseList.self,
        BaseItem.self,
        PackingList.self,
        PackingItem.self,
    ])

    /// The app's on-disk, local-only container.
    static func makeLocal() -> ModelContainer {
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
            // To enable iCloud sync later (after adding the iCloud/CloudKit
            // capability), add: `, cloudKitDatabase: .automatic`
        )
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create the Stow model container: \(error)")
        }
    }

    /// An ephemeral in-memory container for previews and tests.
    static func makeInMemory() -> ModelContainer {
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create the in-memory Stow model container: \(error)")
        }
    }
}
