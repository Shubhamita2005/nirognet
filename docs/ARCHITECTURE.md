# NirogNet — Architecture

## System Overview

NirogNet uses a client-server architecture:

- **Flutter client** (`client/`) — mobile frontend for Android (and potentially iOS/web)
- **Flask REST API** (`server/`) — Python backend exposing JSON endpoints
- **PostgreSQL database** — accessed via SQLAlchemy ORM
- **Google Gemini AI** — used for symptom analysis and emergency first-aid guidance
- **Razorpay** — payment processing for consultation bookings

All communication between client and server is over HTTP using JSON. The client stores a JWT access token in secure storage and attaches it as a Bearer header on authenticated requests.

---

## Backend Architecture

### Entry Point

`server/run.py` calls `create_app()` and starts Flask on `host='0.0.0.0', port=5000, debug=True`.

### App Factory (`server/app/__init__.py`)

Flask uses an application factory pattern. `create_app()`:

1. Calls `load_dotenv()` to read `server/.env`
2. Creates the Flask instance
3. Enables CORS for all routes (`Flask-CORS`)
4. Sets configuration: `DATABASE_URL`, `SECRET_KEY`, `JWT_SECRET_KEY`, `JWT_ACCESS_TOKEN_EXPIRES=30 days`
5. Initialises extensions: `db.init_app(app)`, `jwt.init_app(app)`
6. Configures Gemini: reads `GEMINI_API_KEY`, creates `genai.GenerativeModel("gemini-2.5-flash")`, stores on `app.gemini_model`
7. Registers JWT error handlers (expired token, invalid token, missing token)
8. Attaches a `before_request` logger for `/api/` routes
9. Registers Blueprints: `main_bp`, `auth_bp`, `symptom_bp`, `emergency_chat_bp`, `medicine_bp` (prefix `/api`), `book_bp`
10. Adds a `/health` endpoint that returns `{db: "ok", gemini: bool}`

### Layer Structure

```
Request
  -> Route (Blueprint)   routes/*.py        URL binding, HTTP method
  -> Controller          controllers/*.py   Validation, orchestration
  -> Service             services/*.py      Business logic, external API calls
  -> Model               models/models.py   SQLAlchemy ORM, DB operations
```

#### Routes

Each feature area has a Blueprint:

| Blueprint | File | Prefix |
|---|---|---|
| `main_bp` | `routes/main_routes.py` | (none) |
| `auth_bp` | `routes/auth_routes.py` | `/api` |
| `symptom_bp` | `routes/symptom_routes.py` | `/api` |
| `emergency_chat_bp` | `routes/emergency_chat_routes.py` | `/api` |
| `medicine_bp` | `routes/medicine_availablity_routes.py` | `/api` |
| `book_bp` | `routes/book_consultation_routes.py` | (contains full paths) |

#### Controllers

Controllers validate the incoming request (check required fields, types, length limits), call the appropriate service function, and return `jsonify(...)` responses with HTTP status codes.

Notable: `symptom_controller.py` enforces:
- Non-empty `symptoms` field
- Must be a string
- Minimum 3 characters
- Maximum 2000 characters

`emergency_chat_controller.py` enforces the same limits on `message`, calls the Gemini service, and queries the `Hospital` database table to attach hospital records (returned without geographic proximity filtering) to the response.

#### Services

Services contain business logic and external API calls, keeping controllers thin:

| Service | Responsibility |
|---|---|
| `symptom_checker_service.py` | Calls Gemini with symptom prompt; falls back to keyword-match mock |
| `emergency_gemini_service.py` | Calls Gemini with emergency system prompt; returns fallback string if model absent |
| `book_consultation_services.py` | Slot generation, consultation creation, Razorpay order creation/verification |
| `medicine_availablity_service.py` | SQLAlchemy queries for medicines: all, by name, by category, by ID |

#### Middleware

`auth_middleware.py` provides two reusable helpers:

- `get_current_user()` — extracts user from JWT via `get_jwt_identity()`, queries DB, returns `(user, None)` or `(None, error_response)`
- `require_fields(*fields)` — checks that named fields exist in the JSON request body

These are called explicitly by controllers, not as Flask decorators.

---

## Database Architecture

**Technology:** PostgreSQL (connected via `DATABASE_URL` env var, accessed through SQLAlchemy 2.0)

### Models

```
User
  id, email (unique), password_hash
  name, age, gender, contact, address
  blood_group, blood_pressure, language

Hospital
  id, name, distance, doctors (int), beds, ventilators, blood

Specialty
  id, name (unique)

Doctor
  id, name, specialty_id (FK -> Specialty), available (bool), contact

DoctorSchedule  [table: doctor_schedule]
  id
  doctor_id  (FK -> Doctor)
  hospital_id (FK -> Hospital)
  day_of_week (e.g. "Monday")
  start_time, end_time (Time)

AppointmentType
  id, name, description, icon

Consultation
  id
  user_id (FK -> User)
  doctor_id (FK -> Doctor)
  appointment_type_id (FK -> AppointmentType, nullable)
  date_time (DateTime)
  status  ("pending" / "confirmed")
  UNIQUE constraint on (doctor_id, date_time)  -- prevents double-booking

Medicine  [table: medicines]
  id, name, category, description, created_at

Payment
  id
  consultation_id (FK -> Consultation)
  amount (int, stored in INR)
  status ("pending" / "success")
  razorpay_order_id, razorpay_payment_id
  payment_method, created_at
```

### Key Relationships

```
Specialty 1---* Doctor
Doctor    1---* DoctorSchedule ---* Hospital
Doctor    1---* Consultation
User      1---* Consultation
Consultation 1---* Payment
AppointmentType 1---* Consultation
```

### Slot Generation Logic

`get_available_slots(doctor_id, date)` in `book_consultation_services.py`:

1. Converts `date` to day name (e.g., "Monday")
2. Queries `DoctorSchedule` for that doctor and day
3. Generates 15-minute slots between `start_time` and `end_time`
4. Queries `Consultation` for already-booked slots on that date
5. Marks overlapping slots `available: false`
6. Returns the full slot list

---

## Authentication Architecture

### Registration

```
POST /api/register {email, password, name?, contact?}
  -> auth_controller.register()
  -> Check User.query.filter_by(email=email).first() -- duplicate check
  -> user = User(email=email)
  -> user.set_password(password)  -- Werkzeug generate_password_hash()
  -> db.session.add(user); db.session.commit()
  <- 201 {msg: "User registered"}
```

### Login

```
POST /api/login {email, password}
  -> auth_controller.login()
  -> User.query.filter_by(email=email).first()
  -> user.check_password(password)  -- Werkzeug check_password_hash()
  -> create_access_token(identity=str(user.id))  -- Flask-JWT-Extended
  <- 200 {access_token: "..."}  (expires in 30 days)
```

### Token Storage (client)

`auth_service.dart` stores the token:

```dart
await _storage.write(key: 'access_token', value: data['access_token']);
```

`main.dart`'s `AuthCheck` widget reads it at startup to decide which screen to show.

### Authenticated Requests

Protected controllers use `@jwt_required()` decorator. The client sends:

```
Authorization: Bearer <access_token>
```

The controller then calls `get_jwt_identity()` to get `str(user.id)`, casts to `int`.

### Optional JWT (Booking/Payment)

`book_consultation_controller.py` uses a helper:

```python
def get_user_id_with_fallback(default_user_id=1):
    try:
        verify_jwt_in_request(optional=True)
        identity = get_jwt_identity()
        return int(identity) if identity else default_user_id
    except:
        return default_user_id
```

This means booking, payment creation, and consultation type update work without authentication during development, defaulting to `user_id=1`.

### JWT Error Handling

Registered in the app factory:

- Expired token -> `401 {msg: "Token has expired"}`
- Invalid/tampered token -> `422 {msg: "Invalid token: ..."}`
- Missing token on protected route -> `401 {msg: "Authorization token is missing"}`

---

## AI Architecture

### Gemini Configuration

On startup, `create_app()` reads `GEMINI_API_KEY` and stores a `GenerativeModel("gemini-2.5-flash")` instance on `app.gemini_model`. Both AI services retrieve this via `current_app.gemini_model`.

### Symptom Checker

`symptom_checker_service.analyze_symptoms_with_gemini(symptom_text)`:

1. Gets `model = getattr(current_app, "gemini_model", None)`
2. If model is None -> calls `generate_smart_response()` (mock)
3. If model present and `FORCE_MOCK_MODE=False`:
   - Sends prompt to Gemini: asks for empathy, clarifying questions, OTC medicine suggestions, doctor recommendations, urgency level, disclaimer
   - Returns `response.text`
4. On any Gemini exception -> falls back to `generate_smart_response()`

**Mock fallback** (`generate_smart_response`): keyword matching on lowercased symptom text:
- Contains "head" or "migraine" -> headache response with Paracetamol suggestion
- Contains "fever" -> fever response
- Contains "chest" and "pain" -> urgent warning, advise emergency services
- Default -> asks for more detail, recommends doctor

### Emergency AI

`emergency_gemini_service.emergency_ai_response(prompt)`:

1. Gets `model = getattr(current_app, "gemini_model", None)`
2. If model is None -> returns `"AI service unavailable. Please seek emergency help."`
3. Sends: system prompt (acknowledge + 3-5 first-aid steps + disclaimer) + `"User: " + prompt`
4. Returns `response.text`
5. On exception -> returns `"AI error. Please call emergency services."`

The controller wraps this with hospital records retrieved from the database and emergency numbers (102, 112). Note that hospital records are returned directly from the database table without geographic proximity filtering.

### Frontend Emergency Screen Note

The `EmergencyAssistantPage` (`emergency_assistant.dart`) uses hardcoded simulated responses. It does not call `/api/emergency/chat`. The backend emergency endpoint exists and is functional but is not consumed by the current frontend screen.

---

## Payment Architecture

### Flow

```
1. POST /api/payments/create {consultation_id}
     -> verify consultation exists and belongs to user (or default user_id=1)
     -> amount = 500 (INR, hardcoded)
     -> razorpay_client.order.create({amount: 50000, currency: "INR", payment_capture: 1})
     -> create Payment record (status="pending", razorpay_order_id=order["id"])
     <- {payment_id, consultation_id, amount, status, razorpay_order_id, key=RAZORPAY_KEY_ID}

2. Client opens Razorpay payment sheet with the order_id and key

3. POST /api/payments/verify {consultation_id, razorpay_order_id, razorpay_payment_id, razorpay_signature}
     -> fetch Payment record
     -> razorpay_client.utility.verify_payment_signature(params_dict)
     -> On success: payment.status = "success", consultation.status = "confirmed"
     <- {payment_id, consultation_id, status: "success", razorpay_payment_id}
```

### Notes

- Razorpay SDK is configured with `RAZORPAY_KEY_ID` and `RAZORPAY_KEY_SECRET` from environment.
- Amount is hardcoded at INR 500 per consultation. Variable pricing is not implemented.
- Currently configured with test-mode account keys.

---

## Frontend Architecture

### App Entry and Navigation

`main.dart`:
- `AuthCheck` (StatefulWidget) reads `FlutterSecureStorage` key `'access_token'`
- If token found -> `Navigator.pushReplacementNamed(context, '/main')`
- If no token -> `Navigator.pushReplacementNamed(context, '/get_started')`

Named routes:
```
/get_started         -> WelcomeScreen
/login               -> LoginPage
/login_as            -> LoginScreen
/signup              -> SignUpPage
/ai_symptom          -> AISymptomChecker
/profile             -> ProfilePage
/emergency_assistant -> EmergencyAssistantPage
emergency_assistance_offline -> EmergencyAssessmentPage
```

The `main_scaffold.dart` provides the main app shell with bottom navigation; screens that are part of the main shell (home, consultation, medicines, etc.) are accessed via the shell's tab navigation rather than named routes.

### Services

| Service file | Responsibilities | Base URL Configuration |
|---|---|---|
| `auth_service.dart` | register, login, getProfile, updateProfile, updateHealth, changePassword | Independent `baseUrl` property |
| `consultation_service.dart` | fetchSpecialties, fetchDoctorsBySpecialty, fetchDoctorSlots, bookConsultation, fetchMyConsultations, updateConsultationType | Uses `ApiConstants` |
| `payment_service.dart` | createPayment, verifyPayment (Razorpay integration) | Uses `ApiConstants` |
| `symptom_service.dart` | analyzeSymptoms (POST /api/symptoms/analyze) | Independent `_baseUrl` property |
| `medicine_api_service.dart` | getMedicinesByCategory, searchMedicines | Independent `baseUrl` property |

### State Management

Screens use `StatefulWidget` with local state and `setState()`.

### API Configuration

Backend URLs are defined across multiple files (`api_constants.dart`, `auth_service.dart`, `symptom_service.dart`, and `medicine_api_service.dart`). The base URL defaults to `http://10.0.2.2:5000` (Android emulator address). Developers must update all definitions when pointing to alternative hosts.

---

## Configuration

| Config Source | What It Provides |
|---|---|
| `server/.env` | All secrets and connection strings (not committed) |
| `server/app/config/settings.py` | Loads `GEMINI_API_KEY` from env |
| `server/app/__init__.py` | All Flask/JWT/SQLAlchemy config |
| `client/lib/utils/api_constants.dart` | Centralized endpoint paths and base URL |
| `client/lib/services/*` | Independent base URL definitions in specific service files |

---

## Error Handling

### Backend

- JWT errors: handled globally by `jwt.expired_token_loader`, `jwt.invalid_token_loader`, `jwt.unauthorized_loader` — return structured JSON
- Controller-level: explicit input validation with descriptive `400` responses
- Service-level: try/except blocks; AI failures fall back gracefully
- Database errors: not explicitly caught at service level beyond Razorpay verification

### Frontend

- Services use try/catch; exceptions are re-thrown as `Exception("message")`
- Screens display error messages via SnackBars or error state in UI
- Auth check errors fall back to the onboarding screen
