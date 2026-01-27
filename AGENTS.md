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

## 4. Coding Rules & Patterns

### A. Navigation

* **Library:** `@react-navigation/native` v6.x with native-stack, drawer, and bottom-tabs.
* **Pattern:** Stack-based navigation with drawer overlay for main screens.
* **Implementation:**
  * Root navigator: `RootStack` (Native Stack Navigator)
  * Authenticated screens: `RootDrawerScreen` (Drawer Navigator)
  * Define routes in `appNavigator.tsx`
  * Use `navigationRef` from `/src/shared/services/navigation/RootNavigation` for imperative navigation
* **Navigation Service:**
  * `NavigationService.navigateTo(routeName, params)` - Navigate to screen
  * `NavigationService.goBack()` - Go back
  * `NavigationService.getCurrentRoute()` - Get current route name
* **Route Constants:** Define route names in `appConstants.ts` under `NavigationConstant`
* **Deep Linking:** Supported via `link-routes/` module
* **FORBIDDEN:** Do NOT use React Navigation v5 or lower patterns. Always use v6+ APIs.

### B. State Management (Redux + Redux-Saga)

* **Redux Store:** Configured in `/src/store/configureStore.js`
* **Middleware:** Redux-Saga, Redux-Thunk, Dynatrace logger
* **State Tree:** See comprehensive list in architecture analysis above
* **Pattern:**
  * Define actions in `[feature].action.ts` with action creators
  * Define action type constants in `[feature].constant.ts`
  * Handle side effects in `[feature].saga.ts` using Redux-Saga
  * Update state in `[feature].reducer.ts` with pure functions
  * Connect components using `useSelector` and `useDispatch` hooks (functional components) or `connect` HOC (class components)
* **Selectors:** Define selectors for derived state in reducer files or separate selector files
* **Forms:** Use Redux-Form for complex forms (service details, EVCRF)
* **FORBIDDEN:**
  * Do NOT mutate state directly in reducers
  * Do NOT put non-serializable values in state (functions, promises, classes)
  * Do NOT use `redux-saga-testing` for production code (dev dependency only)

### C. API Layer & Network

* **API Modules:** Located in `/src/apis/`
* **Pattern:** Each backend service has a dedicated API module
* **Core APIs:**
  * `jobMonitoringApi.ts` - Assignments & cases
  * `userManagementApi.ts` - Auth & user data
  * `guacApi.ts` - Token management
  * `serviceBrokerApi.ts` - Service operations
  * `fleetManagementApi.ts` - Fleet & driver data
  * `feConfigApi.ts` - Feature flags
  * `translationApi.ts` - i18n translations
  * `googleMapApi.ts` - Google Maps APIs
* **Interceptor Service:** `/src/services/interceptorService.ts`
  * Handles authentication (GUAC-Authorization header)
  * Automatic token refresh on 401
  * Request/response logging
  * Offline cache integration
  * Error handling with retry logic
* **Error Handling:**
  * Do NOT use bare `try/catch` without proper error handling
  * Use interceptor's centralized error handling
  * Display user-friendly errors via `CommonService.showError()`
* **Offline Support:**
  * Cache responses with `offlineApiCacheService` (MMKV-based)
  * Queue failed requests with `requestQueueService`
  * Default cache expiration: 3 days
* **Environment Configuration:**
  * API hosts defined in `.env` files (e.g., `.env.dev-aws`, `.env.prod`)
  * Use `react-native-config` to access environment variables
* **FORBIDDEN:**
  * Do NOT use Axios, Ktor, or third-party HTTP clients
  * Do NOT hardcode API URLs in components or sagas
  * Do NOT use GraphQL/Apollo

### D. Authentication & Security

* **Authentication Service:** `/src/services/authService.ts`
* **Flow:**
  1. User enters credentials
  2. Call `authService.authentication(username, password, subscriptionCountry)`
  3. Service validates via `userManagementApi.login()`
  4. On success: Save tokens in secure storage, fetch user config, link device
  5. Navigate to Terms of Service (if not accepted) or main screen
* **Token Storage:**
  * Use `react-native-sensitive-info` for tokens (encrypted)
  * Access token: `token`
  * Refresh token: `refresh_token`
* **Token Refresh:**
  * Automatic on 401 response
  * Handled by `interceptorService`
  * Subscriber queue pattern to avoid duplicate refresh requests
* **Multi-Factor Authentication:**
  * Biometric (fingerprint/face ID): `authService.loginWithBiometric()`
  * OTP: Via `otpService` and `OtpInputScreen`
  * Configuration: Per BU level (mandatory/optional)
* **Logout:**
  * Call `authService.logOut()`
  * Clears tokens, cache, Redux state
  * Resets navigation to Login screen
* **FORBIDDEN:**
  * Do NOT store tokens in AsyncStorage (use secure storage)
  * Do NOT log tokens or sensitive data
  * Do NOT bypass MFA if configured

### E. Storage

* **Storage Types:**
  * **Secure Storage:** `react-native-sensitive-info` for tokens, credentials
  * **Fast Storage:** `react-native-mmkv` for cache, preferences (10x faster than AsyncStorage)
  * **Persistent Storage:** `@react-native-async-storage/async-storage` for non-sensitive data
* **Services:**
  * `asyncStorageService.ts` - AsyncStorage wrapper
  * `mmkvStorageService.ts` - MMKV wrapper
  * `offlineApiCacheService.ts` - API response caching
* **Cache Management:**
  * Prefix-based keys (e.g., `API_CACHE_`, `OFFLINE_QUEUE_`)
  * Selective invalidation
  * Parallel Promise.all operations for batch reads/writes
* **FORBIDDEN:**
  * Do NOT use AsyncStorage for tokens or sensitive data
  * Do NOT use raw storage APIs (always use service wrappers)

### F. Component Design & Shared Components

* **Shared Components:** Located in `/src/shared/components/`
* **Rule:** Shared components must be GENERIC and REUSABLE
  * Accept props for configuration (text, colors, callbacks)
  * No domain-specific logic (e.g., "Cart", "User", "Assignment")
  * No direct Redux connections (pass data via props)
  * No hardcoded navigation (use callbacks)
* **Available Shared Components:**
  * `button/` - Generic button with variants
  * `custom-text/` - Typography wrapper
  * `custom-picker/` - Dropdown/picker
  * `floating-label-text-input/` - Input fields with floating labels
  * `header/` - Header bars (main, back, hamburger variants)
  * `loading-overlay/` - Loading spinner
  * `animated-view/` - Animation wrapper
  * `mapview/` - Map components
  * `modal/` - Modal dialogs (ask, contact, reject, lunch break)
  * `switch/` - Toggle switch
* **Feature-Specific Components:** Located in `/src/components/`
  * Can contain domain logic
  * Can connect to Redux
  * Can use navigation
* **Styling:**
  * Use StyleSheet API for styles
  * Separate style files: `[component].style.ts`
  * Import colors/fonts from `appConstants.ts`
  * Use responsive design (consider device dimensions)
* **Modification Protocol:**
  * **ALLOWED:** Adding new generic components to `/src/shared/components/`
  * **ALLOWED:** Enhancing shared components with generic props
  * **FORBIDDEN:** Adding domain-specific logic to shared components
  * **FORBIDDEN:** Modifying shared components for one-off feature requirements
  * **INSTEAD:** Wrap shared components in feature-specific components for customization

### G. Cross-Feature Communication

* **Rule:** Features should be loosely coupled
* **Pattern:**
  * If Feature A needs data from Feature B:
    * Feature A dispatches a Redux action
    * Feature B's saga handles the action and updates state
    * Feature A reads from Redux store via selector
  * Example: `assignment-list` dispatches `FETCH_ASSIGNMENT_DETAIL` action, `service-detail` saga handles it
* **Navigation Between Features:**
  * Use `NavigationService.navigateTo()` or `navigation.navigate()`
  * Pass params via navigation params (not Redux state)
  * Example: Navigate from assignment list to service detail with assignment ID
* **FORBIDDEN:**
  * Do NOT import feature components directly across features
  * Do NOT create circular dependencies between features

### H. Models & Type Safety

* **Location:** `/src/model/` and `/src/shared/models/`
* **Pattern:**
  * Define TypeScript interfaces for all domain entities
  * Use classes for entities with computed properties or methods
  * Static factory methods (e.g., `AssignmentModel.of(data)`)
* **Core Models:**
  * `AssignmentModel` - Assignment entity
  * `ServiceDeliveryItemModel` - Service/tariff item
  * `DriverModel` - Driver profile
  * `TruckModel` - Vehicle information
  * `UserProfile.model` - User with permissions
  * `ConvertedResponse.model` - Standard API response wrapper
* **API Response Pattern:**
  ```typescript
  interface ConvertedResponse<T> {
    isSuccess: boolean;
    body: T;
    errorKey: string;
    msg: string;
    msgCode: string;
    status: number;
  }
  ```
* **Type Safety:**
  * Use TypeScript for all new code
  * Avoid `any` type (use `unknown` or proper types)
  * Define interfaces for props, state, API responses
* **FORBIDDEN:**
  * Do NOT use `any` type unless absolutely necessary
  * Do NOT use JavaScript files for new code (use TypeScript)

### I. Localization & Internationalization

* **Library:** `i18n-js` v3.8.0
* **Translation Service:** `/src/services/i18nService.ts`
* **Pattern:**
  * Translations fetched from backend via `translationApi`
  * Cached in MMKV storage
  * Fallback to English if translation not found
* **Usage:**
  * Import `I18n` from `i18n-js`
  * Use `I18n.t('translation.key')` for translations
  * Dynamic translations: `I18n.t('key', { variable: value })`
* **Translation Keys:**
  * Defined in backend (hexalite-translation service)
  * Managed via Excel file in group_solution repo
* **FORBIDDEN:**
  * Do NOT hardcode user-facing strings
  * Do NOT create local translation files (use backend API)

### J. Testing

* **Framework:** Jest + React Native Testing Library
* **Test Files:** Co-locate tests with features in `__test__/` or `__tests__/` folders
* **Naming:** `[feature].spec.ts` or `[feature].test.ts`
* **Mocks:** Global mocks in `__mocks__/` at root level
* **Patterns:**
  * Unit tests: Test individual functions, models, reducers
  * Component tests: Test component rendering & behavior
  * Snapshot tests: Test UI stability (use sparingly)
  * Saga tests: Test side effects with `redux-saga-testing`
* **Coverage:** Run `npm run test` for coverage report
* **FORBIDDEN:**
  * Do NOT skip tests for critical paths (auth, payments, data mutations)
  * Do NOT commit code with failing tests

## 5. Implementation Details

### Platform-Specific Code

* **Pattern:** Use platform-specific files when necessary
  * `component.android.tsx` - Android-specific implementation
  * `component.ios.tsx` - iOS-specific implementation
  * React Native automatically picks the correct file
* **Platform Detection:** Use `Platform.OS` from `react-native`
  ```typescript
  import { Platform } from 'react-native';
  if (Platform.OS === 'android') {
    // Android-specific code
  } else if (Platform.OS === 'ios') {
    // iOS-specific code
  }
  ```
* **Native Modules:**
  * Android: `android/app/src/main/java/`
  * iOS: `ios/gbmfDriverApp/`
* **FORBIDDEN:**
  * Do NOT use platform checks for UI styling (use responsive design)
  * Do NOT create platform-specific features without product approval

### Environment Configuration

* **Pattern:** Use `.env` files for environment-specific configuration
* **Available Environments:**
  * `.env.dev-aws` - Development (AWS)
  * `.env.qa` - QA
  * `.env.uat-aws` - UAT (AWS)
  * `.env.perf` - Performance testing
  * `.env.prod` - Production
* **Configuration Variables:**
  * API hosts (SERVICE_BROKER_API_HOST, USER_MANAGEMENT_API_HOST, etc.)
  * App version (APP_VERSION_CODE, APP_VERSION_NAME)
  * CodePush keys (ANDROID_CODEPUSH_KEY, CODEPUSH_KEY for iOS)
  * Google Maps API keys (GOOGLE_MAPS_API_KEY, etc.)
* **Access:** Use `Config` from `react-native-config`
  ```typescript
  import Config from 'react-native-config';
  const apiHost = Config.SERVICE_BROKER_API_HOST;
  ```
* **Android Configuration:**
  * Product flavors in `android/app/build.gradle`
  * Flavor-specific resources (strings, authorities)
  * Build variants: `[flavor][buildType]` (e.g., `devawsDebug`, `prodRelease`)
* **iOS Configuration:**
  * Build configurations in Xcode project
  * User-defined build settings (CODEPUSH_KEY, Env_BundleIdentifier, etc.)
  * Schemes for each environment
* **FORBIDDEN:**
  * Do NOT commit API keys to `.env` files (use vault)
  * Do NOT hardcode environment-specific values in code

### Background Services & Geolocation

* **Background Geolocation:** `/src/services/backgroundGeolocationService.ts`
* **Pattern:**
  * Android: Foreground service with persistent notification
  * iOS: Background location updates with significant change monitoring
* **Service:** `/src/services/foregroundService.ts` (Android-specific)
* **Configuration:**
  * Update interval: Configurable per BU
  * Geofencing: Supported
  * Battery optimization: Balanced mode
* **FORBIDDEN:**
  * Do NOT track location without user consent
  * Do NOT drain battery with aggressive tracking

### Push Notifications

* **Service:** `/src/services/localNotificationService.ts`
* **Firebase:** `@react-native-firebase/messaging`
* **Pattern:**
  * FCM for push notification delivery
  * Local notifications for reminders
  * Background handler for silent notifications
* **Configuration:**
  * Android: `google-services.json` (from vault)
  * iOS: APNS certificate + FCM configuration
* **Subscription:**
  * Subscribe on login: `pushNotificationApi.subscribe(token, subscriptionCountry)`
  * Unsubscribe on logout
* **FORBIDDEN:**
  * Do NOT show notifications without user permission
  * Do NOT send sensitive data in notification payload

### Code Push (OTA Updates)

* **Service:** Standalone Code Push Server
* **Configuration:**
  * Android: `ANDROID_CODEPUSH_KEY`, `ANDROID_CODEPUSH_SERVER_URL` in `.env`
  * iOS: `CODEPUSH_KEY`, `CODEPUSH_SERVER_URL` in Xcode build settings
* **Deployments:**
  * Multiple deployment targets per environment (dev, staging, production)
  * Target versions with semantic versioning
* **Release Process:**
  * Jenkins automation for releases
  * Manual release: `npm run codepush-release:android` / `npm run codepush-release:ios`
* **FORBIDDEN:**
  * Do NOT release code push without testing
  * Do NOT target wrong deployment (could break production)

### Performance Optimization

* **Storage:**
  * Use MMKV for frequently accessed data (10x faster than AsyncStorage)
  * Batch read/write operations with Promise.all
  * Selective cache invalidation (prefix-based)
* **Network:**
  * Cache API responses (3-day default expiration)
  * Offline queue for failed requests
  * Request deduplication in interceptor
* **Rendering:**
  * Use `React.memo` for expensive components
  * Use `useMemo` and `useCallback` hooks for expensive computations
  * Avoid inline styles and function definitions in render
  * Use FlatList for long lists (virtualization)
* **FORBIDDEN:**
  * Do NOT block UI thread with heavy computations
  * Do NOT render large lists without virtualization

## 6. Third-Party Dependency Protocol

Before adding **ANY** new library, follow this strict process:

1. **Search Strategy:**
   * Search on [npm](https://www.npmjs.com/) for React Native libraries
   * Check React Native Directory: https://reactnative.directory/
   * Verify React Native version compatibility (0.74.5)
   * Check TypeScript support

2. **Evaluation Criteria:**
   * Is it actively maintained? (recent commits, issues addressed)
   * Does it support both Android and iOS?
   * Is it well-documented?
   * What are the bundle size implications?
   * Does it require native module linking?
   * Are there security vulnerabilities? (check npm audit)

3. **Comparison:**
   * Do not simply pick the first result
   * Compare at least 2-3 alternatives
   * Consider: stars, downloads, issues, last update, license

4. **Mandatory Approval:**
   * You MUST stop and ask the user before editing `package.json` or build files
   * Provide a summary like this:

   > "To solve [Problem], I researched React Native libraries:
   > 1. **Library A (vX.X.X):** [Pros/Cons]
   > 2. **Library B (vX.X.X):** [Pros/Cons]
   >
   > I recommend **Library A** (Version X.X.X) because [Reason].
   > This will require:
   > - npm install (--legacy-peer-deps if needed)
   > - pod install (iOS)
   > - [Any native configuration steps]
   >
   > Shall I proceed?"

5. **Installation Process:**
   * Install with `npm install [package] --legacy-peer-deps` (if peer dependency conflicts)
   * Run `cd ios && pod install` for iOS native dependencies
   * Run `npm run instrumentDynatrace` after installing (Dynatrace integration)
   * Test on both Android and iOS

6. **FORBIDDEN:**
   * Do NOT install libraries without user approval
   * Do NOT use alpha/beta versions in production
   * Do NOT ignore peer dependency warnings

## 7. Build & Release Process

### Development Builds

**Android:**
```bash
# Set environment
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home
export ANDROID_HOME=$HOME/Library/Android/sdk

# Run on emulator/device
npm run android:mode --mode=devawsDebug

# Or with specific variant
npm run android -- --variant devawsdebug
```

**iOS:**
```bash
# Install dependencies
cd ios && pod install && cd ..

# Run on simulator
npm run ios -- --simulator="iPhone 15"

# Run on real device
npx react-native run-ios --device "Device Name"

# Switch environment
cp .env.dev-aws .env
ENVFILE=.env.dev-aws npm run ios -- --configuration DEV-AWS
```

### Production Builds

**Android:**
1. Run `npm run bundle:android-wo-asset` to create JS bundle
2. Open Android Studio
3. Build > Generate Signed APK
4. Select keystore: `android/key` (password: 123456)
5. Key alias: `gbmf-driver-app-key`
6. Select build variant (e.g., `prodRelease`)

**iOS:**
1. Open `ios/gbmfDriverApp.xcworkspace` in Xcode
2. Select scheme (e.g., PROD)
3. Product > Archive
4. Distribute App > Enterprise
5. Export IPA

**FORBIDDEN:**
* Do NOT build production without testing on staging
* Do NOT commit keystore files
* Do NOT use debug builds for production

## 8. Git Workflow & Conventions

### Branch Strategy

* **Main Branches:**
  * `master` - Production-ready code
  * `releases/R[version]` - Release branches (e.g., `releases/R26B`)
* **Feature Branches:**
  * Format: `feature/[ticket-id]-short-description`
  * Example: `feature/ONERSA-12345-add-biometric-login`
* **Bugfix Branches:**
  * Format: `bugfix/[ticket-id]-short-description`
  * Example: `bugfix/UATRSA-67890-fix-crash-on-logout`

### Commit Messages

* **Format:** `[TICKET-ID] Brief description`
* **Examples:**
  * `[ONERSA-12345] Add biometric authentication support`
  * `[UATRSA-67890] Fix crash on logout when offline`
* **Good Commit:** Clear, concise, explains "what" and "why"
* **Bad Commit:** `fix bug`, `update code`, `wip`

### Pull Request Process

1. Create feature/bugfix branch from `master` or release branch
2. Make changes following coding guidelines
3. Write/update tests
4. Run `npm run lint` to check code quality
5. Run `npm run test` to ensure tests pass
6. Create PR with template (PULL_REQUEST_TEMPLATE.md)
7. Request reviews from team members
8. Address review comments
9. Merge after approval

**FORBIDDEN:**
* Do NOT merge without review
* Do NOT commit directly to `master` or release branches
* Do NOT merge with failing tests

## 9. Common Pitfalls & Best Practices

### Pitfalls to Avoid

1. **AsyncStorage for Tokens:** Use `react-native-sensitive-info` for secure storage
2. **Blocking UI Thread:** Use async operations and loading indicators
3. **Memory Leaks:** Clean up listeners, timers, subscriptions in unmount
4. **Hardcoded Strings:** Use i18n translations
5. **Large Bundle Size:** Use dynamic imports for large features
6. **Unhandled Promise Rejections:** Always catch errors in async code
7. **Direct State Mutation:** Always return new state objects in reducers
8. **Inline Styles:** Use StyleSheet.create for performance
9. **Missing Permissions:** Request permissions before accessing device features
10. **Network Errors:** Handle offline state gracefully

### Best Practices

1. **Always Use Hooks:** Prefer functional components with hooks over class components
2. **TypeScript:** Use TypeScript for new code with proper type definitions
3. **Code Review:** Review your own code before submitting PR
4. **Testing:** Write tests for critical paths (auth, payments, data mutations)
5. **Error Handling:** Show user-friendly error messages, log technical details
6. **Performance:** Profile with React DevTools, optimize re-renders
7. **Accessibility:** Add accessibility labels for screen readers
8. **Security:** Never log sensitive data (tokens, passwords, PII)
9. **Documentation:** Document complex logic with comments
10. **Consistency:** Follow existing patterns and conventions in the codebase

## 10. Key Files & Entry Points

### Critical Files

* **Entry Point:** `index.js` - App registration
* **Root Component:** `App.tsx` - App initialization with Redux provider
* **Navigation:** `src/appNavigator.tsx` - Navigation configuration
* **Constants:** `src/appConstants.ts` - Application-wide constants (~730 lines)
* **Redux Store:** `src/store/configureStore.js` - Redux setup
* **Root Reducer:** `src/reducers/index.ts` - Combines all reducers
* **Root Saga:** `src/saga/index.ts` - Combines all sagas
* **Interceptor:** `src/services/interceptorService.ts` - HTTP interceptor

### Configuration Files

* **Package:** `package.json` - Dependencies & scripts
* **TypeScript:** `tsconfig.json` - TypeScript configuration
* **Babel:** `babel.config.js` - Babel presets & plugins
* **Metro:** `metro.config.js` - Metro bundler configuration
* **Jest:** `jest.config.js` - Test configuration
* **ESLint:** `.eslintrc.json` - Linting rules
* **Prettier:** `.prettierrc` - Code formatting

### Android

* **Build:** `android/app/build.gradle` - Build configuration, product flavors
* **Manifest:** `android/app/src/main/AndroidManifest.xml` - App manifest
* **Main Activity:** `android/app/src/main/java/.../MainActivity.java`

### iOS

* **Workspace:** `ios/gbmfDriverApp.xcworkspace` - Xcode workspace
* **Podfile:** `ios/Podfile` - CocoaPods dependencies
* **Info.plist:** `ios/gbmfDriverApp/Info.plist` - App configuration

## 11. Support & Resources

### Documentation

* **README:** `/README.md` - Setup & build instructions
* **Release Notes:** `/RELEASE-NOTES.md` - Version history
* **PR Template:** `/PULL_REQUEST_TEMPLATE.md` - PR guidelines

### Internal Links

* **Vault:** Credentials & secrets storage
* **Jenkins:** CI/CD pipelines
* **Code Push Server:** OTA updates management
* **Confluence:** Project documentation
* **GitHub:** Source code repository

### External Resources

* **React Native Docs:** https://reactnative.dev/docs/getting-started
* **React Navigation:** https://reactnavigation.org/docs/getting-started
* **Redux:** https://redux.js.org/introduction/getting-started
* **Redux-Saga:** https://redux-saga.js.org/docs/introduction/GettingStarted
* **TypeScript:** https://www.typescriptlang.org/docs/

---

## Summary

This AGENTS.md document provides comprehensive guidelines for developing the Hexalite Integrated App. Key principles:

1. **Feature-Based Architecture:** Self-contained modules with clear boundaries
2. **Redux + Saga:** Centralized state management with side effects handling
3. **Type Safety:** TypeScript for new code with proper type definitions
4. **Offline-First:** Cache API responses, queue failed requests
5. **Security:** Secure storage for tokens, MFA support, no sensitive data logging
6. **Testing:** Unit tests for critical paths, integration tests for workflows
7. **Code Quality:** ESLint, Prettier, consistent code style
8. **Performance:** MMKV storage, request deduplication, optimized rendering
9. **Dependency Management:** Approval required before adding new dependencies
10. **Documentation:** Clear comments, JIRA tickets, PR descriptions

**When in doubt, follow existing patterns in the codebase. Consistency is key.**
