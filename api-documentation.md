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
- `name` TEXT NOT NULL
- `purpose` TEXT NULLABLE
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
  "purpose": "string",
  "schedule": {
    "daysOfWeek": ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
    "times": ["morning", "afternoon", "evening", "night"]
  },
  "tags": ["Goal names from goals table"],
  "rationale": "string",
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
  "token": "<jwt_token_here>",
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
  "token": "<jwt_token_here>",
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
  "token": "<jwt_token_here>",
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
Generates and stores a supplement stack for the current user based on their goals and preferences. Uses OpenAI GPT-4-turbo to intelligently select supplements and create personalized dosing schedules.

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
        "purpose": "Supports muscle growth and strength gains",
        "schedule": {
          "daysOfWeek": ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
          "times": ["morning"]
        },
        "tags": ["Build Muscle", "Increase Strength"],
        "rationale": "Creatine is one of the most well-researched supplements for muscle building and strength enhancement.",
        "active": true
      },
      {
        "supplement_id": "550e8400-e29b-41d4-a716-446655440101",
        "name": "Magnesium Glycinate",
        "dose": "400mg",
        "purpose": "Improves sleep quality and promotes relaxation",
        "schedule": {
          "daysOfWeek": ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
          "times": ["evening"]
        },
        "tags": ["Improve Sleep Quality"],
        "rationale": "Magnesium glycinate is highly bioavailable and helps with sleep onset and quality.",
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
  - `purpose`: Why this supplement is included
  - `schedule`: When to take it
    - `daysOfWeek`: Array of day abbreviations (Mon-Sun)
    - `times`: Array of TimeOfDay values ("morning", "afternoon", "evening", "night")
  - `tags`: Goal names this supplement addresses
  - `rationale`: AI-generated explanation for inclusion
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
        "purpose": "Supports muscle growth and strength gains",
        "schedule": {
          "daysOfWeek": ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
          "times": ["morning"]
        },
        "tags": ["Build Muscle", "Increase Strength"],
        "rationale": "Creatine is one of the most well-researched supplements for muscle building and strength enhancement.",
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


