# StackWise iOS App - Development TODO

## Overview
This document tracks all remaining work to transform the current UI scaffold into a production-ready iOS application. Items are organized by priority and category.

## 🔴 Critical Path (Must Have for Launch)

### 1. Backend Infrastructure
- [x] **API Design & Implementation**
  - [x] Design RESTful API schema
  - [x] Set up backend infrastructure (AWS API Gateway + Lambda)
  - [x] Implement user authentication endpoints (/auth/signup, /auth/login)
  - [ ] Implement Apple Sign In endpoint (/auth/apple)
  - [x] Create basic supplement database
  - [x] Build basic recommendation engine API (/stack/generate)
  - [x] Implement user data storage endpoints (/preferences)
  - [x] Set up secure API authentication (JWT)

### 2. Authentication System
- [x] **Build Authentication UI**
  - [x] Create welcome screen with auth options
  - [x] Build login screen with email/password
  - [x] Build signup screen with validation
  - [x] Add Sign in with Apple button UI
  - [x] Mock authentication flow (accepts any credentials)
- [x] **Implement Real Authentication (Partial)**
  - [x] Connect to backend authentication API
  - [x] Implement JWT token storage
  - [x] Handle auth state persistence
  - [x] Create NetworkManager for API calls
  - [x] Implement login/signup with email
- [ ] **Remaining Authentication Tasks**
  - [ ] Implement real Sign in with Apple (AuthenticationServices framework)
  - [ ] Add biometric authentication (Face ID/Touch ID)
  - [ ] Implement secure token storage (Keychain instead of UserDefaults)
  - [ ] Add session refresh/expiry management
  - [ ] Implement logout/account deletion flow
  - [ ] Add account recovery options
  - [ ] Add email verification
  - [ ] Implement password reset flow

### 3. AI/LLM Integration for Recommendations
- [x] **Basic Recommendation Service**
  - [x] Implement RealRecommendationService
  - [x] Connect to /stack/generate endpoint
  - [x] Save preferences before generating stack
  - [x] Fetch current stack on app load
- [ ] **Advanced Recommendation Features**
  - [ ] Integrate LLM API (OpenAI/Claude/Custom)
  - [ ] Design prompt engineering for supplement recommendations
  - [ ] Implement safety filters for medical conditions
  - [ ] Add interaction checking between supplements
  - [ ] Add real PubMed citation fetching

### 4. AI Chat Assistant
- [x] **Replace MockChatService** (December 2024)
  - [x] Integrate with backend Chat API endpoints
  - [x] Implement RealChatService with session management
  - [x] Add conversation context management (user profile & stack)
  - [x] Build chat sessions list screen
  - [x] Implement chat conversation view with pagination
  - [x] Add conversation history persistence (local caching)
  - [x] Build suggested queries UI based on user stack
  - [x] Handle message sending and AI responses
- [ ] **Advanced Chat Features**
  - [ ] Implement streaming responses (when API supports it)
  - [ ] Add session renaming functionality
  - [ ] Implement session deletion
  - [ ] Add message search within sessions
  - [ ] Create supplement-specific knowledge base enhancements
  - [ ] Add export chat history feature
  - [ ] Implement typing indicators
  - [ ] Add voice input support

### 5. Data Persistence
- [ ] **Local Storage**
  - [ ] Migrate from UserDefaults to Core Data
  - [ ] Design Core Data schema for all models
  - [ ] Implement data migration strategy
  - [ ] Add offline queue for pending operations
  - [ ] Cache supplement database locally
  - [ ] Store chat history locally

- [ ] **Cloud Sync**
  - [ ] Implement CloudKit integration
  - [ ] Design conflict resolution strategy
  - [ ] Add background sync
  - [ ] Handle multiple device sync
  - [ ] Implement data export/import

### 6. Real Supplement Database
- [ ] **Data Collection**
  - [ ] Source verified supplement information
  - [ ] Create comprehensive ingredient database
  - [ ] Add interaction warnings database
  - [ ] Include dosage guidelines
  - [ ] Add form factors (capsule, powder, liquid)
  - [ ] Include pricing information
  - [ ] Add brand recommendations

### 7. Notification System
- [ ] **Replace Mock Scheduling**
  - [ ] Implement real iOS local notifications
  - [ ] Add smart reminder timing
  - [ ] Create notification content extensions
  - [ ] Add notification actions (mark taken, snooze)
  - [ ] Implement notification analytics
  - [ ] Add push notification support

## 🟡 Important Features (High Priority)

### 8. Tracking & Analytics
- [ ] **User Analytics**
  - [ ] Integrate analytics SDK (Mixpanel/Amplitude/PostHog)
  - [ ] Track user journey events
  - [ ] Monitor feature usage
  - [ ] Track supplement compliance
  - [ ] Add crash reporting (Sentry/Crashlytics)
  - [ ] Implement A/B testing framework

- [ ] **Health Tracking**
  - [ ] Integrate with HealthKit
  - [ ] Track supplement intake in Health app
  - [ ] Read relevant health metrics
  - [ ] Correlate supplements with health outcomes
  - [ ] Add progress charts and visualizations

### 9. Export & Sharing Features
- [ ] **Replace MockExportService**
  - [ ] Generate real PDF reports
  - [ ] Create proper ICS calendar files
  - [ ] Add sharing via ShareSheet
  - [ ] Implement email export
  - [ ] Add provider letter generation
  - [ ] Create supplement summary cards for sharing

### 10. In-App Purchases / Monetization
- [ ] **StoreKit Integration**
  - [ ] Design subscription tiers (Free/Premium/Pro)
  - [ ] Implement StoreKit 2
  - [ ] Add receipt validation
  - [ ] Create paywall screens
  - [ ] Implement restore purchases
  - [ ] Add promotional offers
  - [ ] Handle subscription management

### 11. Onboarding Improvements
- [ ] **Medical Validation**
  - [ ] Add comprehensive medication database
  - [ ] Implement serious interaction checking
  - [ ] Add pregnancy/nursing specific logic
  - [ ] Create age-specific recommendations
  - [ ] Add more granular health conditions

### 12. Safety & Compliance
- [ ] **Medical Disclaimers**
  - [ ] Add comprehensive legal disclaimers
  - [ ] Implement consent management
  - [ ] Add HIPAA compliance if needed
  - [ ] Create terms of service
  - [ ] Add privacy policy
  - [ ] Implement GDPR compliance
  - [ ] Add age verification

## ✅ Recently Completed (December 2024)

### API Integration Phase 1
- [x] **Networking Infrastructure**
  - [x] Created NetworkManager for API calls
  - [x] Implemented JWT token storage
  - [x] Created API models and conversion logic
  - [x] Error handling for network requests

- [x] **Authentication Integration**
  - [x] RealAuthService implementation
  - [x] Login endpoint integration (/auth/login)
  - [x] Signup endpoint integration (/auth/signup)
  - [x] Token persistence across app launches

- [x] **Goals & Preferences**
  - [x] RealGoalsService implementation
  - [x] Dynamic goals loading from API (/goals)
  - [x] RealPreferencesService implementation
  - [x] Save preferences endpoint (/preferences POST)
  - [x] Fetch preferences endpoint (/preferences GET)

- [x] **Stack Generation**
  - [x] RealRecommendationService implementation
  - [x] Stack generation endpoint (/stack/generate)
  - [x] Fetch current stack endpoint (/stack/current)
  - [x] Onboarding flow saves to API and generates real stack

- [x] **Chat Feature Implementation**
  - [x] RealChatService implementation with full API integration
  - [x] Chat sessions management (/chat/session, /chat/sessions)
  - [x] Message sending and receiving (/chat/session/{id}/message)
  - [x] Session history and pagination support
  - [x] ChatSessionsView for listing all conversations
  - [x] ChatConversationView for individual chats
  - [x] Local caching for offline support
  - [x] Contextual suggestions based on user's stack

- [x] **Stack Screen Enhancement** (October 2025)
  - [x] Updated Supplement model with purposeShort, purposeLong, scientificFunction
  - [x] Created SupplementDetailSheet with bottom sheet modal
  - [x] Implemented PATCH /stack/{stackId}/supplements integration
  - [x] Added active/inactive supplement filtering
  - [x] Optimistic UI updates for supplement toggling
  - [x] Show/hide inactive supplements feature
  - [x] Stack ID tracking for API integration

- [x] **App Infrastructure Updates**
  - [x] DIContainer updated to use real services
  - [x] Toggle between mock and real services
  - [x] Automatic stack loading for returning users
  - [x] Goals screen dynamically loads from API

## 🟢 Nice to Have (Post-Launch)

### 13. Enhanced Features
- [ ] **Barcode Scanning**
  - [ ] Add supplement barcode scanner
  - [ ] Create product database
  - [ ] Auto-fill supplement information

- [ ] **Social Features**
  - [ ] Add stack sharing
  - [ ] Create community reviews
  - [ ] Implement expert verification badges

- [ ] **Advanced Tracking**
  - [ ] Add symptom tracking
  - [ ] Create mood/energy logs
  - [ ] Build correlation analysis
  - [ ] Add photo progress tracking

- [ ] **Personalization**
  - [ ] Add genetic testing integration (23andMe)
  - [ ] Implement blood work analysis
  - [ ] Create seasonal adjustments
  - [ ] Add lifestyle-based modifications

### 14. Platform Expansion
- [ ] **Apple Watch App**
  - [ ] Create WatchKit app
  - [ ] Add quick logging
  - [ ] Implement complications
  - [ ] Add reminder notifications

- [ ] **iPad Optimization**
  - [ ] Create iPad-specific layouts
  - [ ] Add split-view support
  - [ ] Optimize for larger screens

- [ ] **Mac Catalyst**
  - [ ] Port to macOS
  - [ ] Add keyboard shortcuts
  - [ ] Implement menu bar app

### 15. Performance & Polish
- [ ] **Optimization**
  - [ ] Profile and optimize performance
  - [ ] Reduce app size
  - [ ] Optimize image assets
  - [ ] Implement lazy loading
  - [ ] Add progressive disclosure

- [ ] **Animations**
  - [ ] Add micro-interactions
  - [ ] Create smooth transitions
  - [ ] Add haptic feedback
  - [ ] Implement success animations

## 🔧 Technical Debt & Improvements

### Code Quality
- [ ] Add comprehensive unit tests
- [ ] Implement UI tests
- [ ] Add snapshot tests
- [ ] Set up CI/CD pipeline
- [ ] Add code documentation
- [ ] Implement error tracking
- [ ] Add performance monitoring

### Architecture Improvements
- [ ] Consider migrating to TCA or similar
- [ ] Add proper navigation coordinator
- [ ] Implement deep linking
- [ ] Add universal links support
- [ ] Create feature flags system
- [ ] Add remote configuration

### Developer Experience
- [ ] Add SwiftLint rules
- [ ] Create component library documentation
- [ ] Add Xcode templates
- [ ] Create contribution guidelines
- [ ] Add PR templates
- [ ] Set up development environment scripts

## 📱 App Store Requirements

### Submission Checklist
- [ ] App Store screenshots (all device sizes)
- [ ] App preview video
- [ ] App description and keywords
- [ ] Privacy policy URL
- [ ] Support URL
- [ ] Age rating questionnaire
- [ ] Export compliance
- [ ] App icon (all sizes)
- [ ] Launch screen

### Testing Requirements
- [ ] TestFlight beta testing
- [ ] Device compatibility testing
- [ ] Accessibility audit
- [ ] Performance testing
- [ ] Security audit
- [ ] Localization testing

## 🎯 Current Implementation Status

### What's Done
- ✅ Complete UI/UX scaffold
- ✅ All screens and navigation
- ✅ Design system components
- ✅ Basic state management
- ✅ Accessibility support
- ✅ Real backend API integration for core features
- ✅ Authentication (email/password)
- ✅ User preferences and goals
- ✅ Stack generation via API
- ✅ AI-powered chat assistant with session management
- ✅ Local caching for offline support

### What's Partially Complete
- ⚠️ Sign in with Apple (UI present, not functional)
- ⚠️ Schedule service (still mocked)
- ⚠️ Export service (still mocked)
- ⚠️ Data persistence (using UserDefaults, needs Core Data)

### What's Completely Missing
- ❌ Real supplement database with full details
- ❌ Push notifications
- ❌ Analytics tracking
- ❌ In-app purchases
- ❌ Health app integration
- ❌ Real PDF/calendar export
- ❌ Biometric authentication
- ❌ Advanced LLM features (streaming, etc.)

## 🚀 Recommended Development Order

### Phase 1: Core Infrastructure (Weeks 1-4)
1. Set up backend infrastructure
2. Implement authentication
3. Create basic API endpoints
4. Add data persistence

### Phase 2: Core Features (Weeks 5-8)
1. Integrate basic LLM for recommendations
2. Build supplement database
3. Implement real scheduling
4. Add basic chat functionality

### Phase 3: Safety & Compliance (Weeks 9-10)
1. Add medical safety checks
2. Implement legal requirements
3. Add privacy/security features

### Phase 4: Polish & Monetization (Weeks 11-12)
1. Add in-app purchases
2. Integrate analytics
3. Performance optimization
4. App Store preparation

### Phase 5: Launch & Iterate (Ongoing)
1. Beta testing
2. App Store submission
3. Post-launch features
4. User feedback implementation

## 📝 Notes for Implementation

### When Replacing Mock Services
1. Keep service protocols unchanged
2. Create new implementations alongside mocks
3. Use feature flags to toggle between mock/real
4. Test thoroughly before removing mocks
5. Consider keeping mocks for testing/development

### API Integration Approach
1. Start with most critical endpoints
2. Use URLSession or Alamofire
3. Implement proper error handling
4. Add retry logic
5. Cache responses appropriately

### LLM Integration Considerations
1. Cost management is critical
2. Implement caching for common queries
3. Add fallback logic for API failures
4. Consider on-device models for privacy
5. Monitor and log for quality assurance

### Data Migration Strategy
1. Version all data models
2. Create migration paths
3. Test with various data sizes
4. Handle edge cases gracefully
5. Provide user feedback during migration

## 🔄 Living Document Notes

This TODO list should be updated as:
- Tasks are completed (mark with ✅)
- New requirements emerge (add to appropriate section)
- Priorities change (reorder items)
- Technical decisions are made (add implementation notes)

Last Updated: December 2024
Next Review: Weekly

---

**Remember**: This is a marathon, not a sprint. Focus on shipping a solid MVP with core features rather than trying to build everything at once.
