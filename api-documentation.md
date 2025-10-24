## StackWise API

This document provides everything a front-end developer needs to integrate with the StackWise API: database schemas, authentication, and detailed endpoint specs with examples.

### Base URL
- Use your environment’s base URL. Example: `https://xuy07kjq0b.execute-api.us-east-1.amazonaws.com/`
- In Postman, this is the `{{baseUrl}}` variable.

### Authentication
- All endpoints except signup/login/apple require a Bearer JWT in the `Authorization` header.
- Header format: `Authorization: Bearer <jwt>`
- Obtain a token via `POST /auth/signup`, `POST /auth/login`, or `POST /auth/apple`.

### Error Format
Errors return JSON with an `error` field and relevant HTTP status codes.

```json
{ "error": "Invalid or expired token" }
```

### Key TypeScript Interfaces

The API uses strongly-typed interfaces throughout. Key types for front-end development:

**TimeOfDay**: `"morning" | "afternoon" | "evening" | "night"`

**DayOfWeek**: `"Mon" | "Tue" | "Wed" | "Thu" | "Fri" | "Sat" | "Sun"`

**Sex**: `"male" | "female" | "other"`

**StimulantTolerance**: `"none" | "low" | "moderate" | "high"`

**DietaryFlag**: `"vegan" | "vegetarian" | "gluten_free" | "dairy_free" | "soy_free" | "nut_free"`

**Goal**: String literal type - see `/goals` endpoint for all 20 valid values (e.g., "Build Muscle", "Improve Sleep Quality")

**SupplementSchedule**:
```typescript
{
  daysOfWeek: DayOfWeek[];
  times: TimeOfDay[];
}
```

**StackSupplement**:
```typescript
{
  supplement_id: string;  // UUID
  name: string;
  dose: string;
  purpose: string;
  schedule: SupplementSchedule;
  tags: Goal[];
  rationale: string;
  active: boolean;
}
```

**IntakeLogEntry**:
```typescript
{
  supplement_id: string;  // UUID
  time: TimeOfDay;
}
```

---

## Chat Endpoints

The chat feature enables multi-session conversations with an AI assistant that knows about your supplements, preferences, and goals.

### Typical Chat Flow:
1. **Create a session**: `POST /chat/session` → Get `session_id`
2. **Send messages**: `POST /chat/session/{sessionId}/message` → Get AI response
3. **List sessions**: `GET /chat/sessions` → See all your conversations
4. **View history**: `GET /chat/session/{sessionId}` → See messages in a session

---

### POST /chat/session
Create a new chat session for the authenticated user.

**Purpose**: Initialize a new conversation thread. Each session is independent with its own message history.

**Authentication**: Required (JWT Bearer token)

**Request**:
```http
POST {{baseUrl}}chat/session
Authorization: Bearer {{jwt}}
Content-Type: application/json

{
  "title": "Questions about creatine timing"
}
```

**Request Body** (all fields optional):
- `title`: Session title (max 255 characters). If omitted, session has no title.

**Response** (201 Created):
```json
{
  "session_id": "550e8400-e29b-41d4-a716-446655440000",
  "title": "Questions about creatine timing",
  "created_at": "2024-10-20T10:30:00.000Z"
}
```

**Response Fields**:
- `session_id`: UUID to use for sending messages to this session
- `title`: The session title (null if not provided)
- `created_at`: ISO 8601 timestamp

**Front-End Usage**:
- Store the `session_id` to send messages to this conversation
- Create a new session for each new conversation topic
- Sessions persist forever (until explicitly deleted, if that feature is added)

**Error Responses**:
- 401: Invalid or missing JWT token
- 400: Title exceeds 255 characters
- 500: Database error

### GET /chat/sessions
List all chat sessions for the authenticated user, sorted by most recently active.

**Purpose**: Display user's conversation history. Use this to populate a chat list or sidebar.

**Authentication**: Required (JWT Bearer token)

**Request**:
```http
GET {{baseUrl}}chat/sessions?limit=20
Authorization: Bearer {{jwt}}
```

**Query Parameters**:
- `limit` (optional): Number of sessions to return (default: 20, max: 100)
- `cursor` (optional): Pagination cursor (use `next_cursor` from previous response)

**Response** (200 OK):
```json
{
  "sessions": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "user_id": "123e4567-e89b-12d3-a456-426614174000",
      "title": "Creatine questions",
      "created_at": "2024-10-20T10:30:00.000Z",
      "updated_at": "2024-10-20T15:45:00.000Z"
    },
    {
      "id": "550e8400-e29b-41d4-a716-446655440001",
      "user_id": "123e4567-e89b-12d3-a456-426614174000",
      "title": "Sleep supplement timing",
      "created_at": "2024-10-19T14:00:00.000Z",
      "updated_at": "2024-10-19T14:30:00.000Z"
    }
  ],
  "next_cursor": "2024-10-19T14:30:00.000Z"
}
```

**Response Fields**:
- `sessions`: Array of chat sessions
  - `id`: Session UUID
  - `user_id`: Owner's user ID
  - `title`: Session title (can be null)
  - `created_at`: When session was created
  - `updated_at`: Last message timestamp (used for sorting)
- `next_cursor`: Present only if more sessions exist (use for pagination)

**Sorting & Pagination**:
- Sessions are sorted by `updated_at DESC` (most recent first)
- When a new message is sent to a session, its `updated_at` is updated
- This naturally bubbles active conversations to the top
- To load more: Call again with `cursor={next_cursor}`

**Front-End Usage**:
```typescript
// Initial load
GET /chat/sessions?limit=20
// Returns sessions and next_cursor

// Load more (if next_cursor exists)
GET /chat/sessions?limit=20&cursor=2024-10-19T14:30:00.000Z
```

**Error Responses**:
- 401: Invalid or missing JWT token
- 500: Database error

### GET /chat/session/{sessionId}
Retrieve messages from a specific chat session.

**Purpose**: Load conversation history to display in the chat UI. Call this when user opens a conversation.

**Authentication**: Required (JWT Bearer token - must be session owner)

**Request**:
```http
GET {{baseUrl}}chat/session/550e8400-e29b-41d4-a716-446655440000?limit=50
Authorization: Bearer {{jwt}}
```

**Path Parameters**:
- `sessionId`: UUID of the chat session

**Query Parameters**:
- `limit` (optional): Number of messages to return (default: 50, max: 100)
- `before` (optional): ISO 8601 timestamp - fetch messages before this time (for loading older messages)

**Response** (200 OK):
```json
{
  "session": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "user_id": "123e4567-e89b-12d3-a456-426614174000",
    "title": "Supplement timing questions",
    "created_at": "2024-10-20T10:30:00.000Z",
    "updated_at": "2024-10-20T15:45:00.000Z"
  },
  "messages": [
    {
      "id": "msg-001",
      "session_id": "550e8400-e29b-41d4-a716-446655440000",
      "user_id": "123e4567-e89b-12d3-a456-426614174000",
      "role": "user",
      "content": "When should I take magnesium?",
      "created_at": "2024-10-20T10:31:00.000Z"
    },
    {
      "id": "msg-002",
      "session_id": "550e8400-e29b-41d4-a716-446655440000",
      "user_id": "123e4567-e89b-12d3-a456-426614174000",
      "role": "assistant",
      "content": "Magnesium glycinate is best taken in the evening, about 30-60 minutes before bed. This timing helps with sleep quality and allows for optimal absorption.",
      "created_at": "2024-10-20T10:31:05.000Z"
    },
    {
      "id": "msg-003",
      "session_id": "550e8400-e29b-41d4-a716-446655440000",
      "user_id": "123e4567-e89b-12d3-a456-426614174000",
      "role": "user",
      "content": "Can I take it with food?",
      "created_at": "2024-10-20T10:32:00.000Z"
    },
    {
      "id": "msg-004",
      "session_id": "550e8400-e29b-41d4-a716-446655440000",
      "user_id": "123e4567-e89b-12d3-a456-426614174000",
      "role": "assistant",
      "content": "Yes, taking magnesium with a light snack can help reduce any potential stomach upset. It doesn't significantly affect absorption.",
      "created_at": "2024-10-20T10:32:05.000Z"
    }
  ],
  "has_more": false
}
```

**Response Fields**:
- `session`: Complete session metadata
- `messages`: Array of messages in chronological order (oldest first)
  - `id`: Message UUID
  - `session_id`: Parent session UUID
  - `user_id`: Always matches the session owner
  - `role`: "user", "assistant", or "system"
  - `content`: Message text
  - `created_at`: ISO 8601 timestamp
- `has_more`: Boolean indicating if more messages exist before the oldest returned

**Message Ordering**:
- Messages are returned in **chronological order** (oldest first)
- This is ready to display in a chat UI from top to bottom
- Newest messages appear at the end of the array

**Pagination (Loading Older Messages)**:
```typescript
// Initial load (most recent 50 messages)
GET /chat/session/{sessionId}?limit=50
// Returns has_more: true

// Load older messages
GET /chat/session/{sessionId}?limit=50&before=2024-10-20T10:31:00.000Z
// Use the created_at of the oldest message you have
```

**Front-End Usage**:
- Call this when user selects a session from the list
- Display messages in chronological order
- If `has_more: true`, show "Load older messages" button
- Use the oldest message's `created_at` as the `before` cursor

**Ownership Validation**:
- The endpoint automatically verifies the session belongs to the authenticated user
- Returns 404 if session doesn't exist or belongs to another user

**Error Responses**:
- 404: Session not found or doesn't belong to user
- 400: Invalid session ID format (must be valid UUID)
- 401: Invalid or missing JWT token
- 500: Database error

### POST /chat/session/{sessionId}/message
Send a message to a chat session and receive an AI-generated response.

**Purpose**: Enable conversation with an AI assistant that has context about the user's supplements, preferences, and goals.

**Authentication**: Required (JWT Bearer token)

**Path Parameters**:
- `sessionId`: UUID of the chat session (must belong to the authenticated user)

**Request Body**:
```json
{
  "message": "Can I take creatine with coffee?"
}
```

**Request Field Validation**:
- `message`: Required, 1-4000 characters
- Must be non-empty after trimming whitespace

**Response** (200 OK):
```json
{
  "message_id": "7e3bd994-fd85-4e2f-aed1-4bcf3741105a",
  "content": "Yes, creatine can be taken with coffee. In fact, some studies suggest that caffeine may enhance creatine's performance benefits. However, it's best to stay well-hydrated when combining the two.",
  "role": "assistant",
  "created_at": "2025-10-21T22:02:45.664Z"
}
```

**Response Fields**:
- `message_id`: UUID of the saved assistant message
- `content`: The AI's response text
- `role`: Always "assistant"
- `created_at`: Timestamp when the message was created

**How It Works**:
1. Your message is saved to the database immediately
2. The AI generates a response using GPT-4o-mini
3. Context is automatically included:
   - User's goals from preferences
   - Age, sex, dietary preferences, stimulant tolerance
   - Active supplement stack (names and doses)
   - Last 6 messages from this conversation
4. The assistant's response is saved to the database
5. The session's `updated_at` timestamp is updated
6. The complete response is returned

**AI Context Example**:
The AI sees context like this:
```
User Profile:
- Goals: Build Muscle, Improve Sleep Quality
- Age: 28
- Sex: male
- Dietary: gluten_free
- Stimulant tolerance: moderate

Active Stack:
- Creatine Monohydrate: 5g
- Magnesium Glycinate: 400mg
- L-Theanine: 200mg
```

**Error Responses**:
- 404: Session not found or doesn't belong to user
- 400: Message is empty or exceeds 4000 characters
- 401: Invalid or missing JWT token
- 500: OpenAI API error or database error

**Important Notes for Front-End**:
- The endpoint saves BOTH the user's message AND the assistant's response
- After calling this endpoint, the session will contain 2 new messages (user + assistant)
- To display the full conversation, call `GET /chat/session/{sessionId}` after sending
- Or append the returned message directly to your local conversation state

---

## Complete Chat Implementation Example

Here's a complete workflow for implementing the chat feature in your iOS app:

### 1. Display Chat List (Sessions Screen)
```swift
// Fetch user's chat sessions
GET /chat/sessions?limit=20

// Display list showing:
// - session.title (or "New Chat" if null)
// - session.updated_at (format as "2 hours ago", "Yesterday", etc.)
// - Sorted by updated_at DESC (most recent at top)

// When user taps a session → Navigate to chat screen with session_id
// When user taps "New Chat" → Call POST /chat/session first
```

### 2. Open a Chat Session (Chat Screen)
```swift
// When opening session:
GET /chat/session/{sessionId}?limit=50

// This returns:
// - session metadata (title, timestamps)
// - messages array (chronological order)
// - has_more flag

// Display:
// - session.title in navigation bar
// - messages in chat bubbles (user messages on right, assistant on left)
// - If has_more==true, show "Load Earlier Messages" button at top
```

### 3. Send a Message
```swift
// When user types and sends:
POST /chat/session/{sessionId}/message
{
  "message": "User's typed message here"
}

// Returns assistant's response immediately:
{
  "message_id": "uuid",
  "content": "Assistant's response",
  "role": "assistant",
  "created_at": "2024-10-20T..."
}

// Update UI:
// 1. Add user's message bubble (use local text, current timestamp)
// 2. Show loading indicator for assistant
// 3. When response arrives, add assistant message bubble
// 4. No need to reload entire conversation - just append these 2 messages
```

### 4. Load Older Messages (Pagination)
```swift
// When user scrolls to top and taps "Load Earlier":
GET /chat/session/{sessionId}?limit=50&before={oldest_message_created_at}

// Prepend returned messages to your messages array
// Update has_more flag
```

### 5. Session Management
```swift
// Creating new session:
POST /chat/session { "title": "Supplement questions" }
// Returns session_id → Navigate to that session

// Switching sessions:
// Just change active session_id and load messages
// No need to close/cleanup previous session
```

### Key Implementation Tips:

**Local State Management**:
- Keep current `session_id` in state
- Keep `messages` array in state
- When sending message:
  1. Optimistically add user message to UI
  2. Show loading indicator
  3. When response comes, add assistant message
  4. Both are already saved server-side

**Session List Updates**:
- After sending a message, the session's `updated_at` changes
- You can either:
  - Refetch the sessions list to show updated order
  - Or locally update that session's timestamp

**Error Handling**:
- If send message fails, show retry button
- User message was still saved (check logs)
- Can safely retry the same message

**Offline Support**:
- Queue outgoing messages locally
- Send when connection restored
- Session state persists server-side

---

## Database Schemas

Below are the key tables and columns used by the API. Types are PostgreSQL.

### users
- `id` UUID PRIMARY KEY
- `email` TEXT UNIQUE NULLABLE
- `password_hash` TEXT NULLABLE
- `apple_sub` TEXT NULLABLE
- `created_at` TIMESTAMP DEFAULT now()

### user_preferences
- `id` UUID PRIMARY KEY
- `user_id` UUID NOT NULL REFERENCES users(id)
- `goals` TEXT[] NOT NULL (valid values from goals table)
- `age` INTEGER NULLABLE
- `sex` TEXT NULLABLE (valid: 'male', 'female', 'other')
- `height_cm` INTEGER NULLABLE
- `weight_kg` INTEGER NULLABLE
- `body_fat_pct` NUMERIC NULLABLE
- `stimulant_tolerance` TEXT NULLABLE (valid: 'none', 'low', 'moderate', 'high')
- `budget_usd` INTEGER NULLABLE
- `dietary_prefs` TEXT[] NOT NULL DEFAULT '{}' (e.g., 'vegan', 'vegetarian', 'gluten_free')
- `priority_text` TEXT NULLABLE
- `updated_at` TIMESTAMP DEFAULT now()

### supplements
- `id` UUID PRIMARY KEY
- `name` TEXT NOT NULL UNIQUE
- `purpose_short` TEXT NULLABLE (1 sentence overview)
- `purpose_long` TEXT NULLABLE (3-5 sentence overview)
- `scientific_function` TEXT NULLABLE (how the supplement works scientifically)
- `timing_tags` TEXT[] NOT NULL DEFAULT '{}' (valid: 'morning', 'afternoon', 'evening', 'night')
- `dietary_flags` TEXT[] NOT NULL DEFAULT '{}'
- `stimulant_free` BOOLEAN NOT NULL DEFAULT true
- `citations` TEXT[] NOT NULL DEFAULT '{}'

### stacks
- `id` UUID PRIMARY KEY
- `user_id` UUID NOT NULL REFERENCES users(id)
- `supplements` JSONB NOT NULL (array of StackSupplement objects - see below)
- `created_at` TIMESTAMP DEFAULT now()
- `active` BOOLEAN NOT NULL DEFAULT false
- `active_start` DATE NULLABLE (date when stack became active)
- `active_end` DATE NULLABLE (date when stack was deactivated)

**StackSupplement JSONB Schema:**
```json
{
  "supplement_id": "uuid",
  "name": "string",
  "dose": "string",
  "schedule": {
    "daysOfWeek": ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
    "times": ["morning", "afternoon", "evening", "night"]
  },
  "tags": ["Goal names from goals table"],
  "rationale": "1-2 sentence personalized explanation (e.g., 'Based on your goal to build muscle, creatine is excellent for strength gains.')",
  "active": true
}
```

### goals
- `id` UUID PRIMARY KEY DEFAULT uuid_generate_v4()
- `goal_name` TEXT NOT NULL (see /goals endpoint for valid values)
- Unique index on `goal_name`

### daily_intake_log
- `id` UUID PRIMARY KEY DEFAULT uuid_generate_v4()
- `user_id` UUID NOT NULL REFERENCES users(id)
- `stack_id` UUID NULLABLE REFERENCES stacks(id)
- `date` DATE NOT NULL
- `created_at` TIMESTAMP NOT NULL DEFAULT now()
- `entries` JSONB NOT NULL DEFAULT '[]' (array of IntakeLogEntry objects - see below)

**IntakeLogEntry JSONB Schema:**
```json
{
  "supplement_id": "uuid",
  "time": "morning | afternoon | evening | night"
}
```

### chat_sessions
- `id` UUID PRIMARY KEY DEFAULT gen_random_uuid()
- `user_id` UUID NOT NULL REFERENCES users(id)
- `title` TEXT NULLABLE
- `created_at` TIMESTAMP NOT NULL DEFAULT now()
- `updated_at` TIMESTAMP NOT NULL DEFAULT now()
- Indexes: user_id, updated_at DESC

### chat_messages
- `id` UUID PRIMARY KEY DEFAULT gen_random_uuid()
- `session_id` UUID NOT NULL REFERENCES chat_sessions(id)
- `user_id` UUID NOT NULL REFERENCES users(id)
- `role` TEXT NOT NULL CHECK (role IN ('user', 'assistant', 'system'))
- `content` TEXT NOT NULL
- `created_at` TIMESTAMP NOT NULL DEFAULT now()
- Indexes: session_id, user_id, created_at, (session_id, created_at DESC)

### schema_migrations (internal)
- `id` SERIAL PRIMARY KEY
- `filename` TEXT NOT NULL UNIQUE
- `applied_at` TIMESTAMP NOT NULL DEFAULT now()

### schema_seeds (internal)
- `id` SERIAL PRIMARY KEY
- `filename` TEXT NOT NULL UNIQUE
- `applied_at` TIMESTAMP NOT NULL DEFAULT now()

---

## Endpoints

All JSON bodies are UTF-8 encoded. Unless otherwise stated, responses are JSON.

### Auth

#### POST /auth/signup
Creates a new user with email/password and returns a JWT.

Request
```http
POST {{baseUrl}}auth/signup
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "Password123!"
}
```

Response (201)
```json
{
  "token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "user@example.com",
    "created_at": "2025-01-01T00:00:00.000Z"
  },
  "has_active_stack": false,
  "needs_onboarding": true
}
```

**Response Fields:**
- `has_active_stack`: Whether the user has an active stack (always `false` for new signups)
- `needs_onboarding`: Whether the user needs to go through the onboarding flow (always `true` for new signups)

Errors
- 400 if invalid input
- 409 if email already exists

#### POST /auth/login
Logs in an existing user and returns a JWT.

Request
```http
POST {{baseUrl}}auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "Password123!"
}
```

Response (200)
```json
{
  "token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "user@example.com",
    "created_at": "2025-01-01T00:00:00.000Z"
  },
  "has_active_stack": true,
  "needs_onboarding": false
}
```

**Response Fields:**
- `has_active_stack`: Whether the user has an active stack
- `needs_onboarding`: Whether the user needs to go through the onboarding flow
- **Front-end logic**: If `has_active_stack` is `true` (or `needs_onboarding` is `false`), skip onboarding and go directly to the main app

Errors
- 401 if credentials invalid

#### POST /auth/apple
Verifies an Apple identity token; upserts a user and returns a JWT.

Request
```http
POST {{baseUrl}}auth/apple
Content-Type: application/json

{
  "identityToken": "<apple_identity_token>",
  "email": "optional@domain.com"
}
```

Response (200)
```json
{
  "token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "optional@domain.com",
    "created_at": "2025-01-01T00:00:00.000Z"
  },
  "has_active_stack": false,
  "needs_onboarding": true
}
```

**Response Fields:**
- `has_active_stack`: Whether the user has an active stack
- `needs_onboarding`: Whether the user needs to go through the onboarding flow
- Values depend on whether this is a new Apple user or a returning user

Errors
- 401 if Apple token invalid

---

### User Preferences

Requires Authorization header.

#### POST /preferences
Create or update the current user’s preferences.

Request
```http
POST {{baseUrl}}preferences
Content-Type: application/json
Authorization: Bearer {{jwt}}

{
  "goals": [
    "Build Muscle",
    "Improve Sleep Quality"
  ],
  "age": 28,
  "sex": "male",
  "height_cm": 180,
  "weight_kg": 75,
  "body_fat_pct": 15.5,
  "stimulant_tolerance": "moderate",
  "budget_usd": 120,
  "dietary_prefs": ["gluten_free"],
  "priority_text": "Focus on energy and recovery"
}
```

Response (201 for create, 200 for update)
```json
{
  "message": "Preferences created successfully",
  "preferences": {
    "id": "550e8400-e29b-41d4-a716-446655440001",
    "user_id": "550e8400-e29b-41d4-a716-446655440000",
    "goals": ["Build Muscle", "Improve Sleep Quality"],
    "age": 28,
    "sex": "male",
    "height_cm": 180,
    "weight_kg": 75,
    "body_fat_pct": 15.5,
    "stimulant_tolerance": "moderate",
    "budget_usd": 120,
    "dietary_prefs": ["gluten_free"],
    "priority_text": "Focus on energy and recovery",
    "updated_at": "2025-01-01T00:00:00.000Z"
  }
}
```

**Notes:**
- All fields except `goals` are optional
- Valid values for `sex`: "male", "female", "other"
- Valid values for `stimulant_tolerance`: "none", "low", "moderate", "high"
- Valid values for `dietary_prefs`: "vegan", "vegetarian", "gluten_free", "dairy_free", "soy_free", "nut_free"
- Valid values for `goals`: See `/goals` endpoint for full list

Errors
- 400 if `goals` missing or empty
- 401 if token missing/invalid

#### GET /preferences
Fetch the current user’s preferences.

Request
```http
GET {{baseUrl}}preferences
Authorization: Bearer {{jwt}}
```

Response (200)
```json
{
  "preferences": {
    "id": "550e8400-e29b-41d4-a716-446655440001",
    "user_id": "550e8400-e29b-41d4-a716-446655440000",
    "goals": ["Build Muscle", "Improve Sleep Quality"],
    "age": 28,
    "sex": "male",
    "height_cm": 180,
    "weight_kg": 75,
    "body_fat_pct": 15.5,
    "stimulant_tolerance": "moderate",
    "budget_usd": 120,
    "dietary_prefs": ["gluten_free"],
    "priority_text": "Focus on energy and recovery",
    "updated_at": "2025-01-01T00:00:00.000Z"
  }
}
```

Errors
- 401 if token missing/invalid
- 404 if no preferences set for user

---

### Goals

Requires Authorization header.

#### GET /goals
Returns the list of all supported goals. Use these values when setting user preferences.

Request
```http
GET {{baseUrl}}goals
Authorization: Bearer {{jwt}}
```

Response (200)
```json
{
  "goals": [
    { "id": "550e8400-e29b-41d4-a716-446655440010", "goal_name": "Build Muscle" },
    { "id": "550e8400-e29b-41d4-a716-446655440011", "goal_name": "Increase Strength" },
    { "id": "550e8400-e29b-41d4-a716-446655440012", "goal_name": "Improve Endurance" },
    { "id": "550e8400-e29b-41d4-a716-446655440013", "goal_name": "Boost Energy (non-stimulant)" },
    { "id": "550e8400-e29b-41d4-a716-446655440014", "goal_name": "Improve Sleep Quality" }
  ]
}
```

**Note:** The response includes 20 total goals. See the database seeds for the complete list.

---

### Stacks

Requires Authorization header.

#### POST /stack/generate
Generates and stores a supplement stack for the current user based on their goals and preferences. Uses OpenAI GPT-4o-mini to intelligently select supplements and create personalized dosing schedules.

**Important Behavior:**
- Automatically deactivates any currently active stacks (sets `active=false`, `active_end=today`)
- Sets the new stack as active (sets `active=true`, `active_start=today`)
- Ensures only one stack is active at a time

Request
```http
POST {{baseUrl}}stack/generate
Authorization: Bearer {{jwt}}
```

Response (201)
```json
{
  "stack": {
    "id": "550e8400-e29b-41d4-a716-446655440020",
    "user_id": "550e8400-e29b-41d4-a716-446655440000",
    "supplements": [
      {
        "supplement_id": "550e8400-e29b-41d4-a716-446655440100",
        "name": "Creatine Monohydrate",
        "dose": "5g",
        "schedule": {
          "daysOfWeek": ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
          "times": ["morning"]
        },
        "tags": ["Build Muscle", "Increase Strength"],
        "rationale": "Based on your goals to build muscle and increase strength, creatine is one of the most well-researched supplements for enhancing power output and supporting muscle growth.",
        "active": true
      },
      {
        "supplement_id": "550e8400-e29b-41d4-a716-446655440101",
        "name": "Magnesium Glycinate",
        "dose": "400mg",
        "schedule": {
          "daysOfWeek": ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
          "times": ["evening"]
        },
        "tags": ["Improve Sleep Quality"],
        "rationale": "Given your goal to improve sleep quality, magnesium glycinate is highly bioavailable and helps with sleep onset and quality without morning grogginess.",
        "active": true
      }
    ],
    "created_at": "2025-01-01T00:00:00.000Z",
    "active": true,
    "active_start": "2025-01-01",
    "active_end": null
  },
  "message": "Stack generated successfully"
}
```

**Response Schema Notes:**
- `supplements`: Array of `StackSupplement` objects
  - `supplement_id`: UUID of the supplement from the supplements table
  - `name`: Supplement name
  - `dose`: Dosage recommendation (e.g., "5g", "400mg")
  - `schedule`: When to take it
    - `daysOfWeek`: Array of day abbreviations (Mon-Sun)
    - `times`: Array of TimeOfDay values ("morning", "afternoon", "evening", "night")
  - `tags`: Goal names this supplement addresses (from user's selected goals)
  - `rationale`: Personalized 1-2 sentence explanation written directly to the user (e.g., "Based on your goal to build muscle, creatine is excellent for strength gains.")
  - `active`: Whether this supplement is currently active in the user's routine
- `active`: Whether this stack is currently active (automatically set to `true` on creation)
- `active_start`: The date when this stack became active
- `active_end`: The date when this stack was deactivated (null if currently active)

Errors
- 400 if user has no goals set
- 401 if token missing/invalid
- 404 if user preferences not found

#### GET /stack/current
Fetch the most recently created stack for the current user.

Request
```http
GET {{baseUrl}}stack/current
Authorization: Bearer {{jwt}}
```

Response (200)
```json
{
  "stack": {
    "id": "550e8400-e29b-41d4-a716-446655440020",
    "user_id": "550e8400-e29b-41d4-a716-446655440000",
    "supplements": [
      {
        "supplement_id": "550e8400-e29b-41d4-a716-446655440100",
        "name": "Creatine Monohydrate",
        "dose": "5g",
        "schedule": {
          "daysOfWeek": ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
          "times": ["morning"]
        },
        "tags": ["Build Muscle", "Increase Strength"],
        "rationale": "Based on your goals to build muscle and increase strength, creatine is one of the most well-researched supplements for enhancing power output and supporting muscle growth.",
        "active": true
      }
    ],
    "created_at": "2025-01-01T00:00:00.000Z",
    "active": true,
    "active_start": "2025-01-01",
    "active_end": null
  }
}
```

**Note:** Returns the same stack structure as `/stack/generate`. See that endpoint for detailed schema information. The `active_start` and `active_end` fields track when this stack was/is active.

Errors
- 401 if token missing/invalid
- 404 if no stack exists for the user

#### PATCH /stack/{stackId}/supplements
Toggle the active status of one or more supplements within a stack (batch operation).

**Purpose**: Allow users to mark supplements as active/inactive without modifying the entire stack. Inactive supplements won't show in daily intake tracking. Supports batch updates for efficiency.

**Authentication**: Required (JWT Bearer token - must be stack owner)

**Path Parameters**:
- `stackId`: UUID of the stack

**Request**:
```http
PATCH {{baseUrl}}stack/550e8400-e29b-41d4-a716-446655440020/supplements
Authorization: Bearer {{jwt}}
Content-Type: application/json

{
  "updates": [
    {
      "supplement_id": "550e8400-e29b-41d4-a716-446655440100",
      "active": false
    },
    {
      "supplement_id": "550e8400-e29b-41d4-a716-446655440101",
      "active": true
    }
  ]
}
```

**Request Body**:
- `updates`: Array of supplement status updates, each with:
  - `supplement_id`: UUID of the supplement to update
  - `active`: Boolean - `true` to activate, `false` to deactivate

**Response** (200 OK):
```json
{
  "message": "Supplement statuses updated",
  "updated_count": 2,
  "updates": [
    {
      "supplement_id": "550e8400-e29b-41d4-a716-446655440100",
      "active": false
    },
    {
      "supplement_id": "550e8400-e29b-41d4-a716-446655440101",
      "active": true
    }
  ]
}
```

**Use Cases**:
- User doesn't want to take specific supplements → Set multiple to `active: false` at once
- User wants to pause entire stack → Set all to `active: false` in one request
- User wants to customize their routine → Mix of true/false for different supplements
- Efficient bulk operations → Update multiple supplements with single API call

**Important Notes**:
- All updates are processed atomically (all succeed or all fail)
- Supplements remain in the stack (not deleted)
- Inactive supplements are excluded from daily intake schedules
- Can toggle individual or multiple supplements
- Does not affect other supplements not in the updates array

Errors
- 400 if stackId or updates array is missing/empty
- 400 if any update is missing supplement_id or active field
- 401 if token missing/invalid
- 404 if stack not found or doesn't belong to user
- 404 if any supplement_id not found in the stack (returns list of not_found IDs)

---

### Daily Intake Log

Requires Authorization header.

#### POST /intake/log
Batch logs or removes supplement intakes for a specific date. Processes multiple supplement entries in a single request for efficiency.

**Duplicate Prevention**: If an entry with the same `supplement_id` and `time` already exists, it will not be added again (silently ignored).

Request
```http
POST {{baseUrl}}intake/log
Authorization: Bearer {{jwt}}
Content-Type: application/json

{
  "date": "2025-10-08",
  "entries": [
    {
      "supplement_id": "550e8400-e29b-41d4-a716-446655440100",
      "time": "morning",
      "taken": true
    },
    {
      "supplement_id": "550e8400-e29b-41d4-a716-446655440101",
      "time": "evening",
      "taken": true
    },
    {
      "supplement_id": "550e8400-e29b-41d4-a716-446655440102",
      "time": "afternoon",
      "taken": false
    }
  ]
}
```

**Request Fields:**
- `date`: Date string in YYYY-MM-DD format (can be historical, not just today)
- `entries`: Array of intake entry objects, each with:
  - `supplement_id`: UUID of the supplement being logged/removed
  - `time`: Time of day, must be one of: "morning", "afternoon", "evening", "night"
  - `taken`: Boolean - `true` to add entry, `false` to remove entry

**Processing Logic:**
- All entries in the batch are processed atomically for the specified date
- Entries with `taken: true` are added (unless duplicate)
- Entries with `taken: false` are removed
- If no log exists for the date, creates one using the user's active stack
- If log exists, updates the entries array

Response (200 - Updated existing log)
```json
{
  "log": {
    "id": "550e8400-e29b-41d4-a716-446655440030",
    "user_id": "550e8400-e29b-41d4-a716-446655440000",
    "stack_id": "550e8400-e29b-41d4-a716-446655440020",
    "date": "2025-10-08",
    "created_at": "2025-10-08T10:00:00.000Z",
    "entries": [
      {
        "supplement_id": "550e8400-e29b-41d4-a716-446655440100",
        "time": "morning"
      },
      {
        "supplement_id": "550e8400-e29b-41d4-a716-446655440101",
        "time": "evening"
      }
    ]
  },
  "message": "Intake log updated successfully"
}
```

Response (201 - Created new log)
```json
{
  "log": {
    "id": "550e8400-e29b-41d4-a716-446655440030",
    "user_id": "550e8400-e29b-41d4-a716-446655440000",
    "stack_id": "550e8400-e29b-41d4-a716-446655440020",
    "date": "2025-10-08",
    "created_at": "2025-10-08T10:00:00.000Z",
    "entries": [
      {
        "supplement_id": "550e8400-e29b-41d4-a716-446655440100",
        "time": "morning"
      }
    ]
  },
  "message": "Intake log created successfully"
}
```

**Response Schema Notes:**
- `entries`: Array of `IntakeLogEntry` objects
  - `supplement_id`: UUID of the supplement that was taken
  - `time`: TimeOfDay value when it was taken ("morning", "afternoon", "evening", "night")
- `stack_id`: Links to the active stack at the time of log creation
- `date`: The date (YYYY-MM-DD) this log is for

Errors
- 400 if `date` or `entries` array is missing/empty
- 400 if date format is invalid
- 400 if any entry is missing required fields (supplement_id, time, taken)
- 400 if time is not a valid TimeOfDay value
- 400 if user has no active stack (when creating new log)
- 401 if token missing/invalid

#### GET /intake/logs
Retrieves all daily intake logs for the current user within a specified date range.

Request
```http
GET {{baseUrl}}intake/logs?start_date=2025-10-01&end_date=2025-10-31
Authorization: Bearer {{jwt}}
```

**Query Parameters:**
- `start_date`: Start date in YYYY-MM-DD format (inclusive)
- `end_date`: End date in YYYY-MM-DD format (inclusive)

Response (200)
```json
{
  "stacks": [
    {
      "stack_id": "550e8400-e29b-41d4-a716-446655440020",
      "logs": [
        {
          "id": "550e8400-e29b-41d4-a716-446655440030",
          "user_id": "550e8400-e29b-41d4-a716-446655440000",
          "stack_id": "550e8400-e29b-41d4-a716-446655440020",
          "date": "2025-10-05",
          "created_at": "2025-10-05T10:00:00.000Z",
          "entries": [
            {
              "supplement_id": "550e8400-e29b-41d4-a716-446655440100",
              "time": "morning"
            },
            {
              "supplement_id": "550e8400-e29b-41d4-a716-446655440101",
              "time": "evening"
            }
          ]
        },
        {
          "id": "550e8400-e29b-41d4-a716-446655440031",
          "user_id": "550e8400-e29b-41d4-a716-446655440000",
          "stack_id": "550e8400-e29b-41d4-a716-446655440020",
          "date": "2025-10-06",
          "created_at": "2025-10-06T09:30:00.000Z",
          "entries": [
            {
              "supplement_id": "550e8400-e29b-41d4-a716-446655440100",
              "time": "morning"
            }
          ]
        }
      ]
    },
    {
      "stack_id": "550e8400-e29b-41d4-a716-446655440019",
      "logs": [
        {
          "id": "550e8400-e29b-41d4-a716-446655440032",
          "user_id": "550e8400-e29b-41d4-a716-446655440000",
          "stack_id": "550e8400-e29b-41d4-a716-446655440019",
          "date": "2025-10-03",
          "created_at": "2025-10-03T08:00:00.000Z",
          "entries": [
            {
              "supplement_id": "550e8400-e29b-41d4-a716-446655440102",
              "time": "morning"
            }
          ]
        }
      ]
    }
  ]
}
```

**Response Notes:**
- Logs are grouped by `stack_id` to separate current and historical stacks
- Within each stack group, logs are sorted by date in ascending order (earliest first)
- If no logs exist in the date range, returns an empty `stacks` array
- Each log follows the same `DailyIntakeLog` schema as the `/intake/log` endpoint
- This grouping allows front-end to easily distinguish between active and historical stack usage

Errors
- 400 if start_date or end_date is missing
- 400 if date format is invalid
- 400 if start_date is after end_date
- 401 if token missing/invalid

---

### Analytics

Requires Authorization header.

#### GET /analytics/weekly-intake
Retrieves 7 days of historical intake data starting from the specified date. For each day, shows the active stack and which supplements were taken.

Request
```http
GET {{baseUrl}}analytics/weekly-intake?start_date=2025-10-06
Authorization: Bearer {{jwt}}
```

**Query Parameters:**
- `start_date`: Start date in YYYY-MM-DD format (returns this day + 6 more days)

Response (200)
```json
{
  "week_data": [
    {
      "date": "2025-10-06",
      "stack_id": "550e8400-e29b-41d4-a716-446655440020",
      "stack_intake_data": [
        {
          "supplement_id": "550e8400-e29b-41d4-a716-446655440100",
          "supplement_name": "Creatine Monohydrate",
          "time": "morning",
          "taken": true
        },
        {
          "supplement_id": "550e8400-e29b-41d4-a716-446655440101",
          "supplement_name": "Magnesium Glycinate",
          "time": "evening",
          "taken": false
        }
      ]
    },
    {
      "date": "2025-10-07",
      "stack_id": "550e8400-e29b-41d4-a716-446655440020",
      "stack_intake_data": [
        {
          "supplement_id": "550e8400-e29b-41d4-a716-446655440100",
          "supplement_name": "Creatine Monohydrate",
          "time": "morning",
          "taken": true
        },
        {
          "supplement_id": "550e8400-e29b-41d4-a716-446655440101",
          "supplement_name": "Magnesium Glycinate",
          "time": "evening",
          "taken": true
        }
      ]
    }
  ]
}
```

**Response Notes:**
- Always returns exactly 7 days of data (start_date + 6 days)
- `stack_intake_data` includes all scheduled supplements for that day's stack
- Each supplement appears once per scheduled time (e.g., if scheduled for both morning and evening, appears twice)
- `taken` field indicates whether the user marked that specific supplement+time as taken

**Stack Determination Logic:**
1. **If daily_intake_log exists for the date**: Uses the `stack_id` from that log
2. **For past dates without a log**: Finds the stack that was active on that date using `active_start` and `active_end` dates
3. **For future dates**: Uses the currently active stack
4. **Result**: Always shows supplements with `taken=false` for future dates

**Data Completeness:**
- Even if no supplements were marked as taken, `stack_intake_data` still shows all scheduled supplements from the active stack
- Empty `stack_intake_data` only occurs if no stack was active on that date
- Calculated live by combining data from `stacks` and `daily_intake_log` tables

**Use Case:**
This endpoint is perfect for displaying weekly views where users can see:
- Their adherence to their supplement schedule
- Historical changes in their stack
- Which supplements they consistently take vs. skip

Errors
- 400 if start_date is missing
- 400 if date format is invalid
- 401 if token missing/invalid

---

## Implementation Notes

- Authorization is via Bearer JWT; obtain via signup/login/apple and include on protected endpoints.
- Arrays returned from preferences (e.g., `goals`, `dietary_prefs`) are JSON arrays of strings.
- Generated stacks are stored as JSONB arrays with supplement details; front-end can render directly.

## Postman

- Collection: `postman/StackWise.postman_collection.json`
- Environment: `postman/StackWise.postman_environment.json`
- Set `baseUrl` to your API Gateway URL. Use Signup/Login to populate `{{jwt}}` automatically via test scripts.



# Schema Updates - StackWise API

This document tracks recent schema changes that affect the front-end application. Use this alongside the API_README.md to understand what has changed in the API responses.

---

## Update 1: Removed `purpose` Field from Stack Supplements (October 2025)

### What Changed

The `StackSupplement` object in the `stacks` table's `supplements` JSONB column has been updated.

**Before:**
```typescript
{
  supplement_id: string;
  dose: string;
  name: string;
  purpose: string;        // ← REMOVED
  schedule: SupplementSchedule;
  tags: Goal[];
  rationale: string;      // ← ENHANCED
  active: boolean;
}
```

**After:**
```typescript
{
  supplement_id: string;
  dose: string;
  name: string;
  schedule: SupplementSchedule;
  tags: Goal[];
  rationale: string;      // Now contains personalized explanation
  active: boolean;
}
```

### Why This Changed

- **Removed**: `purpose` field (was duplicate of rationale)
- **Enhanced**: `rationale` now contains 1-2 sentence personalized explanation written in second person

### Rationale Field Enhancement

The `rationale` field is now AI-generated text that:
- Speaks directly to the user (second person: "you", "your")
- Explains WHY this supplement was selected for THIS specific user
- References user's goals and profile

**Example rationale text:**
```
"Based on your goal to build muscle and improve gym performance, creatine is an excellent choice for increasing strength and power output."
```

### Affected Endpoints

#### POST /stack/generate
**Response changed:**
```json
{
  "stack": {
    "supplements": [
      {
        "supplement_id": "uuid",
        "name": "Creatine Monohydrate",
        "dose": "5g",
        "schedule": {
          "daysOfWeek": ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
          "times": ["morning"]
        },
        "tags": ["Build Muscle", "Increase Strength"],
        "rationale": "Based on your goals to build muscle and increase strength, creatine is one of the most well-researched supplements for enhancing power output and supporting muscle growth.",
        "active": true
      }
    ]
  }
}
```

**NoteMenu`purpose` field is no longer present in the response.

#### GET /stack/current
Same change - `purpose` field removed from each supplement object.

#### GET /analytics/weekly-intake
The `stack_intake_data` items don't include full supplement details, so this endpoint is unaffected.

### Front-End Migration

**Swift Model Update:**
```swift
struct StackSupplement: Codable {
    let supplementId: String
    let name: String
    let dose: String
    // let purpose: String  // ← REMOVE THIS
    let schedule: SupplementSchedule
    let tags: [String]
    let rationale: String  // Keep this, now has personalized content
    let active: Bool
}
```

**UI Update:**
```swift
// Before:
Text(supplement.purpose)  // Generic purpose

// After:
Text(supplement.rationale)  // Personalized "why this for you"
```

### Database Schema

The `stacks` table's `supplements` JSONB column stores these objects. No database migration needed - it's just JSON data. Existing stacks will have both fields, new stacks will only have `rationale`.

### Backward Compatibility

If you have locally cached stacks with the old schema:
- Old stacks will have both `purpose` and `rationale` (ignore `purpose`)
- New stacks will only have `rationale`
- Your Swift model can handle this by making `purpose` optional during transition, then removing it

---

## Update 2: Enhanced Supplement Descriptions (October 2025)

### What Changed

The `supplements` table schema has been updated with more detailed description fields.

**Before:**
```sql
CREATE TABLE supplements (
  id UUID,
  name TEXT,
  purpose TEXT,           -- ← REMOVED
  ...
);
```

**After:**
```sql
CREATE TABLE supplements (
  id UUID,
  name TEXT,
  purpose_short TEXT,     -- ← NEW: 1 sentence overview
  purpose_long TEXT,      -- ← NEW: 3-5 sentence overview
  scientific_function TEXT, -- ← NEW: Scientific explanation
  ...
);
```

### Why This Changed

- **More granularity**: Apps can choose which level of detail to display
- **User education**: `scientific_function` helps users understand HOW supplements work
- **Better UX**: Short descriptions for lists, long descriptions for detail views

### New Fields Explained

1. **purpose_short** (1 sentence)
   - Quick overview for list views
   - Example: "Supports muscle strength, power output, and cognitive function"

2. **purpose_long** (3-5 sentences)
   - Detailed overview for detail/info views
   - Explains benefits and use cases
   - Example: "Creatine monohydrate is one of the most researched supplements for athletic performance. It enhances strength, increases muscle mass..."

3. **scientific_function** (3-5 sentences)
   - Technical explanation of mechanism of action
   - For users who want to understand the science
   - Example: "Creatine increases phosphocreatine stores in muscles, enabling rapid ATP regeneration..."

### Affected Endpoints

#### None (supplements table is reference data)

The supplements table is used internally by the API to generate stacks, but supplement details are not directly exposed to the front-end through any current endpoints.

**Note**: If you add an endpoint to browse/search supplements in the future, it will include these new fields.

### Database Migration

**Migration**: `migrations/0004_update_supplement_descriptions.sql`

This migration:
1. Adds three new TEXT columns
2. Populates data for all 5 existing supplements
3. Drops the old `purpose` column

### Front-End Impact

**No immediate action required** - This change is internal to the API.

However, if you later add features to display supplement information (e.g., "Learn More" about a supplement), you can query these fields.

### Sample Data

**Creatine Monohydrate:**
- purpose_short: "Supports muscle strength, power output, and cognitive function"
- purpose_long: "Creatine monohydrate is one of the most researched supplements for athletic performance. It enhances strength, increases muscle mass, improves high-intensity exercise performance, and may support cognitive function and brain health."
- scientific_function: "Creatine increases phosphocreatine stores in muscles, enabling rapid ATP regeneration during high-intensity activities..."

---

## Future Updates

Additional schema changes will be documented here as they occur.

### Template for Future Updates:

```markdown
## Update N: [Title] (Date)

### What Changed
- Describe the change

### Why This Changed
- Reason for the change

### Affected Endpoints
- List endpoints with before/after examples

### Front-End Migration
- Code changes needed

### Backward Compatibility
- How to handle transition
```

