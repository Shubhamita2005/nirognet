# NirogNet — Project Overview

## Problem Statement

Healthcare access in rural and semi-urban India faces significant barriers:

- Long distances to the nearest specialist
- Limited awareness of available healthcare services
- Language barriers in receiving medical guidance
- Lack of tools for non-emergency health guidance that can reduce unnecessary hospital visits
- No convenient way to book consultations or pay digitally

These problems are compounded during health emergencies, where people may not know what to do or who to call in the critical first minutes.

---

## Solution

NirogNet is a mobile healthcare application designed to reduce these barriers. The application is built as a Flutter mobile client backed by a Flask REST API, connected to a cloud-hosted PostgreSQL database and Google Gemini AI.

The key premise: give users access to health guidance, a doctor booking system, and emergency assistance from their mobile phone — without requiring prior medical knowledge or a hospital visit for every concern.

---

## Target Users

- Individuals in underserved or rural communities seeking accessible health guidance
- General users who want to book consultations with specialists without calling
- Patients who need quick information about medicine options
- Anyone needing immediate first-aid guidance during an emergency

---

## Major Features

### 1. User Account and Health Profile

Users register and log in with email and password. The app maintains a health profile including:
- Name, age, gender, contact, address, language preference
- Blood group and blood pressure readings

The JWT access token (30-day expiry) is persisted in the device's secure storage for auto-login.

### 2. AI-Powered Symptom Checker

Users type their symptoms in plain text. The backend sends this to Google Gemini 2.5 Flash with a prompt instructing it to respond with:
- Empathy and acknowledgment
- Clarifying questions
- Over-the-counter medicine suggestions where appropriate
- Recommendation to see a doctor
- Urgency level
- A clear disclaimer that this is not a medical diagnosis

If Gemini is unavailable, the system falls back to a keyword-based local response for common conditions (headache, fever, chest pain). The disclaimer is always included.

### 3. Doctor Discovery and Consultation Booking

The booking flow is:
1. Browse specialties (e.g., Cardiology, General Medicine)
2. Select a doctor — returns available doctors filtered by specialty, joined with their schedule and hospital
3. Select a date — generates 15-minute slots from the doctor's schedule, marks already-booked slots as unavailable
4. Book a slot — creates a Consultation record in the database with status "pending" (with optional JWT fallback defaulting to user_id=1 for development)
5. Select appointment type — updates the consultation with the preferred appointment format

The slot uniqueness constraint (`UNIQUE(doctor_id, date_time)`) in the database prevents double-booking.

### 4. Payment Integration

After booking, users can pay via Razorpay:
1. Backend creates a Razorpay order (INR 500, hardcoded)
2. The Razorpay Flutter SDK handles the payment UI
3. Backend verifies the payment signature using Razorpay's HMAC verification
4. On success: payment status becomes "success", consultation status becomes "confirmed"

Currently configured with test-mode account keys.

### 5. Emergency Assistance

**Backend:** Accepts any emergency description, sends it to Gemini with a structured emergency prompt, and returns 3–5 first-aid steps along with stored hospital records from the database (without geographic proximity filtering) and Indian emergency numbers (102, 112).

**Frontend — Emergency Assistant screen:** Uses simulated/hardcoded responses. This screen is a UI prototype and does not call the backend endpoint.

**Frontend — Offline Triage screen:** An on-device symptom decision tree that requires no network connection. Returns an assessment level (urgent, serious, or minor) based on user answers.

### 6. Medicine Catalogue

A searchable medicine database accessible to all users without login:
- Browse all medicines
- Search by name (partial, case-insensitive)
- Filter by category
- View individual medicine details

The medicines table stores name, category, and description. There is no stock/inventory system.

---

## Application Workflows

### Authentication Flow

```
App launch
  -> AuthCheck reads FlutterSecureStorage['access_token']
  -> Token exists -> go to main screen
  -> No token -> go to welcome/onboarding

Register -> POST /api/register -> success
Login -> POST /api/login -> receive JWT -> stored in secure storage
Logout -> token deleted from secure storage
```

### Symptom Check Workflow

```
User types symptoms (free text)
  -> Frontend validates non-empty input
    -> POST /api/symptoms/analyze
      -> Backend validates (length, type)
        -> Gemini generates response OR keyword fallback
      <- {reply, disclaimer}
  -> Frontend displays AI response
```

### Consultation and Payment Workflow

```
Select specialty -> GET /api/specialties
Select doctor   -> GET /api/specialties/{id}/doctors
Select date     -> GET /api/doctors/{id}/slots?date=...
Select slot     -> POST /api/consultations
Select mode     -> PUT /api/consultations/{id}/type
Create payment  -> POST /api/payments/create
  <- razorpay_order_id, amount, key
Razorpay SDK opens payment sheet
  -> User pays
POST /api/payments/verify
  -> Signature verified
  -> Consultation confirmed
```

---

## Technology Choices

| Technology | Why Used |
|---|---|
| Flutter | Cross-platform mobile development with a single codebase; responsive UI components |
| Flask | Lightweight Python web framework; fast to develop REST APIs; well-suited for team development with clear blueprint structure |
| SQLAlchemy | ORM that avoids raw SQL; makes model relationships explicit; enables database-agnostic development |
| PostgreSQL | Production-grade relational database; handles relational data (users, doctors, schedules, consultations) with integrity constraints |
| Supabase | Managed PostgreSQL provider; provides direct connection string |
| Flask-JWT-Extended | JWT authentication with minimal boilerplate; supports optional verification for development flexibility |
| Google Gemini 2.5 Flash | Accessible AI model API for natural language health guidance; chosen for its instruction-following capability with medical disclaimers |
| Razorpay | Payment gateway with strong India-first support; Flutter SDK available; test mode for development |
| flask-cors | Required for browser-based Flutter web clients and cross-origin API calls from mobile |
| flutter_secure_storage | Secure token persistence on device; preferred over SharedPreferences for JWT storage |

---

## Architecture Summary

```
Flutter Client (client/)
     |
     | HTTP REST (JSON)
     |
Flask REST API (server/, port 5000)
     |
     +-- app factory (__init__.py)
     |     JWT / CORS / Gemini init
     |
     +-- Blueprints (routes/)
     |     URL definitions and HTTP method binding
     |
     +-- Controllers (controllers/)
     |     Input validation, response formatting
     |
     +-- Services (services/)
     |     Business logic, DB queries, Gemini calls, Razorpay calls
     |
     +-- Models (models/models.py)
           SQLAlchemy ORM: User, Doctor, Specialty, DoctorSchedule,
           Hospital, Consultation, AppointmentType, Medicine, Payment
           |
           v
     PostgreSQL (Supabase)
```

---

## External Integrations

| Service | Purpose | Mode |
|---|---|---|
| Google Gemini 2.5 Flash | Symptom analysis, emergency first-aid | Production API key (falls back to mock) |
| Razorpay | Consultation payment processing | Test-mode account |
| Supabase | Managed PostgreSQL database hosting | Configured connection |

---

## Current Limitations

| Limitation | Detail |
|---|---|
| Decentralized API Base URLs | Base URLs are independently hardcoded across multiple client files (`api_constants.dart`, `auth_service.dart`, `symptom_service.dart`, `medicine_api_service.dart`) to the Android emulator address |
| Optional JWT on booking | Unauthenticated booking defaults to user_id=1 (development convenience) |
| Static homepage | Recent medicines, symptoms, and consultation cards show hardcoded data |
| Disconnected emergency screen | In-app emergency chat does not call the backend AI endpoint |
| Fixed consultation fee | Payment amount is hardcoded at INR 500 |
| Test payments only | Razorpay is configured with test account keys |
| No geographic filtering | Hospital list in emergency response returns all records from the database table |
| No push notifications | Appointment reminders not implemented |
| Insecure defaults | SECRET_KEY and JWT_SECRET_KEY fall back to hardcoded dev values if not set |

---

## Future Scope

The following improvements have been identified as natural next steps:

- **Centralize frontend base URLs** to a single source of truth
- **Full JWT enforcement** on booking and payment endpoints (remove optional JWT bypass)
- **Dynamic homepage** fetching real user consultations, medications, and symptom history
- **Connect emergency frontend** to the backend AI endpoint
- **Variable pricing** per specialty or doctor
- **Push notifications** for upcoming appointments
- **Hospital proximity search** using real geolocation
- **Multi-language support** for Gemini prompts based on user language preference
- **Health records upload** and storage
- **Production deployment** with proper secret management and SSL

---

## Team

NirogNet was developed as a collaborative student project.

| Name | LinkedIn |
|---|---|
| Shubhamita Majumder | https://www.linkedin.com/in/shubhamita-majumder-69264b30a/ |
| Neha Pani | https://www.linkedin.com/in/neha-pani/ |
| Protyush Banik | https://www.linkedin.com/in/protyush-banik/ |
| Ritwika Banerjee | https://www.linkedin.com/in/ritwika-banerjee-5a9207360/ |
