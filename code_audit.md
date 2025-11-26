# StackWise iOS App - Code Audit

**Date:** November 18, 2025  
**Last Updated:** November 19, 2025  
**Purpose:** Comprehensive audit to identify loose ends, bugs, UX issues, naming inconsistencies, and areas for improvement

**Recent Changes (Nov 19, 2025):**
- ✅ Removed export functionality from Stack screen (Issue #4)
- ✅ Removed export methods from Profile (Issue #6)  
- ✅ Added sign out confirmation alert and loading state (Issue #7)
- ✅ Removed MockScheduleService and MockExportService (Issue #9)

---

## 🔴 Critical Issues

### 1. **Apple Sign In Not Implemented**
**Location:** `OnboardingViewModel.swift` (lines 295-326)  
**Issue:** The `signInWithApple()` method is still using mock data instead of real Apple Sign In implementation.  
**Impact:** Users attempting to sign in with Apple will receive mock user data instead of authenticating with Apple.  
**Recommendation:** Implement real Apple Sign In using `AuthenticationServices` framework, or temporarily hide the button until implemented.  
**Test:** Try tapping "Continue with Apple" button on any authentication screen.

### 2. **Phone Signup Not Implemented**
**Location:** `SignupScreen.swift` (lines 546-552)  
**Issue:** Phone number signup shows an error message saying "Phone signup not yet implemented".  
**Impact:** Users selecting phone as their contact method cannot sign up.  
**Recommendation:** Either implement phone signup or remove the phone option from signup (keep it for login only where it works).  
**Test:** On signup screen, select phone number option, fill out form, and try to sign up.

---

## 🟡 High Priority Issues

### 3. **Missing Error Toast on Supplement Toggle Failure**
**Location:** `StackViewModel.swift` (line 97)  
**Issue:** TODO comment exists: `// TODO: Show error toast`. When toggling a supplement active/inactive fails, the state is reverted but no user feedback is shown.  
**Impact:** Poor UX - users won't know the operation failed.  
**Recommendation:** Implement error toast to show "Failed to update supplement" when the API call fails.  
**Test:** Force API to fail during supplement toggle operation.

### 4. **~~Export Stack Button Has No Loading State~~** ✅ FIXED
**Status:** REMOVED - Export button and functionality removed entirely per user request.  
**Changes Made:** 
- Removed export button from StackView toolbar
- Removed `exportStack()` method from StackViewModel
- Removed export success toast from StackView

### 5. **Remix Stack Button No Loading State**
**Location:** `StackView.swift` (line 71-75), `StackViewModel.swift` (lines 27-47)  
**Issue:** When "Remix Stack" is tapped, the button has no loading state while preferences are being fetched.  
**Impact:** No feedback to user during network operation.  
**Recommendation:** Add loading state to the button or show loading overlay while fetching preferences.  
**Test:** Tap "Remix Stack" and observe the flow - there's a network call with no loading indicator.

### 6. **~~Profile Export Buttons No Loading States~~** ✅ FIXED
**Status:** REMOVED - Export functionality removed entirely per user request.  
**Changes Made:**
- Removed `exportPDF()` method from ProfileViewModel
- Removed `exportCalendar()` method from ProfileViewModel
- Removed `showExportSuccess` state and toast from ProfileView

### 7. **~~Sign Out No Loading State~~** ✅ FIXED
**Status:** FIXED - Sign out now has confirmation alert and loading state.  
**Changes Made:**
- Added `showSignOutAlert` property to ProfileViewModel
- Updated sign out button to trigger confirmation alert first
- Added loading state to `signOut()` method in ProfileViewModel
- Sign out button now shows "Are you sure?" alert before proceeding
- Loading spinner shows during sign out process

### 8. **Delete Account No Loading State**
**Location:** `ProfileViewModel.swift` (lines 107-114), `ProfileView.swift` (lines 311-330)  
**Issue:** Delete account action has no loading indicator while the async operation runs.  
**Impact:** User has no feedback during account deletion.  
**Recommendation:** Show loading overlay or disable button during deletion.  
**Test:** Try to delete account and observe no loading feedback.

---

## 🟢 Medium Priority Issues

### 9. **~~Services Still Using Mocks~~** ✅ FIXED
**Status:** REMOVED - Mock services deleted entirely per user request.  
**Changes Made:**
- Deleted `MockScheduleService.swift` and `ScheduleService.swift` protocol
- Deleted `MockExportService.swift` and `ExportService.swift` protocol
- Removed `scheduleService` and `exportService` from DIContainer
- Updated TodayViewModel to generate reminders only from current stack (no fallback to service)
- Reminders are now purely derived from the user's stack, not persisted separately

### 10. **Empty State "Get Started" Button Does Nothing**
**Location:** `StackView.swift` (line 235-239)  
**Issue:** The EmptyStateView has a "Get Started" button with a TODO comment and empty action.  
**Impact:** Button doesn't work if user somehow sees this state.  
**Recommendation:** Either implement the action to navigate to onboarding or remove the button (users shouldn't see this screen anyway if they completed onboarding).  
**Test:** This state is hard to reach, but the button action is empty.

### 11. **Legal Links Do Nothing**
**Location:** `ProfileView.swift` (lines 350-372)  
**Issue:** Terms of Service, Privacy Policy, and Safety Disclaimers buttons have empty actions.  
**Impact:** Buttons are visible but don't work.  
**Recommendation:** Either implement these to open URLs/sheets, or hide this section until documents are ready (per user's note that these are placeholders).  
**Test:** Tap any legal link in Profile - nothing happens.

### 12. **Password Reset From Profile Pre-fills But Can Fail Silently**
**Location:** `ProfileView.swift` (lines 413-477)  
**Issue:** When initiating password reset from profile, the contact info is pre-filled. However, there's no validation that the user actually has the contact method they're trying to use.  
**Impact:** Minor UX issue - form will fail when trying to send code.  
**Recommendation:** Add validation or disable the contact method toggle if user doesn't have that method.  
**Test:** Create account with only email, then try to change password using phone number option.

### 13. **Chat Conversation Missing Optimistic Update**
**Location:** `ChatViewModel.swift` (lines 41-74)  
**Issue:** When sending a message, it's added to messages array immediately (line 47), but if the API call fails, the message is not removed from the array.  
**Impact:** Failed messages stay in the UI.  
**Recommendation:** This might be intentional for retry functionality, but consider adding error state to Message model and showing failed messages differently.  
**Test:** Force chat API to fail and observe message behavior.

### 14. **Profile Update Success Message Auto-Dismisses Sheet**
**Location:** `ProfileEditViewModel.swift` (lines 99-100), `ProfileEditSheet.swift` (lines 198-202)  
**Issue:** Success message shows for 2 seconds, then the sheet dismisses. This happens very fast and user might miss it.  
**Impact:** User might not see confirmation of successful update.  
**Recommendation:** Either show success message for longer, or dismiss immediately and show toast on parent view.  
**Test:** Edit profile, save changes, observe quick success message before dismiss.

---

## 📝 Naming & Convention Issues

### 15. **Inconsistent Service Naming**
**Location:** `DIContainer.swift`, various service files  
**Issue:** Services are named `RealXXXService` vs mocks named `MockXXXService`, but when mocks become real, the "Real" prefix is redundant.  
**Impact:** Naming becomes outdated as features are completed.  
**Recommendation:** Consider renaming `RealXXXService` to `XXXServiceImpl` or `DefaultXXXService` for clarity.  
**Note:** This is low priority, more of a style preference.

### 16. **"Track" Tab Confusion**
**Location:** `StackWiseApp.swift` (line 84-88)  
**Issue:** The tab is labeled "History" in the UI, but the view and view model are named `TrackView` and `TrackViewModel`.  
**Impact:** No functional impact, but naming mismatch between code and UI could confuse developers.  
**Recommendation:** This appears intentional - "Track" is the feature name, "History" is user-facing label. Consider adding comments to clarify this is intentional.  
**Note:** Actually, on review this seems fine - Track is the broader feature that includes historical tracking.

---

## 🐛 Potential Bugs

### 17. **Forgot Password Timer Leak**
**Location:** `ForgotPasswordViewModel.swift` (lines 28-30, 117-118)  
**Issue:** `codeExpirationTime` and `resendCooldown` are published properties but no timer is actually managing them.  
**Impact:** The countdown timer component might not work properly without an actual timer updating these values.  
**Recommendation:** Review `CountdownTimer` component usage in `PasswordResetScreen.swift` - the timer is created there, so this might be working as intended.  
**Test:** Trigger password reset flow and verify countdown works correctly.

### 18. **Loading Bubble Animation Timer Leak**
**Location:** `ChatView.swift` (lines 126-131)  
**Issue:** A `Timer` is scheduled in `onAppear` but never invalidated.  
**Impact:** Timer continues running even after view disappears, potential memory leak.  
**Recommendation:** Store timer reference and invalidate in `onDisappear` or use a different animation approach.  
**Test:** Enter and exit chat multiple times - timers may accumulate.

### 19. **IntakeLogManager Potential Race Condition**
**Location:** `IntakeLogManager.swift` (lines 120-136)  
**Issue:** `isSending` flag prevents concurrent sends, but if a send fails, pending changes are cleared anyway (line 135).  
**Impact:** If user toggles multiple supplements rapidly and one fails, all pending changes are lost.  
**Recommendation:** Only clear pendingChanges for items that were successfully sent. Track which items were in the current batch.  
**Test:** Toggle multiple supplements rapidly, force one to fail, verify all changes are applied.

### 20. **Profile Budget Update Has No Effect**
**Location:** `ProfileViewModel.swift` (lines 50-54)  
**Issue:** `updateBudget()` method updates local user but has a TODO: "Trigger stack regeneration with new budget". Budget change doesn't actually do anything.  
**Impact:** Users can change budget in profile but it has no effect.  
**Recommendation:** Either implement the regeneration trigger or remove the ability to change budget from profile (make it only editable during onboarding/remix).  
**Test:** Try changing budget in profile - it updates locally but doesn't affect stack.

### 21. **Onboarding Export for Hard-Stop Cases Returns Nil**
**Location:** `OnboardingViewModel.swift` (lines 184-188)  
**Issue:** `exportSummaryForClinician()` has TODO and always returns nil.  
**Impact:** Hard-stop risk flow mentions exporting for clinician but doesn't work.  
**Recommendation:** Either implement or remove the feature mention from UX flow.  
**Test:** Trigger hard-stop risk in onboarding - export option doesn't work.

---

## 🎨 UX Improvements

### 22. **No Error Handling for Stack Load Failure**
**Location:** `StackViewModel.swift` (lines 64-69)  
**Issue:** `loadStack()` silently fails if the API call fails - no error message shown to user.  
**Impact:** If stack load fails, user sees loading then nothing - unclear what happened.  
**Recommendation:** Show error state or retry option when stack loading fails.  
**Test:** Force stack/current endpoint to fail and observe user experience.

### 23. **No Retry Mechanism for Failed Job Polling**
**Location:** `DIContainer.swift` (lines 123-160)  
**Issue:** Stack generation polling has auto-retry for the entire job (once), but if a single poll request fails due to network, the whole generation fails.  
**Impact:** Temporary network issues can fail the entire stack generation.  
**Recommendation:** Add retry logic for individual poll requests, not just job retries.  
**Test:** Simulate intermittent network during stack generation.

### 24. **Today View Loads Data on Init But No Error State**
**Location:** `TodayViewModel.swift` (lines 61-84, 87-109)  
**Issue:** Both `loadReminders()` and `loadTodayData()` catch errors and print to console but show no error state to user.  
**Impact:** If loading fails, user sees empty screen with no explanation.  
**Recommendation:** Add error state and retry option.  
**Test:** Force tracking API to fail and observe Today screen behavior.

### 25. **Track View Same Issue as Today View**
**Location:** `TrackViewModel.swift` (lines 47-62)  
**Issue:** `loadWeekData()` fails silently with no user feedback.  
**Impact:** Failed loads show no data with no explanation.  
**Recommendation:** Add error state and retry option.  
**Test:** Force weekly tracking API to fail.

### 26. **Chat Sessions Load Shows Stale Cache on Error**
**Location:** `ChatSessionsView.swift` (lines 239-260)  
**Issue:** If fresh sessions fail to load but cached sessions exist, the error is silently ignored.  
**Impact:** User might be looking at stale data without knowing.  
**Recommendation:** Show a subtle indicator that data might be stale (e.g., last updated timestamp).  
**Test:** Force sessions API to fail with existing cache.

### 27. **No Pull-to-Refresh on Key Screens**
**Missing on:**
- StackView
- TodayView  
- TrackView

**Present on:**
- ChatSessionsView ✓

**Impact:** Users can't manually refresh data on most screens.  
**Recommendation:** Add pull-to-refresh to Stack, Today, and Track views.  
**Test:** Try to pull-to-refresh on each screen.

### 28. **Remix Stack Confirmation Wording**
**Location:** `StackView.swift` (lines 108-117)  
**Issue:** Alert says "cannot be recovered" which is technically true but sounds more severe than it is (they can just remix again).  
**Impact:** Might scare users unnecessarily.  
**Recommendation:** Consider softer wording like "This will replace your current stack with a new one based on your updated preferences."  
**Note:** This is subjective - current wording might be intentionally strong.

---

## 🔍 Code Quality & Consistency

### 29. **Inconsistent Date Formatting**
**Locations:** Multiple files  
**Issue:** Date formatters are created inline throughout the codebase instead of being centralized.  
**Impact:** Potential performance impact from repeated formatter creation; inconsistent formats possible.  
**Recommendation:** Create centralized `DateFormatter` utility with reusable formatters.  
**Example locations:**
- `TrackViewModel.swift` line 101, 134, 179
- `TodayViewModel.swift` line 101
- `IntakeLogManager.swift` line 34, 68

### 30. **Phone Number Formatting Duplicated**
**Locations:** 
- `LoginScreen.swift` (lines 407-428)
- `SignupScreen.swift` (lines 487-508)
- `ProfileEditViewModel.swift` (lines 115-136, 139-145)
- `ProfileView.swift` (lines 213-224)

**Issue:** Same phone formatting logic exists in 4 different places.  
**Impact:** Bug fixes need to be applied in multiple places; inconsistency risk.  
**Recommendation:** Extract to utility function in `Extensions.swift`.

### 31. **TODO Comments Left in Production Code**
**All TODO locations:**
1. `StackViewModel.swift:97` - Show error toast
2. `ProfileViewModel.swift:53` - Trigger stack regeneration
3. `StackView.swift:236` - Navigate to onboarding
4. `OnboardingViewModel.swift:185` - Implement PDF export
5. `RealAuthService.swift:16` - Implement real Apple Sign In
6. `RealRecommendationService.swift:63` - Implement actual remix logic when API supports it
7. `ChatConversationView.swift:331` - Implement session rename API endpoint when available

**Recommendation:** Track these in TODO.md instead of inline comments, or create GitHub issues.

### 32. **Timer Leak in GeneratingScreen**
**Location:** `GeneratingScreen.swift` (lines 95-100)  
**Issue:** A `Timer` is scheduled in `onAppear` to cycle through loading messages but is never invalidated.  
**Impact:** Timer continues running after the view disappears, potential memory leak.  
**Recommendation:** Store timer reference and invalidate in `onDisappear`.  
**Test:** Go through onboarding flow multiple times - timers may accumulate.

### 33. **Remix Logic Not Implemented**
**Location:** `RealRecommendationService.swift` (line 63)  
**Issue:** TODO comment indicates remix logic is not actually implemented in the API service.  
**Impact:** Remix feature may not work as expected.  
**Recommendation:** Verify with backend if remix endpoint is functional or if it's still TODO.  
**Test:** Try remixing a stack and verify it actually generates a different stack based on new options.

### 34. **Chat Session Rename Not Implemented**
**Location:** `ChatConversationView.swift` (line 331)  
**Issue:** TODO comment indicates session rename endpoint is not available yet.  
**Impact:** Users cannot rename chat sessions (feature may be visible but non-functional).  
**Recommendation:** Either hide rename option or show "Coming soon" message when tapped.  
**Test:** Try to rename a chat session.

---

## ✅ Good Practices Observed

The following areas demonstrate good implementation:

1. **Optimistic UI Updates:** Supplement toggling in Stack and intake logging in Today/Track views update UI immediately before API calls.

2. **Smart Debouncing:** `IntakeLogManager` implements intelligent debouncing and batching for intake logging.

3. **Loading States:** Most API calls properly show loading states (with exceptions noted above).

4. **Error Handling:** Most network operations have try-catch with error handling (though user feedback could be improved in some cases).

5. **Caching:** Chat service implements local caching for offline support.

6. **Job Polling with Backgrounding:** Stack generation properly handles app backgrounding with job polling resume.

7. **Accessibility:** Use of semantic colors through Theme system supports light/dark mode.

8. **Type Safety:** Good use of Swift enums and type-safe models throughout.

---

## 📊 Summary Statistics

- **Critical Issues:** 2
- **High Priority Issues:** 4 (2 fixed ✅)
- **Medium Priority Issues:** 6 (3 fixed ✅)
- **Naming Issues:** 2
- **Potential Bugs:** 5
- **UX Improvements:** 7
- **Code Quality Issues:** 3

**Total Issues Found:** 34  
**Issues Fixed:** 4 ✅  
**Remaining Issues:** 30

---

## 🎯 Recommended Action Plan

### Phase 1 - Critical (Do Before Launch)
1. Implement Apple Sign In or hide the button
2. Implement phone signup or remove the option
3. Add error toasts for failed operations
4. Add loading states to all async buttons

### Phase 2 - High Priority (Do Soon)
5. Implement export services or clearly mark as "Coming Soon"
6. Add pull-to-refresh on main screens
7. Implement error states with retry options
8. Fix TODO items or remove dead code

### Phase 3 - Quality of Life (Post-Launch)
9. Extract duplicate formatting logic to utilities
10. Centralize date formatters
11. Add stale data indicators
12. Refine service naming conventions

---

## 📝 Notes

- Most "mock" services are intentionally mocked per TODO.md and are documented
- Legal/Terms placeholders are expected per user's note
- Overall code quality is good with consistent patterns
- The app appears functional with the noted exceptions
- Main gaps are in error handling UX and loading state feedback


