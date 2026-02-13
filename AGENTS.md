# Project Instructions

Guidelines for AI agents working on this codebase.

---

## Development

### Build & Test Verification

Before completing any development task, always verify the following:

1. **No Build Failures**
   - Run `xcodebuild` or use the IDE to confirm the project compiles successfully
   - Resolve any build failures before marking the task as complete

2. **No Test Failures**
   - Run the test suite to check for failures
   - If test failures are **caused by new development**, fix them before completing the task
   - If test failures are **unrelated** to the current work, report back to the user:
     - Which tests are failing
     - Confirmation that the failures are pre-existing and unrelated to the development done

### Implementation Plans

When creating an implementation plan in "Plan" mode:

- Always include a **final step** that verifies:
  - No build failures
  - No test failures (or unrelated failures documented)
- This ensures every plan ends with a working, verified codebase

