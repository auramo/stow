import Foundation
import SwiftData

/// Central place that defines the SwiftData schema and builds containers.
///
/// The model is intentionally CloudKit-compatible (every property optional or
/// defaulted, all relationships optional with inverses, no unique constraints),
/// so the store can be mirrored to iCloud without a migration: the existing
/// on-disk store is adopted and uploaded rather than replaced.
///
/// ## Switching iCloud sync on
///
/// Sync is wired but off, because CloudKit needs a paid Apple Developer Program
/// membership — a free personal team cannot create a container, and automatic
/// signing cannot issue a profile carrying the iCloud entitlement. Once enrolled:
///
/// 1. In the CloudKit console, create the container `iCloud.com.example.Stow`.
/// 2. In Xcode, target Stow → Signing & Capabilities → + Capability → iCloud,
///    tick CloudKit, and select that container. Also add Background Modes →
///    Remote notifications, so changes from other devices arrive while running.
/// 3. Point the target's `CODE_SIGN_ENTITLEMENTS` build setting at
///    `Stow/Stow.entitlements` (step 2 usually does this itself; verify the
///    file it picked is that one rather than a newly generated duplicate).
/// 4. Flip `syncsWithCloudKit` to `true` at the call site in `StowApp`.
///
/// Sync cannot be verified before that: without a real container there is
/// nothing to sync against, in the Simulator or on device.
enum StowModelContainer {
    static let schema = Schema([
        BaseList.self,
        BaseItem.self,
        PackingList.self,
        PackingItem.self,
    ])

    /// The app's on-disk container, optionally mirrored to the user's private
    /// iCloud database so their lists follow them between devices.
    static func makeStore(syncsWithCloudKit: Bool) -> ModelContainer {
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: syncsWithCloudKit ? .automatic : .none
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
