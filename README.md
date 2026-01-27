# FinChronicle

Native iOS app built with SwiftUI (iOS 15+), featuring a CodeBreaker game and foundations for financial chronicle tracking.

## Features

- CodeBreaker game with color/peg matching
- Match markers for exact/partial hits
- Financial chronicle tracking (early stage)

## Requirements

- iOS 15.0+
- Xcode 15.0+
- Swift 5.7+

## Setup & Run

1) Clone
```bash
git clone <repository-url>
cd FinChronicle
```

2) Open in Xcode
```bash
open FinChronicle.xcodeproj
```

3) Run
- Select a simulator (e.g., iPhone 15)
- Build & run: ⌘ + R

## Project Structure

```
FinChronicle/
├── FinChronicleApp.swift          # App entry
├── CodeBreaker.swift              # Game model/logic
├── CodeBreakerView.swift          # Game UI
├── MatchMarkers.swift             # Marker UI
└── FinChronicleViews/
    └── FinChronicleMainView.swift # Placeholder main view
```

## Development

### Build targets
- App: FinChronicle (iOS 15+)
- Tests: FinChronicleTests, FinChronicleUITests

### Running tests
- All tests: ⌘ + U
- Individual test: run the gutter diamond in Xcode

### Linting
- SwiftLint config: .swiftlint.yml
- Run locally (if installed): `swiftlint lint --strict`

### Coding guidelines
- MVVM with SwiftUI; keep views thin, move logic to view models/models
- Avoid force unwraps; prefer optionals with safe bindings
- Use async/await for networking; update UI on the main actor
- Keep components small and reusable; prefer previews for UI iteration

### Game logic notes
- `CodeBreaker` holds the master code, current guess, attempts, and peg palette
- `changeGuessPeg(at:)` cycles the guess pegs through available choices
- `attemptGuess()` records a guess and attaches match markers

## Versioning & Releases

- Use Semantic Versioning: MAJOR.MINOR.PATCH (e.g., 1.2.3)
- Tag releases: `git tag -a v1.0.0 -m "v1.0.0" && git push origin v1.0.0`
- Branching suggestion:
    - `main`: stable
    - `develop` (optional): integration
    - `feature/<ticket>-short-desc` for work
- Cut release branches as needed (e.g., `release/1.1.0`), then tag from there

## Future Work Ideas
- Add emoji-based pegs alongside colors
- Build out financial chronicle flows and persistence
- Add haptics/animations to CodeBreaker interactions
- Introduce theming (light/dark previews)

## License

[Add your license here]

## Contact

[Add your contact information or team details]
