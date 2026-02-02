# FinChronicle Architecture Analysis

## Executive Summary

**Current Architecture:** **Hybrid Model-View (MV) with some MVVM tendencies**  
**Clean Architecture Compliance:** ❌ **NOT following Clean Architecture**  
**Recommendation:** 🟡 **Refactor to Clean Architecture for scalability**

---

## Table of Contents

1. [Current State Analysis](#current-state-analysis)
2. [Clean Architecture Principles](#clean-architecture-principles)
3. [Gap Analysis](#gap-analysis)
4. [What You're Doing Right](#what-youre-doing-right)
5. [What Needs to Change](#what-needs-to-change)
6. [Proposed Clean Architecture Structure](#proposed-clean-architecture-structure)
7. [Migration Roadmap](#migration-roadmap)
8. [Code Examples](#code-examples)

---

## 1. Current State Analysis

### Project Structure (As Is)

```
FinChronicle/
├── FinChronicleApp.swift          # App entry point
├── Model/                          # Data models + Business Logic (❌ Mixed concerns)
│   ├── CodeBreaker.swift          # Game state + logic
│   └── Code.swift                 # Data structure + matching logic
├── UI/                            # Views (✅ Good separation)
│   ├── CodeBreakerView.swift     # Main view
│   ├── CodeView.swift
│   ├── MatchMarkers.swift
│   └── PegsView.swift
└── FinChronicleViews/
    └── FinChronicleMainView.swift
```

### Current Architecture Pattern

**Pattern:** **Model-View (MV)** - NOT Clean Architecture, NOT fully MVVM

```
┌─────────────────┐
│  SwiftUI Views  │ ← Directly uses @State with business logic models
│                 │
│ CodeBreakerView │
└────────┬────────┘
         │
         │ @State private var game: CodeBreaker
         ↓
┌────────────────┐
│  CodeBreaker   │ ← MODEL + BUSINESS LOGIC (❌ Violation)
│   (Model)      │   • Game state
│                │   • Game rules
└────────────────┘   • Matching algorithm
```

### Key Issues Identified

#### ❌ **Issue 1: Business Logic in Models**

**File:** `CodeBreaker.swift`
```swift
struct CodeBreaker {
    var masterCode: Code
    var guess: Code
    var attempts: [Code] = []
    
    // ❌ Business logic mixed with data model
    mutating func attemptGuess() { ... }
    mutating func setGuessPeg(_ peg: Peg, at index: Int) { ... }
    mutating func changeGuessPeg(at index:Int) { ... }
    
    // ❌ Game state logic
    var isOver: Bool {
        attempts.last?.pegs == masterCode.pegs
    }
}
```

**Problem:** The `CodeBreaker` struct is acting as both:
- **Data Model** (masterCode, guess, attempts)
- **Use Case / Interactor** (attemptGuess, setGuessPeg, isOver)

#### ❌ **Issue 2: Views Directly Manipulating State**

**File:** `CodeBreakerView.swift`
```swift
struct CodeBreakerView: View {
    @State private var game: CodeBreaker = CodeBreaker(...)
    
    var body: some View {
        Button("Guess") {
            withAnimation {
                game.attemptGuess()  // ❌ Direct business logic call
                selection = 0
            }
        }
    }
}
```

**Problem:** View directly handles business logic - no separation of concerns.

#### ❌ **Issue 3: No Dependency Injection**

- Hard-coded dependencies
- No protocols/interfaces
- Cannot test in isolation
- Tightly coupled components

#### ❌ **Issue 4: No Clear Layers**

Missing layers:
- ❌ **Presentation Layer** (No ViewModels)
- ❌ **Domain Layer** (Business logic mixed in models)
- ❌ **Data Layer** (No repositories, no persistence)
- ❌ **Dependency Inversion** (No protocols)

---

## 2. Clean Architecture Principles

### The Clean Architecture Diagram

```
┌──────────────────────────────────────────────────────────┐
│                    🎨 Presentation Layer                  │
│   ┌────────────┐          ┌──────────────┐              │
│   │   Views    │ ────────>│  ViewModels  │              │
│   │  (SwiftUI) │          │ (Presenters) │              │
│   └────────────┘          └───────┬──────┘              │
│                                    │                      │
└────────────────────────────────────┼──────────────────────┘
                                     │ Dependency Rule
                                     ↓ (Inward only)
┌────────────────────────────────────────────────────────────┐
│                    📦 Domain Layer (Core)                   │
│   ┌─────────────┐    ┌──────────────┐   ┌──────────────┐ │
│   │  Entities   │    │  Use Cases   │   │  Protocols   │ │
│   │  (Models)   │    │ (Interactors)│   │ (Interfaces) │ │
│   └─────────────┘    └──────────────┘   └──────────────┘ │
│                                                             │
└────────────────────────────┬────────────────────────────────┘
                             │ Dependency Inversion
                             ↓
┌────────────────────────────────────────────────────────────┐
│                    💾 Data Layer                            │
│   ┌──────────────┐    ┌───────────────┐   ┌────────────┐ │
│   │ Repositories │    │  Data Sources │   │   Models   │ │
│   │(Implementers)│    │(API/Database) │   │    (DTOs)  │ │
│   └──────────────┘    └───────────────┘   └────────────┘ │
└────────────────────────────────────────────────────────────┘
```

### Core Principles

#### 1️⃣ **Separation of Concerns**
Each layer has ONE responsibility:
- **Presentation:** Display & user interaction
- **Domain:** Business logic & rules
- **Data:** Data access & persistence

#### 2️⃣ **Dependency Rule**
Dependencies point **INWARD** only:
```
Presentation → Domain ← Data
```
- Domain layer is **independent** (no imports of UI or Data)
- Outer layers depend on inner layers
- Inner layers know nothing about outer layers

#### 3️⃣ **Dependency Inversion**
Use **protocols** (interfaces) to invert dependencies:
```swift
// Domain Layer defines WHAT it needs
protocol GameRepository {
    func saveGame(_ game: GameEntity) async throws
    func loadGame() async throws -> GameEntity?
}

// Data Layer implements HOW
class LocalGameRepository: GameRepository {
    func saveGame(_ game: GameEntity) async throws { ... }
    func loadGame() async throws -> GameEntity? { ... }
}
```

#### 4️⃣ **Testability**
All layers can be tested in isolation with mocks/stubs.

---

## 3. Gap Analysis

### Comparison Matrix

| Clean Architecture Layer | Current State | Status | Gap |
|-------------------------|---------------|--------|-----|
| **Presentation Layer** | | | |
| - Views | ✅ SwiftUI Views exist | ✅ Good | None |
| - ViewModels | ❌ Missing | ❌ Critical | Need to create |
| - View State | @State in Views | 🟡 Partial | Move to ViewModels |
| **Domain Layer** | | | |
| - Entities | ✅ `Code`, `Match` | ✅ Good | Clean up |
| - Use Cases | ❌ Mixed in models | ❌ Critical | Extract to Use Cases |
| - Repository Protocols | ❌ Missing | ❌ High | Need to create |
| **Data Layer** | | | |
| - Repositories | ❌ Missing | 🟡 Medium | Add for persistence |
| - Data Sources | ❌ Missing | 🟡 Medium | Add later |
| - DTOs | N/A | N/A | Not needed yet |
| **Dependency Injection** | ❌ Missing | ❌ High | Implement DI |

### Severity Levels

- ✅ **Good:** Meets Clean Architecture standards
- 🟡 **Partial:** Partially implemented, needs refinement
- ❌ **Critical:** Major violation, needs immediate attention
- ❌ **High:** Important for scalability
- ❌ **Medium:** Nice to have, add as needed

---

## 4. What You're Doing Right ✅

Despite not following Clean Architecture, there are several **good practices**:

### ✅ **1. Model Separation**

You've separated data models into a dedicated folder:
```swift
struct Code {
    var kind: Kind
    var pegs: [Peg]
    // Pure data structure
}

enum Match {
    case exact, inexact, nomatch
}
```

**Good:** Clean, well-defined data structures.

### ✅ **2. View Decomposition**

You've broken down views into smaller components:
```
UI/
├── CodeBreakerView.swift    # Main container
├── CodeView.swift           # Reusable code display
├── PegsView.swift           # Peg rendering
└── MatchMarkers.swift       # Match indicators
```

**Good:** Small, focused, reusable views (following SwiftUI best practices).

### ✅ **3. Type Aliases for Clarity**

```swift
typealias Peg = Color
```

**Good:** Makes domain concepts explicit.

### ✅ **4. Struct-Based Models**

Using `struct` for value types:
```swift
struct Code { ... }
struct CodeBreaker { ... }
```

**Good:** Immutability by default, value semantics.

### ✅ **5. Separation of Presentation Logic**

Views focus on layout, not business logic implementation:
```swift
var pegChooser: some View {
    HStack {
        ForEach(game.pegChoices, id: \.self) { peg in
            Button { game.setGuessPeg(peg, at: selection) }
                label: { PegsView(peg: peg) }
        }
    }
}
```

**Good:** Declarative UI, not imperative.

### ✅ **6. Enums for State Modeling**

```swift
enum Kind: Equatable {
    case master(isHidden: Bool)
    case guess
    case attempt([Match])
}
```

**Good:** Type-safe state representation.

---

## 5. What Needs to Change ❌

### Critical Changes (Must Have)

#### ❌ **1. Extract Business Logic to Use Cases**

**Current:**
```swift
// CodeBreaker.swift (Model + Logic)
struct CodeBreaker {
    mutating func attemptGuess() { ... }  // ❌ Business logic
    var isOver: Bool { ... }              // ❌ Business logic
}
```

**Should Be:**
```swift
// Domain/Entities/GameEntity.swift
struct GameEntity {
    var masterCode: Code
    var guess: Code
    var attempts: [Code]
    // Pure data only
}

// Domain/UseCases/AttemptGuessUseCase.swift
struct AttemptGuessUseCase {
    func execute(game: GameEntity, guess: Code) -> GameEntity {
        // Business logic here
    }
}

// Domain/UseCases/CheckGameOverUseCase.swift
struct CheckGameOverUseCase {
    func execute(game: GameEntity) -> Bool {
        game.attempts.last?.pegs == game.masterCode.pegs
    }
}
```

#### ❌ **2. Introduce ViewModels**

**Current:**
```swift
// CodeBreakerView.swift
struct CodeBreakerView: View {
    @State private var game: CodeBreaker = CodeBreaker()  // ❌ Direct model
    
    var body: some View {
        Button("Guess") {
            game.attemptGuess()  // ❌ Direct business logic
        }
    }
}
```

**Should Be:**
```swift
// Presentation/ViewModels/CodeBreakerViewModel.swift
@MainActor
class CodeBreakerViewModel: ObservableObject {
    @Published var game: GameEntity
    @Published var isGameOver: Bool = false
    @Published var selection: Int = 0
    
    private let attemptGuessUseCase: AttemptGuessUseCase
    private let checkGameOverUseCase: CheckGameOverUseCase
    
    init(
        attemptGuessUseCase: AttemptGuessUseCase = AttemptGuessUseCase(),
        checkGameOverUseCase: CheckGameOverUseCase = CheckGameOverUseCase()
    ) {
        self.attemptGuessUseCase = attemptGuessUseCase
        self.checkGameOverUseCase = checkGameOverUseCase
        self.game = GameEntity(pegChoices: [.red, .blue, .green, .yellow])
    }
    
    func submitGuess() {
        game = attemptGuessUseCase.execute(game: game, guess: game.guess)
        isGameOver = checkGameOverUseCase.execute(game: game)
        selection = 0
    }
    
    func selectPeg(_ peg: Peg) {
        game.guess.pegs[selection] = peg
        selection = (selection + 1) % game.masterCode.pegs.count
    }
}

// Presentation/Views/CodeBreakerView.swift
struct CodeBreakerView: View {
    @StateObject private var viewModel = CodeBreakerViewModel()
    
    var body: some View {
        Button("Guess") {
            viewModel.submitGuess()  // ✅ ViewModel handles logic
        }
    }
}
```

#### ❌ **3. Implement Dependency Injection**

**Current:** Hard-coded dependencies
```swift
@State private var game: CodeBreaker = CodeBreaker()  // ❌ Hard-coded
```

**Should Be:**
```swift
// App/DIContainer.swift
class DIContainer {
    // Use Cases
    lazy var attemptGuessUseCase = AttemptGuessUseCase()
    lazy var checkGameOverUseCase = CheckGameOverUseCase()
    lazy var saveGameUseCase = SaveGameUseCase(repository: gameRepository)
    
    // Repositories
    lazy var gameRepository: GameRepository = LocalGameRepository()
    
    // ViewModels
    func makeCodeBreakerViewModel() -> CodeBreakerViewModel {
        CodeBreakerViewModel(
            attemptGuessUseCase: attemptGuessUseCase,
            checkGameOverUseCase: checkGameOverUseCase
        )
    }
}

// FinChronicleApp.swift
@main
struct FinChronicleApp: App {
    let container = DIContainer()
    
    var body: some Scene {
        WindowGroup {
            CodeBreakerView(
                viewModel: container.makeCodeBreakerViewModel()
            )
        }
    }
}
```

### High Priority Changes

#### ❌ **4. Define Repository Protocols**

```swift
// Domain/Protocols/GameRepository.swift
protocol GameRepository {
    func saveGame(_ game: GameEntity) async throws
    func loadGame() async throws -> GameEntity?
    func deleteGame() async throws
}

// Data/Repositories/LocalGameRepository.swift
class LocalGameRepository: GameRepository {
    func saveGame(_ game: GameEntity) async throws {
        // UserDefaults or CoreData implementation
    }
    
    func loadGame() async throws -> GameEntity? {
        // Load from storage
    }
    
    func deleteGame() async throws {
        // Delete from storage
    }
}
```

#### ❌ **5. Create Layer-Specific Models**

```swift
// Domain/Entities/GameEntity.swift
struct GameEntity {
    let id: UUID
    var masterCode: Code
    var guess: Code
    var attempts: [Code]
    var createdAt: Date
}

// Data/Models/GameDTO.swift (Data Transfer Object)
struct GameDTO: Codable {
    let id: String
    let masterCode: CodeDTO
    let guess: CodeDTO
    let attempts: [CodeDTO]
    let createdAt: Date
    
    func toDomain() -> GameEntity {
        // Convert DTO to Entity
    }
}
```

### Medium Priority (Future Enhancements)

#### 🟡 **6. Add Use Case Protocols**

```swift
// Domain/Protocols/UseCase.swift
protocol UseCase {
    associatedtype Input
    associatedtype Output
    
    func execute(_ input: Input) async throws -> Output
}

// Domain/UseCases/AttemptGuessUseCase.swift
struct AttemptGuessUseCase: UseCase {
    typealias Input = (game: GameEntity, guess: Code)
    typealias Output = GameEntity
    
    func execute(_ input: Input) async throws -> Output {
        // Implementation
    }
}
```

#### 🟡 **7. Implement Error Handling**

```swift
// Domain/Errors/GameError.swift
enum GameError: Error, LocalizedError {
    case invalidGuess
    case gameAlreadyOver
    case saveFailed
    case loadFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidGuess: return "Invalid guess submitted"
        case .gameAlreadyOver: return "Game is already over"
        case .saveFailed: return "Failed to save game"
        case .loadFailed: return "Failed to load game"
        }
    }
}
```

---

## 6. Proposed Clean Architecture Structure

### Target Directory Structure

```
FinChronicle/
├── App/
│   ├── FinChronicleApp.swift       # App entry point
│   └── DIContainer.swift           # Dependency Injection container
│
├── Presentation/                   # 🎨 Presentation Layer
│   ├── Views/
│   │   ├── CodeBreaker/
│   │   │   ├── CodeBreakerView.swift
│   │   │   ├── CodeView.swift
│   │   │   └── PegsView.swift
│   │   └── FinChronicle/
│   │       └── FinChronicleMainView.swift
│   └── ViewModels/
│       ├── CodeBreakerViewModel.swift
│       └── FinChronicleViewModel.swift
│
├── Domain/                         # 📦 Domain Layer (Core Business Logic)
│   ├── Entities/
│   │   ├── GameEntity.swift
│   │   ├── Code.swift
│   │   └── Match.swift
│   ├── UseCases/
│   │   ├── AttemptGuessUseCase.swift
│   │   ├── CheckGameOverUseCase.swift
│   │   ├── SaveGameUseCase.swift
│   │   ├── LoadGameUseCase.swift
│   │   └── ResetGameUseCase.swift
│   ├── Protocols/
│   │   ├── GameRepository.swift
│   │   └── UseCase.swift
│   └── Errors/
│       └── GameError.swift
│
├── Data/                           # 💾 Data Layer
│   ├── Repositories/
│   │   ├── LocalGameRepository.swift
│   │   └── RemoteGameRepository.swift (future)
│   ├── DataSources/
│   │   ├── UserDefaultsDataSource.swift
│   │   └── CoreDataDataSource.swift (future)
│   └── Models/
│       └── GameDTO.swift
│
├── Utilities/                      # 🔧 Shared Utilities
│   ├── Extensions/
│   │   ├── Color+Extensions.swift
│   │   └── Array+Extensions.swift
│   └── Helpers/
│       └── DateFormatter+App.swift
│
└── Resources/                      # 📦 Resources
    ├── Assets.xcassets/
    └── Localization/
```

### Layer Responsibilities

#### 🎨 **Presentation Layer**

**Responsibility:** Display UI and handle user interactions

**Components:**
- **Views:** SwiftUI views (declarative UI)
- **ViewModels:** Presentation logic, state management

**Rules:**
- Views only know about ViewModels
- ViewModels call Use Cases from Domain layer
- No business logic in Views or ViewModels

**Example Flow:**
```
User taps "Guess" Button
    ↓
CodeBreakerView calls viewModel.submitGuess()
    ↓
CodeBreakerViewModel calls attemptGuessUseCase.execute()
    ↓
ViewModel updates @Published properties
    ↓
View automatically re-renders
```

#### 📦 **Domain Layer (Core)**

**Responsibility:** Business logic, rules, and entities

**Components:**
- **Entities:** Core business objects (Code, GameEntity, Match)
- **Use Cases:** Specific business actions (AttemptGuess, CheckGameOver)
- **Protocols:** Interfaces for repositories (dependency inversion)

**Rules:**
- **NO imports** from Presentation or Data layers
- Pure Swift (no UIKit, SwiftUI, CoreData imports)
- Defines protocols, Data layer implements them

**Example:**
```swift
// Domain layer defines WHAT it needs
protocol GameRepository {
    func save(_ game: GameEntity) async throws
}

// Use Case uses the protocol
struct SaveGameUseCase {
    let repository: GameRepository  // Protocol, not concrete type
    
    func execute(_ game: GameEntity) async throws {
        try await repository.save(game)
    }
}
```

#### 💾 **Data Layer**

**Responsibility:** Data access and persistence

**Components:**
- **Repositories:** Implement Domain protocols
- **Data Sources:** Raw data access (UserDefaults, API, Database)
- **DTOs:** Data transfer objects (Codable models)

**Rules:**
- Implements Domain protocols
- Handles data conversion (DTO ↔️ Entity)
- Depends on Domain layer protocols

**Example:**
```swift
// Implements Domain protocol
class LocalGameRepository: GameRepository {
    private let dataSource: UserDefaultsDataSource
    
    func save(_ game: GameEntity) async throws {
        let dto = GameDTO(from: game)  // Convert Entity → DTO
        try await dataSource.save(dto)
    }
    
    func load() async throws -> GameEntity? {
        guard let dto = try await dataSource.load() else { return nil }
        return dto.toDomain()  // Convert DTO → Entity
    }
}
```

---

## 7. Migration Roadmap

### Phase 1: Foundation (Week 1-2) 🏗️

**Goal:** Set up Clean Architecture structure without breaking existing functionality

#### Step 1: Create Directory Structure
```bash
mkdir -p FinChronicle/Domain/Entities
mkdir -p FinChronicle/Domain/UseCases
mkdir -p FinChronicle/Domain/Protocols
mkdir -p FinChronicle/Presentation/ViewModels
mkdir -p FinChronicle/Presentation/Views/CodeBreaker
mkdir -p FinChronicle/Data/Repositories
```

#### Step 2: Extract Entities
1. Rename `CodeBreaker.swift` → `GameEntity.swift`
2. Remove all `mutating func` (business logic)
3. Keep only data properties
4. Move to `Domain/Entities/`

**Before:**
```swift
struct CodeBreaker {
    var masterCode: Code
    var guess: Code
    var attempts: [Code] = []
    
    mutating func attemptGuess() { ... }  // ❌ Remove
    var isOver: Bool { ... }              // ❌ Remove
}
```

**After:**
```swift
// Domain/Entities/GameEntity.swift
struct GameEntity {
    let id: UUID
    var masterCode: Code
    var guess: Code
    var attempts: [Code]
    let pegChoices: [Peg]
    var createdAt: Date
    
    // Pure data structure only
}
```

#### Step 3: Create First Use Case
```swift
// Domain/UseCases/AttemptGuessUseCase.swift
struct AttemptGuessUseCase {
    func execute(game: inout GameEntity) {
        var attempt = game.guess
        let match = game.guess.match(against: game.masterCode)
        attempt.kind = .attempt(match)
        game.attempts.append(attempt)
        game.guess.reset()
        
        if game.attempts.last?.pegs == game.masterCode.pegs {
            game.masterCode.kind = .master(isHidden: false)
        }
    }
}
```

#### Step 4: Create First ViewModel
```swift
// Presentation/ViewModels/CodeBreakerViewModel.swift
@MainActor
class CodeBreakerViewModel: ObservableObject {
    @Published var game: GameEntity
    @Published var selection: Int = 0
    
    private let attemptGuessUseCase = AttemptGuessUseCase()
    
    init() {
        self.game = GameEntity(
            id: UUID(),
            pegChoices: [.blue, .green, .yellow, .orange],
            createdAt: Date()
        )
    }
    
    var isGameOver: Bool {
        game.attempts.last?.pegs == game.masterCode.pegs
    }
    
    func submitGuess() {
        attemptGuessUseCase.execute(game: &game)
        selection = 0
    }
    
    func selectPeg(_ peg: Peg, at index: Int) {
        guard game.guess.pegs.indices.contains(index) else { return }
        game.guess.pegs[index] = peg
    }
}
```

#### Step 5: Update View to Use ViewModel
```swift
// Presentation/Views/CodeBreaker/CodeBreakerView.swift
struct CodeBreakerView: View {
    @StateObject private var viewModel = CodeBreakerViewModel()
    
    var body: some View {
        VStack {
            CodeView(code: viewModel.game.masterCode) {
                Text("0:03").font(.title)
            }
            
            ScrollView {
                if !viewModel.isGameOver {
                    CodeView(
                        code: viewModel.game.guess,
                        selection: $viewModel.selection
                    ) {
                        guessButton
                    }
                }
                
                ForEach(viewModel.game.attempts.indices.reversed(), id: \.self) { index in
                    CodeView(code: viewModel.game.attempts[index]) {
                        if let matches = viewModel.game.attempts[index].matches {
                            MatchMarkers(matches: matches)
                        }
                    }
                }
            }
            
            pegChooser
        }
        .padding()
    }
    
    var pegChooser: some View {
        HStack {
            ForEach(viewModel.game.pegChoices, id: \.self) { peg in
                Button {
                    viewModel.selectPeg(peg, at: viewModel.selection)
                    viewModel.selection = (viewModel.selection + 1) % viewModel.game.masterCode.pegs.count
                } label: {
                    PegsView(peg: peg)
                }
            }
        }
    }
    
    var guessButton: some View {
        Button("Guess") {
            withAnimation {
                viewModel.submitGuess()
            }
        }
        .font(.system(size: 80))
        .minimumScaleFactor(0.1)
    }
}
```

**Checkpoint:** App should work exactly the same, but now with ViewModel layer.

---

### Phase 2: Domain Layer (Week 3-4) 📦

**Goal:** Extract all business logic to Use Cases

#### Step 1: Create All Use Cases

```swift
// Domain/UseCases/CheckGameOverUseCase.swift
struct CheckGameOverUseCase {
    func execute(game: GameEntity) -> Bool {
        game.attempts.last?.pegs == game.masterCode.pegs
    }
}

// Domain/UseCases/SetGuessPegUseCase.swift
struct SetGuessPegUseCase {
    func execute(game: inout GameEntity, peg: Peg, at index: Int) {
        guard game.guess.pegs.indices.contains(index) else { return }
        game.guess.pegs[index] = peg
    }
}

// Domain/UseCases/ChangeGuessPegUseCase.swift
struct ChangeGuessPegUseCase {
    func execute(game: inout GameEntity, at index: Int) {
        let existingPeg = game.guess.pegs[index]
        if let indexOfExisting = game.pegChoices.firstIndex(of: existingPeg) {
            let newPeg = game.pegChoices[(indexOfExisting + 1) % game.pegChoices.count]
            game.guess.pegs[index] = newPeg
        } else {
            game.guess.pegs[index] = game.pegChoices.first ?? Code.missingPeg
        }
    }
}

// Domain/UseCases/ResetGameUseCase.swift
struct ResetGameUseCase {
    func execute(pegChoices: [Peg]) -> GameEntity {
        GameEntity(id: UUID(), pegChoices: pegChoices, createdAt: Date())
    }
}
```

#### Step 2: Update ViewModel to Use All Use Cases

```swift
@MainActor
class CodeBreakerViewModel: ObservableObject {
    @Published var game: GameEntity
    @Published var selection: Int = 0
    
    private let attemptGuessUseCase: AttemptGuessUseCase
    private let checkGameOverUseCase: CheckGameOverUseCase
    private let setGuessPegUseCase: SetGuessPegUseCase
    private let resetGameUseCase: ResetGameUseCase
    
    init(
        attemptGuessUseCase: AttemptGuessUseCase = AttemptGuessUseCase(),
        checkGameOverUseCase: CheckGameOverUseCase = CheckGameOverUseCase(),
        setGuessPegUseCase: SetGuessPegUseCase = SetGuessPegUseCase(),
        resetGameUseCase: ResetGameUseCase = ResetGameUseCase()
    ) {
        self.attemptGuessUseCase = attemptGuessUseCase
        self.checkGameOverUseCase = checkGameOverUseCase
        self.setGuessPegUseCase = setGuessPegUseCase
        self.resetGameUseCase = resetGameUseCase
        
        self.game = resetGameUseCase.execute(pegChoices: [.blue, .green, .yellow, .orange])
    }
    
    var isGameOver: Bool {
        checkGameOverUseCase.execute(game: game)
    }
    
    func submitGuess() {
        attemptGuessUseCase.execute(game: &game)
        selection = 0
    }
    
    func selectPeg(_ peg: Peg, at index: Int) {
        setGuessPegUseCase.execute(game: &game, peg: peg, at: index)
    }
    
    func resetGame() {
        game = resetGameUseCase.execute(pegChoices: game.pegChoices)
        selection = 0
    }
}
```

**Checkpoint:** All business logic now in Domain/UseCases/.

---

### Phase 3: Data Layer (Week 5-6) 💾

**Goal:** Add persistence with Repository pattern

#### Step 1: Define Repository Protocol

```swift
// Domain/Protocols/GameRepository.swift
protocol GameRepository {
    func saveGame(_ game: GameEntity) async throws
    func loadGame() async throws -> GameEntity?
    func deleteGame() async throws
}
```

#### Step 2: Create DTO (Data Transfer Object)

```swift
// Data/Models/GameDTO.swift
struct GameDTO: Codable {
    let id: String
    let masterCodePegs: [String]
    let guessPegs: [String]
    let attemptsPegs: [[String]]
    let pegChoices: [String]
    let createdAt: Date
    
    init(from entity: GameEntity) {
        self.id = entity.id.uuidString
        self.masterCodePegs = entity.masterCode.pegs.map { $0.toHex() }
        self.guessPegs = entity.guess.pegs.map { $0.toHex() }
        self.attemptsPegs = entity.attempts.map { $0.pegs.map { $0.toHex() } }
        self.pegChoices = entity.pegChoices.map { $0.toHex() }
        self.createdAt = entity.createdAt
    }
    
    func toDomain() -> GameEntity {
        GameEntity(
            id: UUID(uuidString: id) ?? UUID(),
            masterCode: Code(kind: .master(isHidden: true), pegs: masterCodePegs.map { Color(hex: $0) }),
            guess: Code(kind: .guess, pegs: guessPegs.map { Color(hex: $0) }),
            attempts: attemptsPegs.map { Code(kind: .guess, pegs: $0.map { Color(hex: $0) }) },
            pegChoices: pegChoices.map { Color(hex: $0) },
            createdAt: createdAt
        )
    }
}
```

#### Step 3: Implement Repository

```swift
// Data/Repositories/LocalGameRepository.swift
class LocalGameRepository: GameRepository {
    private let userDefaults = UserDefaults.standard
    private let key = "saved_game"
    
    func saveGame(_ game: GameEntity) async throws {
        let dto = GameDTO(from: game)
        let data = try JSONEncoder().encode(dto)
        userDefaults.set(data, forKey: key)
    }
    
    func loadGame() async throws -> GameEntity? {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        let dto = try JSONDecoder().decode(GameDTO.self, from: data)
        return dto.toDomain()
    }
    
    func deleteGame() async throws {
        userDefaults.removeObject(forKey: key)
    }
}
```

#### Step 4: Create Save/Load Use Cases

```swift
// Domain/UseCases/SaveGameUseCase.swift
struct SaveGameUseCase {
    let repository: GameRepository
    
    func execute(_ game: GameEntity) async throws {
        try await repository.saveGame(game)
    }
}

// Domain/UseCases/LoadGameUseCase.swift
struct LoadGameUseCase {
    let repository: GameRepository
    
    func execute() async throws -> GameEntity? {
        try await repository.loadGame()
    }
}
```

#### Step 5: Update ViewModel with Persistence

```swift
@MainActor
class CodeBreakerViewModel: ObservableObject {
    // ... existing properties ...
    
    private let saveGameUseCase: SaveGameUseCase
    private let loadGameUseCase: LoadGameUseCase
    
    init(
        // ... existing use cases ...
        saveGameUseCase: SaveGameUseCase,
        loadGameUseCase: LoadGameUseCase
    ) {
        // ... existing initialization ...
        self.saveGameUseCase = saveGameUseCase
        self.loadGameUseCase = loadGameUseCase
        
        Task {
            await loadSavedGame()
        }
    }
    
    func submitGuess() {
        attemptGuessUseCase.execute(game: &game)
        selection = 0
        
        Task {
            try? await saveGameUseCase.execute(game)
        }
    }
    
    private func loadSavedGame() async {
        if let savedGame = try? await loadGameUseCase.execute() {
            self.game = savedGame
        }
    }
}
```

**Checkpoint:** Game now persists across app launches.

---

### Phase 4: Dependency Injection (Week 7) 🔧

**Goal:** Implement proper dependency injection for testability

#### Step 1: Create DI Container

```swift
// App/DIContainer.swift
class DIContainer {
    // MARK: - Data Layer
    private lazy var gameRepository: GameRepository = LocalGameRepository()
    
    // MARK: - Domain Layer (Use Cases)
    lazy var attemptGuessUseCase = AttemptGuessUseCase()
    lazy var checkGameOverUseCase = CheckGameOverUseCase()
    lazy var setGuessPegUseCase = SetGuessPegUseCase()
    lazy var changeGuessPegUseCase = ChangeGuessPegUseCase()
    lazy var resetGameUseCase = ResetGameUseCase()
    lazy var saveGameUseCase = SaveGameUseCase(repository: gameRepository)
    lazy var loadGameUseCase = LoadGameUseCase(repository: gameRepository)
    
    // MARK: - Presentation Layer (ViewModels)
    func makeCodeBreakerViewModel() -> CodeBreakerViewModel {
        CodeBreakerViewModel(
            attemptGuessUseCase: attemptGuessUseCase,
            checkGameOverUseCase: checkGameOverUseCase,
            setGuessPegUseCase: setGuessPegUseCase,
            resetGameUseCase: resetGameUseCase,
            saveGameUseCase: saveGameUseCase,
            loadGameUseCase: loadGameUseCase
        )
    }
}
```

#### Step 2: Update App Entry Point

```swift
// App/FinChronicleApp.swift
@main
struct FinChronicleApp: App {
    private let container = DIContainer()
    
    var body: some Scene {
        WindowGroup {
            CodeBreakerView(
                viewModel: container.makeCodeBreakerViewModel()
            )
        }
    }
}
```

#### Step 3: Update Views to Accept ViewModels

```swift
// Presentation/Views/CodeBreaker/CodeBreakerView.swift
struct CodeBreakerView: View {
    @StateObject var viewModel: CodeBreakerViewModel
    
    init(viewModel: @autoclosure @escaping () -> CodeBreakerViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }
    
    // ... rest of view ...
}
```

**Checkpoint:** Full dependency injection, ready for testing.

---

### Phase 5: Testing (Week 8) ✅

**Goal:** Add comprehensive tests for all layers

#### Step 1: Test Use Cases

```swift
// FinChronicleTests/Domain/UseCases/AttemptGuessUseCaseTests.swift
import XCTest
@testable import FinChronicle

final class AttemptGuessUseCaseTests: XCTestCase {
    var sut: AttemptGuessUseCase!
    var game: GameEntity!
    
    override func setUp() {
        super.setUp()
        sut = AttemptGuessUseCase()
        game = GameEntity(
            id: UUID(),
            pegChoices: [.red, .blue, .green, .yellow],
            createdAt: Date()
        )
    }
    
    func testExecute_AddsAttemptToGame() {
        // Given
        let initialAttemptsCount = game.attempts.count
        
        // When
        sut.execute(game: &game)
        
        // Then
        XCTAssertEqual(game.attempts.count, initialAttemptsCount + 1)
    }
    
    func testExecute_ResetsGuessAfterAttempt() {
        // Given
        game.guess.pegs = [.red, .red, .red, .red]
        
        // When
        sut.execute(game: &game)
        
        // Then
        XCTAssertTrue(game.guess.pegs.allSatisfy { $0 == Code.missingPeg })
    }
    
    func testExecute_RevealsCodeWhenGameWon() {
        // Given
        game.guess.pegs = game.masterCode.pegs
        
        // When
        sut.execute(game: &game)
        
        // Then
        XCTAssertFalse(game.masterCode.isHidden)
    }
}
```

#### Step 2: Test Repository with Mock

```swift
// FinChronicleTests/Data/Repositories/LocalGameRepositoryTests.swift
import XCTest
@testable import FinChronicle

final class LocalGameRepositoryTests: XCTestCase {
    var sut: LocalGameRepository!
    var userDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: "test")!
        sut = LocalGameRepository(userDefaults: userDefaults)
    }
    
    override func tearDown() {
        userDefaults.removePersistentDomain(forName: "test")
        super.tearDown()
    }
    
    func testSaveAndLoadGame() async throws {
        // Given
        let game = GameEntity(
            id: UUID(),
            pegChoices: [.red, .blue],
            createdAt: Date()
        )
        
        // When
        try await sut.saveGame(game)
        let loadedGame = try await sut.loadGame()
        
        // Then
        XCTAssertNotNil(loadedGame)
        XCTAssertEqual(loadedGame?.id, game.id)
    }
}
```

#### Step 3: Test ViewModel

```swift
// FinChronicleTests/Presentation/ViewModels/CodeBreakerViewModelTests.swift
import XCTest
@testable import FinChronicle

@MainActor
final class CodeBreakerViewModelTests: XCTestCase {
    var sut: CodeBreakerViewModel!
    var mockRepository: MockGameRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockGameRepository()
        
        sut = CodeBreakerViewModel(
            attemptGuessUseCase: AttemptGuessUseCase(),
            checkGameOverUseCase: CheckGameOverUseCase(),
            setGuessPegUseCase: SetGuessPegUseCase(),
            resetGameUseCase: ResetGameUseCase(),
            saveGameUseCase: SaveGameUseCase(repository: mockRepository),
            loadGameUseCase: LoadGameUseCase(repository: mockRepository)
        )
    }
    
    func testSubmitGuess_CallsSaveGame() async {
        // When
        sut.submitGuess()
        
        // Wait for async save
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertTrue(mockRepository.saveGameCalled)
    }
    
    func testSelectPeg_UpdatesGameState() {
        // Given
        let peg = Color.red
        let index = 0
        
        // When
        sut.selectPeg(peg, at: index)
        
        // Then
        XCTAssertEqual(sut.game.guess.pegs[index], peg)
    }
}

// Mock Repository for testing
class MockGameRepository: GameRepository {
    var saveGameCalled = false
    var loadGameCalled = false
    var gameToReturn: GameEntity?
    
    func saveGame(_ game: GameEntity) async throws {
        saveGameCalled = true
    }
    
    func loadGame() async throws -> GameEntity? {
        loadGameCalled = true
        return gameToReturn
    }
    
    func deleteGame() async throws { }
}
```

**Checkpoint:** Comprehensive test coverage for all layers.

---

## 8. Code Examples

### Complete Example: Feature Implementation

Let's implement a **"Game History"** feature following Clean Architecture.

#### Step 1: Domain Layer

```swift
// Domain/Entities/GameHistoryEntity.swift
struct GameHistoryEntity {
    let id: UUID
    let games: [GameEntity]
    let lastPlayedDate: Date
}

// Domain/Protocols/GameHistoryRepository.swift
protocol GameHistoryRepository {
    func saveHistory(_ history: GameHistoryEntity) async throws
    func loadHistory() async throws -> GameHistoryEntity?
}

// Domain/UseCases/SaveGameToHistoryUseCase.swift
struct SaveGameToHistoryUseCase {
    let repository: GameHistoryRepository
    
    func execute(_ game: GameEntity, to history: GameHistoryEntity) async throws -> GameHistoryEntity {
        var updatedHistory = history
        updatedHistory.games.append(game)
        try await repository.saveHistory(updatedHistory)
        return updatedHistory
    }
}

// Domain/UseCases/LoadGameHistoryUseCase.swift
struct LoadGameHistoryUseCase {
    let repository: GameHistoryRepository
    
    func execute() async throws -> GameHistoryEntity {
        if let history = try await repository.loadHistory() {
            return history
        }
        return GameHistoryEntity(id: UUID(), games: [], lastPlayedDate: Date())
    }
}
```

#### Step 2: Data Layer

```swift
// Data/Models/GameHistoryDTO.swift
struct GameHistoryDTO: Codable {
    let id: String
    let games: [GameDTO]
    let lastPlayedDate: Date
    
    init(from entity: GameHistoryEntity) {
        self.id = entity.id.uuidString
        self.games = entity.games.map { GameDTO(from: $0) }
        self.lastPlayedDate = entity.lastPlayedDate
    }
    
    func toDomain() -> GameHistoryEntity {
        GameHistoryEntity(
            id: UUID(uuidString: id) ?? UUID(),
            games: games.map { $0.toDomain() },
            lastPlayedDate: lastPlayedDate
        )
    }
}

// Data/Repositories/LocalGameHistoryRepository.swift
class LocalGameHistoryRepository: GameHistoryRepository {
    private let userDefaults = UserDefaults.standard
    private let key = "game_history"
    
    func saveHistory(_ history: GameHistoryEntity) async throws {
        let dto = GameHistoryDTO(from: history)
        let data = try JSONEncoder().encode(dto)
        userDefaults.set(data, forKey: key)
    }
    
    func loadHistory() async throws -> GameHistoryEntity? {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        let dto = try JSONDecoder().decode(GameHistoryDTO.self, from: data)
        return dto.toDomain()
    }
}
```

#### Step 3: Presentation Layer

```swift
// Presentation/ViewModels/GameHistoryViewModel.swift
@MainActor
class GameHistoryViewModel: ObservableObject {
    @Published var history: GameHistoryEntity?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let loadHistoryUseCase: LoadGameHistoryUseCase
    
    init(loadHistoryUseCase: LoadGameHistoryUseCase) {
        self.loadHistoryUseCase = loadHistoryUseCase
    }
    
    func loadHistory() async {
        isLoading = true
        errorMessage = nil
        
        do {
            history = try await loadHistoryUseCase.execute()
        } catch {
            errorMessage = "Failed to load history: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

// Presentation/Views/GameHistoryView.swift
struct GameHistoryView: View {
    @StateObject var viewModel: GameHistoryViewModel
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading history...")
                } else if let history = viewModel.history {
                    List(history.games, id: \.id) { game in
                        GameHistoryRow(game: game)
                    }
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Game History")
            .task {
                await viewModel.loadHistory()
            }
        }
    }
}

struct GameHistoryRow: View {
    let game: GameEntity
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Game \(game.id.uuidString.prefix(8))")
                .font(.headline)
            Text("Attempts: \(game.attempts.count)")
                .font(.subheadline)
            Text(game.createdAt, style: .date)
                .font(.caption)
        }
    }
}
```

#### Step 4: Dependency Injection

```swift
// App/DIContainer.swift
class DIContainer {
    // ... existing code ...
    
    private lazy var gameHistoryRepository: GameHistoryRepository = LocalGameHistoryRepository()
    
    lazy var saveGameToHistoryUseCase = SaveGameToHistoryUseCase(repository: gameHistoryRepository)
    lazy var loadGameHistoryUseCase = LoadGameHistoryUseCase(repository: gameHistoryRepository)
    
    func makeGameHistoryViewModel() -> GameHistoryViewModel {
        GameHistoryViewModel(loadHistoryUseCase: loadGameHistoryUseCase)
    }
}
```

#### Step 5: Testing

```swift
// Tests/Presentation/GameHistoryViewModelTests.swift
@MainActor
final class GameHistoryViewModelTests: XCTestCase {
    var sut: GameHistoryViewModel!
    var mockRepository: MockGameHistoryRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockGameHistoryRepository()
        let useCase = LoadGameHistoryUseCase(repository: mockRepository)
        sut = GameHistoryViewModel(loadHistoryUseCase: useCase)
    }
    
    func testLoadHistory_UpdatesHistoryProperty() async {
        // Given
        let expectedHistory = GameHistoryEntity(id: UUID(), games: [], lastPlayedDate: Date())
        mockRepository.historyToReturn = expectedHistory
        
        // When
        await sut.loadHistory()
        
        // Then
        XCTAssertNotNil(sut.history)
        XCTAssertEqual(sut.history?.id, expectedHistory.id)
        XCTAssertFalse(sut.isLoading)
    }
    
    func testLoadHistory_HandlesError() async {
        // Given
        mockRepository.shouldThrowError = true
        
        // When
        await sut.loadHistory()
        
        // Then
        XCTAssertNil(sut.history)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }
}
```

---

## Benefits of Clean Architecture

### ✅ **Testability**
- Each layer can be tested independently
- Mock dependencies easily with protocols
- High test coverage with unit tests

### ✅ **Maintainability**
- Clear separation of concerns
- Easy to locate and fix bugs
- Changes in one layer don't affect others

### ✅ **Scalability**
- Easy to add new features
- Can swap implementations (e.g., change from UserDefaults to CoreData)
- Modular architecture

### ✅ **Team Collaboration**
- Multiple developers can work on different layers simultaneously
- Clear boundaries and contracts
- Consistent code structure

### ✅ **Flexibility**
- Easy to change UI framework (SwiftUI → UIKit)
- Easy to change data source (Local → Remote API)
- Business logic remains unchanged

---

## Common Pitfalls to Avoid

### ❌ **Over-Engineering**
Don't create layers/abstractions you don't need yet. Start simple, refactor when needed.

### ❌ **Leaky Abstractions**
Don't let implementation details leak across layers (e.g., CoreData objects in Domain).

### ❌ **Anemic Domain**
Don't make Domain layer just data containers. It should contain business logic.

### ❌ **God ViewModels**
Don't put all logic in one massive ViewModel. Split by feature/screen.

### ❌ **Ignoring Dependency Rule**
Never let Domain layer depend on Presentation or Data layers.

---

## Conclusion

### Summary

| Aspect | Current State | Target State |
|--------|--------------|-------------|
| **Architecture** | Model-View (MV) | Clean Architecture |
| **Layers** | 2 (Model + View) | 3 (Presentation + Domain + Data) |
| **ViewModels** | ❌ Missing | ✅ Required |
| **Use Cases** | ❌ In Models | ✅ Separate layer |
| **Testability** | 🟡 Limited | ✅ High |
| **Scalability** | 🟡 Medium | ✅ High |

### Key Takeaways

1. **You're not following Clean Architecture** - but you have good foundations
2. **Extract business logic** to Use Cases (Domain layer)
3. **Add ViewModels** for presentation logic
4. **Implement Repository pattern** for data persistence
5. **Use Dependency Injection** for testability
6. **Follow the Dependency Rule** - dependencies point inward

### Next Steps

1. ✅ Read this document thoroughly
2. 📝 Start with Phase 1 (Foundation)
3. 🔨 Migrate incrementally (one phase at a time)
4. ✅ Write tests for each new component
5. 📚 Refer back to this document during migration

---

## Additional Resources

### Books
- **Clean Architecture** by Robert C. Martin
- **iOS Architecture Patterns** by Raywenderlich.com

### Articles
- [Clean Architecture in Swift](https://tech.olx.com/clean-architecture-and-mvvm-on-ios-c9d167d9f5b3)
- [MVVM vs Clean Architecture](https://www.raywenderlich.com/8477-introducing-mvvm-into-your-project)

### Sample Projects
- [Clean Architecture iOS Template](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM)

---

**Document Version:** 1.0  
**Last Updated:** January 31, 2026  
**Author:** GitHub Copilot  
**Status:** Ready for implementation

