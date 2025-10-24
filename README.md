# StackWise - Personalized Supplement Recommendations

A clinical, trustworthy iOS app that provides personalized supplement recommendations based on user health goals, medical history, and preferences.

## 📚 Documentation

### For AI Assistants & New Developers
When working with AI coding assistants (Cursor, GitHub Copilot, Claude, etc.), provide these two documents first:

1. **[ARCHITECTURE_OVERVIEW.md](./ARCHITECTURE_OVERVIEW.md)** - Complete technical overview of the current implementation
   - App structure and architecture patterns
   - File organization and key components
   - Design system and UI patterns
   - Current implementation status

2. **[TODO.md](./TODO.md)** - Comprehensive development roadmap
   - Features that need to be built
   - Mock services that need real implementations
   - Integration points for backend/AI
   - Prioritized task list

## 🚀 Quick Start

```bash
# Build the app
make build

# Run on simulator
make run

# Run tests
make test

# Clean build artifacts
make clean
```

## 🛠 Tech Stack

- **Platform**: iOS 17+
- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Architecture**: MVVM with Dependency Injection
- **Build**: Xcode 15+

## 📱 Features

### Current (Working Features)
- ✅ **Real Authentication** - Email signup/login with backend API
- ✅ **Dynamic Goals** - Fetched from API
- ✅ **User Preferences** - Saved to backend
- ✅ **Stack Generation** - Real recommendations from API with supplement details
- ✅ **Supplement Management** - Active/inactive toggling with detailed info modal  
- ✅ **JWT Token Management** - Persistent authentication
- ✅ **AI-Powered Chat** - Full chat feature with session management
- ✅ **Chat Sessions** - Multiple conversations with history
- ✅ **Message Pagination** - Load older messages as needed
- ✅ **Offline Support** - Local caching for chat sessions and messages
- ✅ **Progress Tracking** - Daily intake logging via API
- ✅ **Complete onboarding flow** (10 screens including auth)
- ✅ **5-tab main app** (Stack, Schedule, Track, Chat, Profile)
- ✅ **Design system** with reusable components
- ✅ **Accessibility support**
- ⚠️ Sign in with Apple (UI only, not functional)
- ⚠️ Schedule and Export still using mock data

### Planned (See TODO.md)
- 🔄 Health app integration
- 🔄 Push notifications
- 🔄 In-app purchases
- 🔄 Advanced chat features (streaming, voice input)
- 🔄 Real PDF/calendar export
- 🔄 Biometric authentication

## 🏗 Project Structure

```
StackWise/
├── App/                 # App entry, DI, theme
├── Models/              # Data models
├── Services/            # Service layer (protocols + mocks)
├── DesignSystem/        # Reusable UI components
├── Features/            # Feature modules (MVVM)
│   ├── Onboarding/
│   ├── Stack/
│   ├── Schedule/
│   ├── Track/
│   ├── Chat/
│   └── Profile/
└── Utilities/           # Helper extensions
```

## 🤝 Contributing

1. Read [ARCHITECTURE_OVERVIEW.md](./ARCHITECTURE_OVERVIEW.md) to understand the codebase
2. Check [TODO.md](./TODO.md) for tasks to work on
3. Follow existing patterns and conventions
4. Test your changes with `make build`
5. Update documentation as needed

## 📄 License

[Add your license here]

## 📧 Contact

[Add contact information]

---

**Note for AI Assistants**: Start by reading ARCHITECTURE_OVERVIEW.md and TODO.md to understand the project context before making any changes.
