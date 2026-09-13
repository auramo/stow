# Stow

An iOS packing-list app, called *Pakkaus* in Finnish.

Two kinds of list. **Base lists** are reusable templates — "ski trip", "hand
luggage" — that you keep and edit over time. A **packing list** is one actual
trip: pick any number of base lists, and their items are copied in (deduped,
case-insensitively) so you can tick them off. The copy is a snapshot, so
editing a trip never disturbs the template it came from, or the other way
round. Finished trips can be archived rather than deleted, items can be pasted
in from the clipboard a line at a time, and a packing list can be captured back
into a new base list once you know what you actually took.

Built with SwiftUI and SwiftData.

## Requirements

- Xcode 26.3 or newer
- iOS 18.0+ (iPhone and iPad)
- Swift 6

## Getting started

```sh
git clone git@github.com:auramo/stow.git
cd stow
cp Config/Local.xcconfig.template Config/Local.xcconfig
git config core.hooksPath .githooks
```

Then open `Stow.xcodeproj` and fill in `Config/Local.xcconfig` with your own
`ORG_IDENTIFIER` (a reverse-DNS prefix, e.g. `com.yourname`) and
`DEVELOPMENT_TEAM` (your Apple Developer Team ID, from Xcode > Settings >
Accounts). That file is git-ignored; it is the only place personal signing
values belong.

The project builds without it — the placeholders in `Config/Shared.xcconfig`
take over — but code signing needs a team of your own.

The `core.hooksPath` line enables a pre-commit hook that keeps those values out
of commits. Xcode writes them back into `project.pbxproj` whenever you touch
the Signing & Capabilities pane; the hook strips them and re-stages the file,
so you never have to do it by hand. Nothing is lost, since the build reads them
from the xcconfig.

## Tests

```sh
xcodebuild -project Stow.xcodeproj -scheme Stow \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

## iCloud sync

The SwiftData model is CloudKit-compatible and sync is wired up, but switched
off: CloudKit containers need a paid Apple Developer Program membership. See
the notes at the top of `Stow/Persistence/StowModelContainer.swift` for the
steps to turn it on.
