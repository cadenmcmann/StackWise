# StackWise iOS App - Architecture Overview

## Executive Summary
StackWise is a SwiftUI-based iOS application (iOS 17+) that provides personalized supplement recommendations. The app uses MVVM architecture with dependency injection, features a comprehensive onboarding flow, and includes five main tabs for stack management, scheduling, tracking, AI chat, and user profile management.

## Tech Stack
- **Platform**: iOS 17+
- **Framework**: SwiftUI
- **Architecture**: MVVM with Dependency Injection
- **Language**: Swift 5.9+
- **Build System**: Xcode 15+ with makefile for CLI builds
- **State Management**: @StateObject, @ObservedObject, @EnvironmentObject

## Project Structure

```
StackWise/
├── StackWise/
│   ├── App/
│   │   ├── StackWiseApp.swift        # Main app entry point
│   │   ├── DIContainer.swift         # Dependency injection container
│   │   └── Theme.swift               # Design tokens (colors, spacing, typography)
│   ├── Models/
│   │   ├── User.swift               # User profile data
│   │   ├── Intake.swift             # Onboarding data (goals, basics, risks)
│   │   ├── Supplement.swift         # Supplement & Stack models
│   │   ├── Reminder.swift           # Schedule reminders
│   │   ├── TrackEntry.swift         # Tracking entries
│   │   └── Message.swift            # Chat messages
│   ├── Services/
│   │   ├── Protocols/               # Service interfaces
│   │   │   ├── AuthService.swift
│   │   │   ├── RecommendationService.swift
│   │   │   ├── ScheduleService.swift
│   │   │   ├── TrackingService.swift
│   │   │   ├── ChatService.swift
│   │   │   ├── ExportService.swift
│   │   │   ├── GoalsService.swift
│   │   │   └── PreferencesService.swift
│   │   ├── Mock/                    # Mock implementations
│   │   │   └── Mock*.swift          # Mock services with sample data
│   │   └── Real/                    # Real API implementations
│   │       ├── RealAuthService.swift
│   │       ├── RealRecommendationService.swift
│   │       ├── RealGoalsService.swift
│   │       ├── RealPreferencesService.swift
│   │       ├── RealTrackingService.swift
│   │       └── RealChatService.swift
│   ├── Networking/
│   │   ├── NetworkManager.swift     # API request handling
│   │   └── APIModels.swift          # API request/response models
│   ├── DesignSystem/                # Reusable UI components
│   │   ├── Chip.swift               # Selectable chips with flow layout
│   │   ├── Card.swift               # Expandable content cards
│   │   ├── Banner.swift             # Info/warning/danger banners
│   │   ├── Buttons.swift            # Primary/Secondary/Text buttons
│   │   ├── FormComponents.swift     # TextField, Slider, Toggle, etc.
│   │   ├── LoadingComponents.swift  # Skeletons and loading states
│   │   ├── Toast.swift              # Toast notifications
│   │   └── EmptyState.swift        # Empty state views
│   ├── Features/                    # Feature modules
│   │   ├── Onboarding/
│   │   │   ├── OnboardingFlow.swift
│   │   │   ├── OnboardingViewModel.swift
│   │   │   └── Screens/            # 10 onboarding screens
│   │   │       ├── WelcomeScreen.swift     # Login/signup hub
│   │   │       ├── LoginScreen.swift       # Email login
│   │   │       ├── SignupScreen.swift      # Account creation
│   │   │       ├── SplashScreen.swift      # Disclaimers
│   │   │       ├── GoalsScreen.swift       # Health goals
│   │   │       ├── BasicsScreen.swift      # Demographics
│   │   │       ├── RisksScreen.swift       # Medical conditions
│   │   │       ├── PriorityScreen.swift    # Top priority
│   │   │       ├── ReviewScreen.swift      # Summary
│   │   │       └── GeneratingScreen.swift  # Loading
│   │   ├── Stack/                  # Tab 1: Stack management
│   │   │   ├── StackView.swift          # Main stack display with active/inactive filtering
│   │   │   ├── StackViewModel.swift     # Stack state management
│   │   │   └── SupplementDetailSheet.swift # Bottom sheet for supplement details
│   │   ├── Schedule/               # Tab 2: Reminder schedule
│   │   │   ├── ScheduleView.swift
│   │   │   └── ScheduleViewModel.swift
│   │   ├── Track/                  # Tab 3: Progress tracking
│   │   │   ├── TrackView.swift
│   │   │   └── TrackViewModel.swift
│   │   ├── Chat/                   # Tab 4: AI assistant
│   │   │   ├── ChatView.swift           # Main entry point
│   │   │   ├── ChatViewModel.swift      # Legacy view model
│   │   │   ├── ChatSessionsView.swift   # Sessions list screen
│   │   │   └── ChatConversationView.swift # Individual chat screen
│   │   └── Profile/                # Tab 5: User profile
│   │       ├── ProfileView.swift
│   │       └── ProfileViewModel.swift
│   └── Utilities/
│       └── Extensions.swift        # Helper extensions
├── StackWise.xcodeproj/
├── makefile                        # Build commands
└── Documentation/
    ├── ARCHITECTURE_OVERVIEW.md    # This document
    └── TODO.md                     # Development roadmap
```

## Core Architecture Patterns

### 1. Dependency Injection Container
The `DIContainer` class manages all service dependencies and shared state:
- Located in: `App/DIContainer.swift`
- Provides singleton services (Auth, Recommendation, Schedule, Tracking, Chat, Export)
- Manages global state (currentUser, currentStack, onboardingCompleted)
- Injected via environment: `.environment(\.container, container)`

### 2. MVVM Pattern
Each feature follows strict MVVM:
- **View**: SwiftUI views with minimal logic
- **ViewModel**: `@MainActor` classes with `@Published` properties
- **Model**: Plain structs with Codable conformance
- **Service**: Protocol-based services injected via DIContainer

Example:
```swift
// View
struct StackView: View {
    @StateObject private var viewModel: StackViewModel
    
    init(container: DIContainer) {
        _viewModel = StateObject(wrappedValue: StackViewModel(container: container))
    }
}

// ViewModel
@MainActor
class StackViewModel: ObservableObject {
    @Published var stack: Stack?
    private let container: DIContainer
}
```

### 3. Service Layer
All external interactions go through protocol-based services:
- **Protocols** define contracts in `Services/Protocols/`
- **Mock implementations** in `Services/Mock/` return sample data
- Services are injected via DIContainer, making them easily swappable

## Key Components

### App Entry & Navigation
- **StackWiseApp.swift**: Main app entry, initializes DIContainer
- **ContentView**: Routes between onboarding and main app based on `onboardingCompleted`
- **MainTabView**: 5-tab navigation (Stack, Schedule, Track, Chat, Profile)

### Onboarding Flow
9-screen modal NavigationStack:
1. **WelcomeScreen**: Login/signup hub with email and Sign in with Apple
2. **LoginScreen**: Email/password authentication (modal sheet)
3. **SignupScreen**: Account creation with validation (modal sheet)
4. **SplashScreen**: Age verification & disclaimers
5. **GoalsScreen**: Multi-select health goals
6. **BasicsScreen**: Demographics, budget, dietary preferences
7. **RisksScreen**: Medical conditions with safety warnings
8. **PriorityScreen**: Free-text primary goal
9. **ReviewScreen**: Editable summary
10. **GeneratingScreen**: Loading animation

Flow managed by `OnboardingViewModel` with step-based navigation and authentication state.

### Design System
Centralized in `Theme.swift`:
- **Colors**: Primary blue (#007AFF), clinical whites/grays
- **Spacing**: 4, 8, 12, 16, 24, 32pt scale
- **Typography**: Semantic sizes (titleXL, titleL, titleM, body, subhead, caption)
- **Radii**: sm=8, md=12, lg=16, xl=24
- **Animation**: Respects Reduce Motion accessibility

### Data Models

#### Core Models
- **User**: Demographics, preferences, budget
- **Intake**: Onboarding selections (goals, basics, risks, priority)
- **Stack**: Contains minimal (1-3) and optional (0-3) supplements
- **Supplement**: Name, purpose, dose, timing, evidence level, citations
- **Reminder**: Supplement ID, time, enabled state
- **TrackEntry**: Date, taken supplements, optional note
- **Message**: Chat messages with role (user/assistant/system)
- **ChatSession**: Session metadata (id, title, timestamps)

#### Enums
- **Goal**: 18 health goals (strength, sleep, focus, etc.)
- **Risk**: 12 medical conditions/medications
- **DietaryPreference**: 7 dietary restrictions
- **TimingTag**: AM/Lunch/PM/Night
- **EvidenceLevel**: A/B/C ratings

### State Management
1. **Global State**: DIContainer holds user, stack, onboarding status
2. **Feature State**: Each ViewModel manages its screen's state
3. **Persistence**: UserDefaults for simple scaffold persistence
4. **Mock Data**: Services return realistic sample data with delays

### Mock Service Behavior

#### MockRecommendationService
- Generates 1-3 minimal supplements based on goals
- Adds 0-2 optional supplements
- Respects dietary preferences and risks
- 1.5s simulated processing delay

#### MockScheduleService
- Pre-configured morning (8am) and night (9pm) reminders
- Tracks taken status in memory
- Integrates with iOS notifications

#### MockTrackingService
- Generates 7 days of sample tracking data
- Random completion rates (50-100%)
- Sample notes for recent days
- Calculates streaks

#### RealChatService (Active)
- Full integration with backend Chat API
- Session management (create, list, fetch)
- Message sending and receiving with AI responses
- Local caching for offline support
- Pagination support for message history
- Context includes user profile and stack

## UI/UX Patterns

### Component Patterns
- **Cards**: Expandable with chevron animation
- **Chips**: Multi-select with flow layout
- **Banners**: Contextual info/warning/danger alerts
- **Empty States**: Icon + title + subtitle + CTA
- **Loading**: Skeletons and progress indicators
- **Toast**: Temporary success notifications

### Navigation Patterns
- **Tab-based**: Persistent 5-tab bottom navigation
- **Modal**: Onboarding presented over main app
- **Sheets**: Settings, remix options, side effects
- **Deep-linking**: Review screen can navigate back to any onboarding step

### Accessibility
- Dynamic Type support throughout
- 44pt minimum touch targets
- Reduce Motion respected (subtle fades instead of animations)
- High contrast colors (WCAG AA compliant)
- VoiceOver labels on interactive elements

## Build & Development

### Build Commands (makefile)
```bash
make build          # Build for iPhone 16 simulator
make test           # Run unit tests
make clean          # Clean derived data
make reset          # Full clean including .build
make run            # Build and launch in simulator
make print-schemes  # List available schemes
make print-devices  # List available simulators
```

### Key Files to Know
1. **Entry Point**: `StackWiseApp.swift` - App initialization
2. **DI Setup**: `DIContainer.swift` - Service registration
3. **Theme**: `Theme.swift` - All design tokens
4. **Mock Data**: `Services/Mock/*` - Sample data generation
5. **Main Navigation**: `StackWiseApp.swift` ContentView

### Current Implementation Status
- ✅ Full UI scaffold with all screens
- ✅ Authentication UI (login/signup screens)
- ✅ Real authentication with backend API
- ✅ JWT token management
- ✅ Dynamic goals loading from API
- ✅ User preferences saved to backend
- ✅ Stack generation via API
- ✅ Navigation and state management
- ✅ Design system components
- ✅ Accessibility support
- ✅ Basic persistence (UserDefaults + API)
- ✅ NetworkManager for API calls
- ✅ Real services for Auth, Goals, Preferences, Stack, Tracking, Chat
- ✅ AI-powered chat with session management
- ✅ Chat sessions list and conversation views
- ✅ Message pagination and local caching
- ✅ Enhanced Stack screen with supplement details modal
- ✅ Active/inactive supplement filtering and toggling
- ✅ Integration with PATCH /stack/{stackId}/supplements endpoint
- ⚠️ Sign in with Apple UI present but not functional
- ⚠️ Schedule and Export still using mock services

## Quick Start for New Developers

1. **Open project**: `open StackWise.xcodeproj`
2. **Build**: `make build` or Cmd+B in Xcode
3. **Run**: `make run` or Cmd+R in Xcode
4. **Key entry points**:
   - App starts in `StackWiseApp.swift`
   - Onboarding in `Features/Onboarding/`
   - Each tab has its own folder in `Features/`
5. **To modify mock data**: Edit files in `Services/Mock/`
6. **To change design**: Update `Theme.swift`
7. **To add new components**: Add to `DesignSystem/`

## Architecture Decisions

1. **Why MVVM**: Clear separation of concerns, SwiftUI-friendly, testable
2. **Why Dependency Injection**: Easy mock/real service swapping, testability
3. **Why Protocol-based Services**: Abstraction from implementation details
4. **Why Design Tokens**: Consistent styling, easy theme changes
5. **Why Mock Services**: Rapid UI development without backend dependencies
6. **Why UserDefaults**: Simple persistence for scaffold (will migrate to Core Data/CloudKit)

## Integration Points (for Future Development)

### Backend API
- **Base URL**: https://7pcymt07l8.execute-api.us-east-1.amazonaws.com/
- **Authentication**: JWT Bearer tokens
- **Implemented Endpoints**:
  - POST /auth/signup - User registration
  - POST /auth/login - User authentication
  - GET /goals - Fetch available goals
  - POST /preferences - Save user preferences
  - GET /preferences - Fetch user preferences
  - POST /stack/generate - Generate supplement stack
  - GET /stack/current - Fetch current stack
- **NetworkManager**: Handles all API requests with token management
- **Real Services**: Located in `Services/Real/`
- **Mock Services**: Still available in `Services/Mock/` for testing

### AI/LLM Integration
- ChatService protocol ready for streaming responses
- Message model supports role-based conversation
- Context includes user profile and current stack

### Authentication
- AuthService protocol supports Sign in with Apple
- User model ready for account data
- DIContainer manages auth state

### Data Persistence
- Models are Codable for easy serialization
- Ready for Core Data or CloudKit migration
- Current UserDefaults can be migrated

### Analytics
- TODO comments mark analytics event points
- Event bus pattern can be added to DIContainer
- No SDK dependencies to add later

This architecture provides a solid foundation for iterative development while maintaining clean separation of concerns and testability.
