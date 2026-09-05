# NirogNet — API Documentation

All endpoints are served by the Flask backend at `http://localhost:5000` (default).

Frontend API calls are made across `client/lib/utils/api_constants.dart`, `client/lib/services/auth_service.dart`, `client/lib/services/symptom_service.dart`, and `client/lib/screens/medicine_api_service.dart`.

**Base URL:** `http://<host>:5000/api`

**Authentication:** JWT Bearer token.
- Include as header: `Authorization: Bearer <access_token>`
- Tokens are issued at login and expire after 30 days.
- Endpoints marked **Optional** use `verify_jwt_in_request(optional=True)` — they work without a token, defaulting to `user_id=1`.

---

## 1. Authentication

### POST `/api/register`

Register a new user.

- **Auth:** None
- **Request body:**

```json
{
  "email": "user@example.com",
  "password": "yourpassword",
  "name": "Jane Doe",
  "contact": "9876500000"
}
```

- **Responses:**

| Code | Body | Condition |
|---|---|---|
| 201 | `{"msg": "User registered"}` | Success |
| 400 | `{"msg": "Email and password required"}` | Missing fields |
| 400 | `{"msg": "User already exists"}` | Duplicate email |

---

### POST `/api/login`

Login and receive a JWT access token.

- **Auth:** None
- **Request body:**

```json
{
  "email": "user@example.com",
  "password": "yourpassword"
}
```

- **Responses:**

| Code | Body | Condition |
|---|---|---|
| 200 | `{"access_token": "eyJ..."}` | Success |
| 400 | `{"msg": "Email and password required"}` | Missing fields |
| 401 | `{"msg": "Invalid credentials"}` | Wrong email/password |

---

## 2. User Profile

### GET `/api/profile`

Get the authenticated user's profile.

- **Auth:** JWT required
- **Response (200):**

```json
{
  "id": 1,
  "email": "user@example.com",
  "name": "Jane Doe",
  "age": 28,
  "gender": "Female",
  "contact": "9876500000",
  "address": "123 Sample Street, City",
  "blood_group": "O+",
  "blood_pressure": "120/80",
  "language": "English"
}
```

- **Error:** `404 {"msg": "User not found"}`

---

### PUT `/api/profile`

Update the authenticated user's profile fields.

- **Auth:** JWT required
- **Request body** (all fields optional):

```json
{
  "name": "Jane Doe",
  "gender": "Female",
  "contact": "9876500000",
  "address": "456 Updated Lane, City",
  "language": "Hindi",
  "age": 29
}
```

- **Response (200):** Updated user object (same structure as GET `/api/profile`)
- **Error:** `400 {"msg": "Invalid age"}` if age is not a valid integer

---

### PUT `/api/profile/health`

Update health-related profile fields.

- **Auth:** JWT required
- **Request body** (both fields optional):

```json
{
  "blood_group": "O+",
  "blood_pressure": "120/80"
}
```

- **Response (200):** Updated user object

---

### PUT `/api/change-password`

Change the authenticated user's password.

- **Auth:** JWT required
- **Request body:**

```json
{
  "old_password": "current_password",
  "new_password": "new_password"
}
```

- **Responses:**

| Code | Body | Condition |
|---|---|---|
| 200 | `{"msg": "Password changed"}` | Success |
| 400 | `{"msg": "old_password and new_password required"}` | Missing fields |
| 401 | `{"msg": "Old password incorrect"}` | Wrong current password |

---

## 3. Doctors and Specialties

### GET `/api/specialties`

List all medical specialties.

- **Auth:** None
- **Response (200):**

```json
{
  "specialties": [
    {"id": 1, "name": "Cardiology"},
    {"id": 2, "name": "General Medicine"}
  ]
}
```

---

### GET `/api/specialties/<specialty_id>/doctors`

Get all available doctors for a specialty, with their schedule and hospital.

- **Auth:** None
- **URL parameter:** `specialty_id` (integer)
- **Response (200):**

```json
{
  "doctors": [
    {
      "doctor_id": 3,
      "doctor_name": "Dr. Sample Specialist",
      "day": "Monday",
      "start_time": "09:00:00",
      "end_time": "13:00:00",
      "hospital": "City Medical Centre"
    }
  ]
}
```

Note: Only doctors with `available=True` are returned. Each record represents a doctor-schedule-hospital combination (one doctor may appear multiple times for different days/hospitals).

---

### GET `/api/doctors/<doctor_id>/slots?date=YYYY-MM-DD`

Get available 15-minute consultation slots for a doctor on a specific date.

- **Auth:** None
- **URL parameter:** `doctor_id` (integer)
- **Query parameter:** `date` (required, format `YYYY-MM-DD`)
- **Response (200):**

```json
{
  "slots": [
    {"time": "09:00", "available": true},
    {"time": "09:15", "available": false},
    {"time": "09:30", "available": true}
  ]
}
```

- **Errors:**

| Code | Body | Condition |
|---|---|---|
| 400 | `{"msg": "date query param is required (YYYY-MM-DD)"}` | Missing date |
| 400 | `{"msg": "Invalid date format. Use YYYY-MM-DD"}` | Bad format |

---

## 4. Consultations

### POST `/api/consultations`

Book a consultation slot.

- **Auth:** Optional JWT (defaults to `user_id=1` if no token)
- **Request body:**

```json
{
  "doctor_id": 3,
  "date_time": "2025-10-15T09:00:00"
}
```

- **Responses:**

| Code | Body | Condition |
|---|---|---|
| 201 | `{"msg": "Consultation booked successfully", "consultation": {...}}` | Success |
| 400 | `{"msg": "doctor_id, date_time required"}` | Missing fields |
| 400 | `{"msg": "Invalid date_time format"}` | Bad ISO format |
| 400 | `{"msg": "Slot already booked"}` | Collision detected |

**Consultation object in response:**
```json
{
  "id": 1,
  "doctor_id": 3,
  "user_id": 1,
  "appointment_type_id": null,
  "date_time": "2025-10-15T09:00:00",
  "status": "pending"
}
```

---

### GET `/api/consultations`

Get all consultations for the authenticated user.

- **Auth:** JWT required
- **Response (200):**

```json
{
  "consultations": [
    {
      "id": 1,
      "doctor_id": 3,
      "user_id": 1,
      "appointment_type_id": 1,
      "date_time": "2025-10-15T09:00:00",
      "status": "confirmed"
    }
  ]
}
```

---

### PUT `/api/consultations/<consultation_id>/type`

Set the appointment type for a consultation.

- **Auth:** Optional JWT (defaults to `user_id=1` if no token)
- **URL parameter:** `consultation_id` (integer)
- **Request body:**

```json
{
  "appointment_type_id": 1
}
```

Note: Valid values are `1` or `2` (hardcoded in the service layer).

- **Responses:**

| Code | Body | Condition |
|---|---|---|
| 200 | `{"msg": "Appointment type updated successfully", "consultation": {...}}` | Success |
| 400 | `{"msg": "appointment_type_id is required"}` | Missing field |
| 400 | `{"msg": "Invalid appointment type"}` | Not 1 or 2 |
| 400 | `{"msg": "Consultation not found"}` | Invalid ID |
| 400 | `{"msg": "Unauthorized"}` | Wrong user |

---

## 5. Payments

### POST `/api/payments/create`

Create a Razorpay payment order for a consultation.

- **Auth:** Optional JWT (defaults to `user_id=1` if no token)
- **Request body:**

```json
{
  "consultation_id": 1
}
```

- **Responses:**

| Code | Body | Condition |
|---|---|---|
| 201 | See below | Success |
| 400 | `{"msg": "consultation_id is required"}` | Missing field |
| 400 | `{"msg": "Consultation not found"}` | Invalid ID |
| 400 | `{"msg": "Unauthorized"}` | Wrong user |

**Success response:**
```json
{
  "msg": "Payment created",
  "payment": {
    "payment_id": 1,
    "consultation_id": 1,
    "amount": 500,
    "status": "pending",
    "razorpay_order_id": "order_placeholder_123",
    "key": "rzp_test_placeholder"
  }
}
```

Amount is fixed at INR 500. The `key` is the `RAZORPAY_KEY_ID` from environment.

---

### POST `/api/payments/verify`

Verify the Razorpay payment signature and confirm the consultation.

- **Auth:** None (signature provides verification)
- **Request body:**

```json
{
  "consultation_id": 1,
  "razorpay_order_id": "order_placeholder_123",
  "razorpay_payment_id": "pay_placeholder_456",
  "razorpay_signature": "signature_placeholder_789"
}
```

- **Responses:**

| Code | Body | Condition |
|---|---|---|
| 200 | `{"msg": "Payment successful", "payment": {...}}` | Signature valid |
| 400 | `{"msg": "Missing payment verification fields"}` | Any field absent |
| 400 | `{"msg": "Payment verification failed"}` | Signature invalid |
| 400 | `{"msg": "Consultation not found"}` | Invalid ID |
| 400 | `{"msg": "Payment not found"}` | No pending payment |

On success: `payment.status = "success"`, `consultation.status = "confirmed"`.

---

## 6. Symptom Checker

### POST `/api/symptoms/analyze`

Submit symptom text for AI analysis.

- **Auth:** None
- **Request body:**

```json
{
  "symptoms": "I have a headache and mild fever for two days"
}
```

Constraints: Must be a string, 3–2000 characters.

- **Responses:**

| Code | Body | Condition |
|---|---|---|
| 200 | See below | Success |
| 400 | `{"msg": "Request body is required"}` | Empty body |
| 400 | `{"msg": "Symptom text is required"}` | Missing field |
| 400 | `{"msg": "Symptom text must be a string"}` | Wrong type |
| 400 | `{"msg": "Please describe your symptoms in more detail"}` | Under 3 chars |
| 400 | `{"msg": "Symptom text is too long (max 2000 characters)"}` | Over 2000 chars |
| 502 | `{"msg": "Empty response from AI service"}` | Gemini returned empty |
| 500 | `{"msg": "An internal error occurred while analyzing symptoms"}` | Unexpected error |

**Success response:**
```json
{
  "reply": "I understand you have a headache and fever...",
  "symptom_input": "I have a headache and mild fever for two days",
  "disclaimer": "This is AI-generated guidance, not a medical diagnosis."
}
```

`reply` is either a Gemini-generated response or a keyword-matched fallback string.

---

## 7. Emergency Chat

### POST `/api/emergency/chat`

Submit an emergency description and receive AI first-aid guidance plus hospital records from database.

- **Auth:** None
- **Request body:**

```json
{
  "message": "Someone collapsed and is not breathing"
}
```

Constraints: Must be a string, 3–2000 characters.

- **Responses:**

| Code | Body | Condition |
|---|---|---|
| 200 | See below | Success |
| 400 | `{"msg": "Request body is required"}` | Empty body |
| 400 | `{"msg": "Message is required"}` | Missing field |
| 400 | `{"msg": "Message must be a string"}` | Wrong type |
| 400 | `{"msg": "Please describe your emergency in more detail"}` | Under 3 chars |
| 400 | `{"msg": "Message is too long (max 2000 characters)"}` | Over 2000 |
| 502 | `{"msg": "Empty response from AI service"}` | Gemini returned empty |
| 500 | `{"msg": "AI error. Please call emergency services immediately.", "emergency_numbers": {...}}` | AI exception |

**Success response:**
```json
{
  "text": "I understand this is an emergency. Here are immediate steps:\n1. Call 102 (ambulance)...",
  "hospitals": [
    {
      "name": "City Medical Centre",
      "distance": "2.3 km",
      "doctors": 12,
      "beds": "50",
      "ventilators": "5",
      "blood": "O+, A+"
    }
  ],
  "disclaimer": "This is AI-generated first-aid guidance, NOT medical advice. Call emergency services immediately.",
  "emergency_numbers": {
    "ambulance": "102",
    "general": "112"
  }
}
```

Note: `hospitals` returns all records from the Hospital database table without geographic proximity filtering.

---

## 8. Medicines

### GET `/api/medicines`

Get all medicines in the catalogue.

- **Auth:** None
- **Response (200):**

```json
[
  {
    "id": 1,
    "name": "Paracetamol",
    "category": "Analgesic",
    "description": "Used for pain and fever relief"
  }
]
```

---

### GET `/api/medicines/search?name=<query>`

Search medicines by name (case-insensitive, partial match).

- **Auth:** None
- **Query parameter:** `name`
- **Response (200):** Array of medicine objects

---

### GET `/api/medicines/category/<category>`

Filter medicines by category (case-insensitive match).

- **Auth:** None
- **URL parameter:** `category`
- **Response (200):** Array of medicine objects

---

### GET `/api/medicines/<medicine_id>`

Get a single medicine by ID.

- **Auth:** None
- **URL parameter:** `medicine_id` (integer)
- **Response (200):** Single medicine object, or `null`/empty if not found

---

## 9. Health Check

### GET `/health`

Check backend status.

- **Auth:** None
- **Response (200):**

```json
{
  "db": "ok",
  "gemini": true
}
```

`gemini` is `true` if `GEMINI_API_KEY` was loaded successfully.

---

## JWT Error Responses

These are returned automatically by Flask-JWT-Extended:

| Scenario | Code | Response |
|---|---|---|
| Token expired | 401 | `{"msg": "Token has expired"}` |
| Token malformed/tampered | 422 | `{"msg": "Invalid token: ..."}` |
| Token missing on protected route | 401 | `{"msg": "Authorization token is missing"}` |
