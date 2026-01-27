# AGENTS.md

## 1. Project Context

This is a **native iOS application** built with **SwiftUI** for financial chronicle tracking and code-breaking game functionality.

* **UI Framework:** SwiftUI (declarative UI)
* **Language:** Swift 5.7+
* **Architecture:** MVVM (Model-View-ViewModel) with SwiftUI
* **Target Platform:** iOS 15.0+
* **Features:** 
  * CodeBreaker game with color peg matching
  * Match Markers functionality
  * Financial chronicle tracking (in development)

## 2. Technology Stack

* **Language:** Swift 5.7+
* **UI Framework:** SwiftUI (iOS 15.0+)
* **IDE:** Xcode 15.0+
* **Deployment Target:** iOS 15.0+
* **Architecture Pattern:** MVVM (Model-View-ViewModel)
* **State Management:** 
  * `@State`, `@StateObject`, `@ObservedObject` (SwiftUI)
  * `ObservableObject` protocol for view models
* **Data Persistence:**
  * UserDefaults (Simple key-value storage)
  * CoreData (Relational database - when needed)
  * Keychain (Secure storage for sensitive data)
* **Networking:** URLSession with async/await
* **Testing:**
  * XCTest (Unit testing)
  * XCUITest (UI testing)
* **Version Control:** Git + GitHub
* **Dependency Management:** Swift Package Manager (SPM)

## 3. Project Architecture & Structure

We use **MVVM (Model-View-ViewModel)** architecture with SwiftUI's declarative paradigm.

### Project Structure

```
FinChronicle/
├── FinChronicle/
│   ├── FinChronicleApp.swift        # App entry point
│   ├── Models/                      # Data models
│   │   ├── CodeBreaker.swift       # CodeBreaker game logic
│   │   └── MatchMarkers.swift      # Match markers logic
│   ├── Views/                       # SwiftUI Views
│   │   ├── CodeBreakerView.swift   # CodeBreaker UI
│   │   └── FinChronicleViews/
│   │       └── FinChronicleMainView.swift
│   ├── ViewModels/                  # View models (to be added)
│   ├── Services/                    # Business logic services
│   ├── Utilities/                   # Helper functions & extensions
│   ├── Resources/                   # Assets, strings, configs
│   │   └── Assets.xcassets/        # Images, colors, icons
│   └── Info.plist                   # App configuration
├── FinChronicleTests/               # Unit tests
│   └── FinChronicleTests.swift
├── FinChronicleUITests/             # UI tests
│   ├── FinChronicleUITests.swift
│   └── FinChronicleUITestsLaunchTests.swift
├── FinChronicle.xcodeproj/          # Xcode project
├── .gitignore                       # Git ignore rules
├── README.md                        # Project documentation
└── AGENTS.md                        # Development guidelines (this file)
```

### MVVM Pattern

```
┌─────────┐         ┌──────────────┐         ┌───────┐
│  View   │────────>│  ViewModel   │────────>│ Model │
│ (SwiftUI)│<────────│(ObservableObject)│<────────│ (Data)│
└─────────┘         └──────────────┘         └───────┘
    │                       │
    │                       │
 @State              @Published
 @ObservedObject
```

* **Model:** Pure Swift data structures (struct/class)
* **View:** SwiftUI views (declarative UI)
* **ViewModel:** `ObservableObject` classes with `@Published` properties

### File Naming Conventions

* **Models:** `[Entity].swift` (e.g., `CodeBreaker.swift`, `User.swift`)
* **Views:** `[Feature]View.swift` (e.g., `CodeBreakerView.swift`, `LoginView.swift`)
* **ViewModels:** `[Feature]ViewModel.swift` (e.g., `CodeBreakerViewModel.swift`)
* **Services:** `[Purpose]Service.swift` (e.g., `NetworkService.swift`, `AuthService.swift`)
* **Extensions:** `[Type]+[Purpose].swift` (e.g., `String+Validation.swift`, `Color+Theme.swift`)
* **Tests:** `[Feature]Tests.swift` (e.g., `CodeBreakerTests.swift`)

## 4. Coding Rules & Swift Best Practices

### A. SwiftUI View Design

* **Keep Views Small:** Break large views into smaller, reusable components
* **Extract Subviews:** Use `@ViewBuilder` for complex layouts
* **Use Computed Properties:** For derived state and conditional views
* **Naming:** Views should end with `View` suffix (e.g., `CodeBreakerView`)

```swift
// ✅ Good: Small, focused view
struct GameBoardView: View {
    var body: some View {
        VStack {
            HeaderView()
            PegGridView()
            ActionButtonsView()
        }
    }
}

// ❌ Bad: Monolithic view with too much logic
struct GameView: View {
    var body: some View {
        VStack {
            // 200+ lines of UI code
        }
    }
}
```

* **FORBIDDEN:**
  * Do NOT put business logic directly in views
  * Do NOT make network calls from views
  * Do NOT create massive 500+ line view files

### B. State Management

**Local State (`@State`):**
* Use for simple, view-local state
* Always mark as `private`
* Primitive types and simple structs only

```swift
@State private var isGameActive = false
@State private var selectedPeg: Peg = .red
```

**Observable Objects (`@StateObject`, `@ObservedObject`):**
* `@StateObject`: View owns the object (creates it)
* `@ObservedObject`: View receives the object (passed in)
* Use for complex state and business logic

```swift
class CodeBreakerViewModel: ObservableObject {
    @Published var attempts: [Code] = []
    @Published var isGameWon = false
    
    func submitGuess() {
        // Business logic here
    }
}

struct CodeBreakerView: View {
    @StateObject private var viewModel = CodeBreakerViewModel()
    
    var body: some View {
        // Use viewModel.attempts, viewModel.submitGuess()
    }
}
```

**Environment Objects (`@EnvironmentObject`):**
* Use for app-wide shared state
* User session, theme, settings

```swift
class AppState: ObservableObject {
    @Published var isLoggedIn = false
    @Published var currentUser: User?
}

// In App:
@main
struct FinChronicleApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}
```

* **FORBIDDEN:**
  * Do NOT use `@State` for complex objects
  * Do NOT mutate `@ObservedObject` in subviews (pass callbacks)
  * Do NOT create multiple `@StateObject` instances of the same ViewModel

### C. Models & Data Types

**Use Structs for Models:**
```swift
struct User: Codable, Identifiable {
    let id: UUID
    var name: String
    var email: String
}

struct Code {
    var kind: Kind
    var pegs: [Peg]
    
    enum Kind: Equatable {
        case master
        case guess
        case attempt(Match)
    }
}
```

**Use Classes for ViewModels:**
```swift
class CodeBreakerViewModel: ObservableObject {
    @Published var game: CodeBreaker
    @Published var message: String = ""
    
    init() {
        self.game = CodeBreaker()
    }
}
```

**Type Aliases for Clarity:**
```swift
typealias Peg = Color  // Makes intent clear
typealias UserID = UUID
```

* **FORBIDDEN:**
  * Do NOT use classes for data models (use structs)
  * Do NOT make models inherit from `NSObject` unless necessary
  * Do NOT use `Any` or `AnyObject` without strong justification

### D. Naming Conventions

**Variables & Properties:**
* Use `lowerCamelCase`
* Be descriptive, avoid abbreviations
* Boolean properties: Use `is`, `has`, `should` prefix

```swift
// ✅ Good
var isGameActive: Bool
var currentAttempt: Code
var hasWonGame: Bool

// ❌ Bad
var active: Bool
var att: Code
var won: Bool
```

**Functions & Methods:**
* Use `lowerCamelCase`
* Start with verb (action-oriented)
* Be specific about what it does

```swift
// ✅ Good
func submitGuess()
func validateUserInput()
func fetchUserProfile()

// ❌ Bad
func guess()
func check()
func get()
```

**Types (Classes, Structs, Enums):**
* Use `UpperCamelCase`
* Singular nouns
* Descriptive names

```swift
// ✅ Good
struct CodeBreaker { }
class UserViewModel { }
enum GameState { }

// ❌ Bad
struct code_breaker { }
class VM { }
enum state { }
```

**Constants:**
* Use `lowerCamelCase` for regular constants
* Group related constants in enums

```swift
// ✅ Good
let maxAttempts = 10
let defaultPegColor = Color.red

enum GameConstants {
    static let maxAttempts = 10
    static let pegCount = 4
}

// ❌ Bad
let MAX_ATTEMPTS = 10
let DEFAULTPEGCOLOR = Color.red
```

### E. Error Handling

**Use Swift's Error Protocol:**
```swift
enum NetworkError: Error {
    case invalidURL
    case noInternetConnection
    case serverError(Int)
}

func fetchData() async throws -> Data {
    guard let url = URL(string: urlString) else {
        throw NetworkError.invalidURL
    }
    // ... fetch logic
}
```

**Handle Errors Gracefully:**
```swift
// ✅ Good: Proper error handling
func loadUserProfile() {
    Task {
        do {
            let profile = try await service.fetchProfile()
            self.user = profile
        } catch NetworkError.noInternetConnection {
            self.errorMessage = "No internet connection"
        } catch {
            self.errorMessage = "Failed to load profile: \(error.localizedDescription)"
        }
    }
}

// ❌ Bad: Silent failures
func loadUserProfile() {
    Task {
        let profile = try? await service.fetchProfile()
        self.user = profile  // nil on error, no feedback to user
    }
}
```

* **FORBIDDEN:**
  * Do NOT use `try!` in production code (use `try?` or proper `do-catch`)
  * Do NOT swallow errors without logging or user feedback
  * Do NOT use force unwrapping (`!`) without justification

### F. Optionals & Safety

**Prefer Optional Binding:**
```swift
// ✅ Good
if let user = currentUser {
    print("Welcome, \(user.name)")
}

guard let email = user.email else {
    return
}

// ❌ Bad
if currentUser != nil {
    print("Welcome, \(currentUser!.name)")  // Force unwrap!
}
```

**Use Nil Coalescing:**
```swift
// ✅ Good
let username = user?.name ?? "Guest"
let itemCount = cart.items.count.description

// ❌ Bad
let username = user != nil ? user!.name : "Guest"
```

**Optional Chaining:**
```swift
// ✅ Good
let firstItemName = cart.items.first?.name ?? "No items"

// ❌ Bad
let firstItemName = cart.items.count > 0 ? cart.items[0].name : "No items"
```

* **FORBIDDEN:**
  * Do NOT use force unwrapping (`!`) except in tests or truly guaranteed scenarios
  * Do NOT use implicitly unwrapped optionals (`!`) for regular properties
  * Do NOT nest multiple optional bindings excessively (extract functions)

### G. Code Organization & Comments

**File Structure:**
```swift
// 1. Imports
import SwiftUI
import Combine

// 2. Main Type Definition
struct CodeBreakerView: View {
    // 3. Properties
    @StateObject private var viewModel = CodeBreakerViewModel()
    @State private var showAlert = false
    
    // 4. Body
    var body: some View {
        VStack {
            // UI code
        }
    }
    
    // 5. Private Helper Views
    private var headerView: some View {
        Text("Code Breaker")
    }
    
    // 6. Private Methods
    private func handleSubmit() {
        // Logic
    }
}

// 7. Preview
#Preview {
    CodeBreakerView()
}
```

**Comments:**
* Use `//` for single-line comments
* Use `/// ` for documentation comments
* Add MARK comments for organization

```swift
// MARK: - Properties
@Published var attempts: [Code] = []

// MARK: - Public Methods
/// Submits the current guess and checks against master code
func submitGuess() {
    // Implementation
}

// MARK: - Private Helpers
private func validateGuess() -> Bool {
    // Implementation
}
```

* **FORBIDDEN:**
  * Do NOT write obvious comments (`// Set name to "John"`)
  * Do NOT leave commented-out code in commits
  * Do NOT write novels - keep comments concise

### H. Async/Await & Concurrency

**Use Modern Swift Concurrency:**
```swift
// ✅ Good: async/await
func fetchUserData() async throws -> User {
    let (data, _) = try await URLSession.shared.data(from: url)
    let user = try JSONDecoder().decode(User.self, from: data)
    return user
}

// Call from SwiftUI:
Button("Load Data") {
    Task {
        do {
            let user = try await viewModel.fetchUserData()
            self.currentUser = user
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
```

**Use MainActor for UI Updates:**
```swift
@MainActor
class UserViewModel: ObservableObject {
    @Published var user: User?
    
    func loadUser() async {
        // This runs on main thread automatically
        user = try? await service.fetchUser()
    }
}
```

* **FORBIDDEN:**
  * Do NOT use completion handlers for new code (use async/await)
  * Do NOT update UI from background threads
  * Do NOT block the main thread with synchronous network calls

## 5. Networking & API Integration

### URLSession with Async/Await

**Basic GET Request:**
```swift
struct NetworkService {
    func fetchData<T: Decodable>(from url: URL) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}
```

**POST Request with JSON Body:**
```swift
func postData<T: Encodable, R: Decodable>(
    to url: URL,
    body: T
) async throws -> R {
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONEncoder().encode(body)
    
    let (data, _) = try await URLSession.shared.data(for: request)
    return try JSONDecoder().decode(R.self, from: data)
}
```

**In ViewModel:**
```swift
class UserViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let service = NetworkService()
    
    @MainActor
    func loadUsers() async {
        isLoading = true
        errorMessage = nil
        
        do {
            users = try await service.fetchData(
                from: URL(string: "https://api.example.com/users")!
            )
        } catch {
            errorMessage = "Failed to load users: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
```

### Error Handling

```swift
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noInternetConnection
    case serverError
    case decodingError
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noInternetConnection:
            return "No internet connection"
        case .serverError:
            return "Server error occurred"
        case .decodingError:
            return "Failed to parse response"
        case .unauthorized:
            return "Unauthorized access"
        }
    }
}
```

* **FORBIDDEN:**
  * Do NOT use third-party networking libraries unless absolutely necessary
  * Do NOT make synchronous network calls
  * Do NOT ignore error responses

## 6. Data Persistence

### UserDefaults (Simple Data)

```swift
extension UserDefaults {
    private enum Keys {
        static let isFirstLaunch = "isFirstLaunch"
        static let userName = "userName"
    }
    
    var isFirstLaunch: Bool {
        get { bool(forKey: Keys.isFirstLaunch) }
        set { set(newValue, forKey: Keys.isFirstLaunch) }
    }
    
    var userName: String? {
        get { string(forKey: Keys.userName) }
        set { set(newValue, forKey: Keys.userName) }
    }
}
```

### Keychain (Secure Data)

```swift
import Security

class KeychainService {
    func save(_ data: Data, forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed
        }
    }
    
    func retrieve(forKey key: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data else {
            throw KeychainError.retrieveFailed
        }
        
        return data
    }
}
```

### CoreData (Relational Data - When Needed)

* Use for complex data relationships
* Create data model in Xcode (.xcdatamodeld)
* Generate NSManagedObject subclasses
* Access via persistent container

```swift
class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "FinChronicle")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
}
```

* **FORBIDDEN:**
  * Do NOT store sensitive data in UserDefaults
  * Do NOT use CoreData for simple key-value storage
  * Do NOT forget to handle migration when changing data models

## 7. Testing

### Unit Tests (XCTest)

```swift
import XCTest
@testable import FinChronicle

final class CodeBreakerTests: XCTestCase {
    var game: CodeBreaker!
    
    override func setUp() {
        super.setUp()
        game = CodeBreaker(pegChoices: [.red, .blue, .green, .yellow])
    }
    
    override func tearDown() {
        game = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertEqual(game.attempts.count, 0)
        XCTAssertEqual(game.guess.pegs.count, 4)
    }
    
    func testAttemptGuess() {
        let initialCount = game.attempts.count
        game.attemptGuess()
        XCTAssertEqual(game.attempts.count, initialCount + 1)
    }
    
    func testPerfectMatch() {
        game.guess.pegs = game.masterCode.pegs
        let match = game.guess.match(against: game.masterCode)
        XCTAssertEqual(match.perfect, 4)
        XCTAssertEqual(match.partial, 0)
    }
}
```

### UI Tests (XCUITest)

```swift
import XCUITest

final class CodeBreakerUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launch()
    }
    
    func testGameLaunch() {
        XCTAssertTrue(app.staticTexts["Code Breaker"].exists)
    }
    
    func testSubmitButton() {
        let submitButton = app.buttons["Submit Guess"]
        XCTAssertTrue(submitButton.exists)
        submitButton.tap()
        
        // Verify attempt was added
        XCTAssertTrue(app.staticTexts["Attempt 1"].exists)
    }
}
```

**Running Tests:**
* Unit tests: ⌘ + U
* Single test: Click diamond next to test method
* Test coverage: Enable in scheme > Test > Options > Code Coverage

* **FORBIDDEN:**
  * Do NOT skip tests for critical functionality
  * Do NOT write tests that depend on external services (mock them)
  * Do NOT commit failing tests

## 8. Dependency Management

### Swift Package Manager (SPM)

**Adding a Package:**
1. File > Add Package Dependencies...
2. Enter package URL (e.g., `https://github.com/...`)
3. Select version/branch
4. Add to target

**Common Packages:**
```swift
// Example: Alamofire (if networking beyond URLSession is needed)
dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0")
]
```

**In Code:**
```swift
import Alamofire  // If added
```

### Before Adding Dependencies

**MUST follow this process:**

1. **Evaluate Need:**
   * Can this be done with native iOS frameworks?
   * Is this dependency actively maintained?
   * What's the package size?

2. **Research Alternatives:**
   * Compare at least 2-3 options
   * Check GitHub stars, issues, last update
   * Review documentation quality

3. **Ask User for Approval:**
   > "To implement [Feature], I found these Swift packages:
   > 1. **Package A:** [Pros/Cons]
   > 2. **Package B:** [Pros/Cons]
   >
   > I recommend **Package A** because [Reason].
   > Shall I proceed with adding it?"

* **FORBIDDEN:**
  * Do NOT add packages without user approval
  * Do NOT use unmaintained or abandoned packages
  * Do NOT add packages for trivial functionality

## 9. Build & Deployment

### Development Build

**Run in Simulator:**
1. Select simulator: iPhone 15 / iPad Air, etc.
2. Press ⌘ + R (or Product > Run)

**Run on Device:**
1. Connect iPhone/iPad
2. Select device from target dropdown
3. Sign in Xcode: Settings > Accounts > Add Apple ID
4. Select team in project settings > Signing & Capabilities
5. Press ⌘ + R

### Production Build

**Archive for App Store:**
1. Select "Any iOS Device" as target
2. Product > Archive
3. Wait for archive to complete
4. Organizer opens automatically
5. Click "Distribute App"
6. Select App Store Connect
7. Follow upload wizard

**TestFlight Beta:**
1. Upload build to App Store Connect
2. Provide export compliance info
3. Add to TestFlight
4. Invite testers via email

**Build Configuration:**
* Debug: Development builds with debug symbols
* Release: Optimized builds for distribution

* **FORBIDDEN:**
  * Do NOT distribute debug builds to users
  * Do NOT commit provisioning profiles
  * Do NOT share signing certificates publicly

## 10. Git Workflow & Best Practices

### Branch Strategy

* **Main Branches:**
  * `main` - Production-ready code
  * `develop` - Development branch (optional)

* **Feature Branches:**
  * Format: `feature/[ticket-id]-short-description`
  * Example: `feature/FC-123-add-financial-tracking`

* **Bugfix Branches:**
  * Format: `bugfix/[ticket-id]-short-description`
  * Example: `bugfix/FC-456-fix-peg-color-selection`

### Commit Messages

**Format:** `[TICKET-ID] Brief description`

**Examples:**
* `[FC-123] Add financial transaction model`
* `[FC-456] Fix color picker crash on iPad`
* `[FC-789] Improve CodeBreaker performance`

**Good Commit:** Clear, concise, explains "what" and "why"  
**Bad Commit:** `fix bug`, `update code`, `wip`

### Pull Request Process

1. Create feature/bugfix branch from `main`
2. Make changes following coding guidelines
3. Write/update tests
4. Run tests (⌘ + U) to ensure they pass
5. Create PR with clear description
6. Request code review
7. Address review comments
8. Merge after approval

* **FORBIDDEN:**
  * Do NOT commit directly to `main`
  * Do NOT merge without testing
  * Do NOT commit sensitive data or keys

## 11. Common Pitfalls & Best Practices

### Pitfalls to Avoid

1. **Force Unwrapping:** Always use optional binding or nil coalescing
2. **Retain Cycles:** Use `[weak self]` in closures that capture `self`
3. **UI on Background Thread:** Always update UI on main thread (`@MainActor`)
4. **Massive Views:** Break down into smaller components
5. **Business Logic in Views:** Move to ViewModels
6. **Hardcoded Strings:** Use localization for user-facing text
7. **Missing Error Handling:** Always handle errors gracefully
8. **No Tests:** Write tests for critical functionality
9. **Ignoring Warnings:** Fix Xcode warnings before committing
10. **Memory Leaks:** Profile with Instruments to detect leaks

### Best Practices

1. **SwiftUI Previews:** Use `#Preview` for rapid UI iteration
2. **Accessibility:** Add `.accessibilityLabel()` to interactive elements
3. **Dark Mode:** Test both light and dark appearances
4. **Different Devices:** Test on iPhone and iPad (when applicable)
5. **Performance:** Use `LazyVStack`/`LazyHStack` for long lists
6. **Reusability:** Create reusable components in `Utilities/`
7. **Type Safety:** Leverage Swift's strong type system
8. **Documentation:** Add documentation comments for public APIs
9. **Code Review:** Review your own code before submitting PR
10. **Consistency:** Follow Swift API Design Guidelines

## 12. Key Files & Resources

### Critical Files

* **App Entry:** `FinChronicleApp.swift` - App lifecycle and scene configuration
* **Info.plist:** App configuration, permissions, capabilities
* **.gitignore:** Git ignore patterns (already created)
* **README.md:** Project documentation (already created)

### Configuration Files

* **Xcode Project:** `FinChronicle.xcodeproj/project.pbxproj`
* **Swift Lint:** `.swiftlint.yml` - Code quality rules (already created)

### Apple Documentation

* **SwiftUI:** https://developer.apple.com/documentation/swiftui/
* **Swift Language:** https://docs.swift.org/swift-book/
* **Human Interface Guidelines:** https://developer.apple.com/design/human-interface-guidelines/
* **Xcode:** https://developer.apple.com/xcode/

### Learning Resources

* **SwiftUI Tutorials:** https://developer.apple.com/tutorials/swiftui
* **Swift Playgrounds:** Interactive learning
* **WWDC Videos:** https://developer.apple.com/videos/
* **Hacking with Swift:** https://www.hackingwithswift.com/

---

## Summary

This AGENTS.md provides comprehensive guidelines for developing FinChronicle iOS app. Key principles:

1. **MVVM Architecture:** Clean separation of concerns with ViewModels
2. **SwiftUI:** Declarative UI with modern Swift syntax
3. **Type Safety:** Leverage Swift's strong type system
4. **State Management:** Use appropriate property wrappers (@State, @StateObject, etc.)
5. **Async/Await:** Modern concurrency for network calls
6. **Testing:** XCTest for unit tests, XCUITest for UI tests
7. **Code Quality:** Follow Swift naming conventions and best practices
8. **Security:** Use Keychain for sensitive data
9. **Performance:** Optimize rendering, use lazy loading for lists
10. **Consistency:** Follow existing patterns in the codebase

**When in doubt, follow Apple's Swift API Design Guidelines and existing patterns in the codebase. Consistency and clarity are paramount.**
