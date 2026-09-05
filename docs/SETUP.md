# NirogNet — Developer Setup Guide

This guide explains how to set up the NirogNet project locally from scratch. It covers the Flask backend, Flutter frontend, environment configuration, and common issues.

---

## Prerequisites

### Backend

| Requirement | Version | Notes |
|---|---|---|
| Python | 3.10+ | Verify with `python --version` |
| pip | Latest | Comes with Python |
| PostgreSQL database | Any | Cloud-hosted (e.g., Supabase) or local instance |
| Git | Any | For cloning |

### Frontend

| Requirement | Version | Notes |
|---|---|---|
| Flutter SDK | 3.x | https://docs.flutter.dev/get-started/install |
| Dart | Included with Flutter | |
| Android Studio / Xcode | Latest | For emulators |
| Android SDK | API 21+ | For Android targets |

---

## Repository Structure

```
nirognet_final/
  .gitignore
  README.md
  client/         <- Flutter frontend
  server/         <- Flask backend
  docs/           <- Documentation
```

There is one Git repository at the root. The `client/` and `server/` directories are independent in terms of language and tooling but share one repo.

---

## Backend Setup

### 1. Navigate to the server directory

```bash
cd server
```

### 2. Create a virtual environment

```bash
python -m venv venv
```

### 3. Activate the virtual environment

```bash
# Windows
venv\Scripts\activate

# Linux / macOS
source venv/bin/activate
```

You should see `(venv)` in your terminal prompt.

### 4. Install dependencies

```bash
pip install -r requirements.txt
```

This installs Flask, SQLAlchemy, Flask-JWT-Extended, Flask-CORS, google-generativeai, razorpay, python-dotenv, psycopg2 (via SQLAlchemy), and all other required packages.

### 5. Configure environment variables

```bash
cp .env.example .env
```

Open `.env` and fill in your actual values:

```env
DATABASE_URL=postgresql+psycopg2://user:password@host:5432/dbname?sslmode=require
SECRET_KEY=your-random-secret-key
JWT_SECRET_KEY=your-random-jwt-secret
GEMINI_API_KEY=your-gemini-api-key
RAZORPAY_KEY_ID=rzp_test_your_key_id
RAZORPAY_KEY_SECRET=your_razorpay_secret
```

**Where to get each:**

| Variable | Source |
|---|---|
| `DATABASE_URL` | Your PostgreSQL provider (e.g., Supabase: Settings > Database > Connection string) |
| `SECRET_KEY` | Generate any random string: `python -c "import secrets; print(secrets.token_hex(32))"` |
| `JWT_SECRET_KEY` | Same as above, use a different value |
| `GEMINI_API_KEY` | Google AI Studio (API key from https://aistudio.google.com/app/apikey) |
| `RAZORPAY_KEY_ID` + `RAZORPAY_KEY_SECRET` | Razorpay Dashboard (Test account from https://dashboard.razorpay.com/app/keys) |

### 6. Set up the database

The Flask app uses SQLAlchemy with `db.create_all()` style initialization. The tables are expected to exist in the PostgreSQL database. You can:

**Option A: Use Flask-Migrate (if configured)**

```bash
flask db upgrade
```

**Option B: Verify tables with the provided utility**

```bash
python check_db.py
```

This script prints the list of tables accessible via your `DATABASE_URL`. If it prints tables like `users`, `doctor`, `specialty`, `consultation` etc., your database is connected correctly.

---

## Frontend Setup

### 1. Navigate to the client directory

```bash
cd client
```

### 2. Install Flutter dependencies

```bash
flutter pub get
```

### 3. Configure the API base URLs

Note: The frontend code contains base URL definitions across multiple files. If changing host/port from the default Android emulator configuration (`http://10.0.2.2:5000`), update the base URL in all of the following:

- `client/lib/utils/api_constants.dart` (`baseUrl = "http://10.0.2.2:5000/api"`)
- `client/lib/services/auth_service.dart` (`baseUrl = 'http://10.0.2.2:5000/api'`)
- `client/lib/services/symptom_service.dart` (`_baseUrl = 'http://10.0.2.2:5000'`)
- `client/lib/screens/medicine_api_service.dart` (`baseUrl = 'http://10.0.2.2:5000/api'`)

**Recommended values based on setup:**

| Scenario | Value |
|---|---|
| Android emulator (default) | `http://10.0.2.2:5000/api` |
| Physical Android device (same Wi-Fi as laptop) | `http://192.168.x.x:5000/api` |
| iOS simulator | `http://localhost:5000/api` |
| Web browser | `http://localhost:5000/api` |

To find your machine's local IP:
```bash
# Windows
ipconfig
# Look for: IPv4 Address ... 192.168.x.x

# Linux/macOS
ifconfig | grep "inet "
```

### 4. Run the Flutter app

```bash
# Check connected devices
flutter devices

# Run on a specific device
flutter run -d <device_id>

# Or just run (will prompt if multiple devices)
flutter run
```

For Android emulator, make sure the emulator is running first (via Android Studio > Device Manager).

---

## Database Notes

The PostgreSQL database is accessed via the `DATABASE_URL` environment variable. The app connects using SQLAlchemy's `postgresql+psycopg2` driver.

The following tables are expected:
- `user` — application users
- `specialty` — medical specialties
- `doctor` — doctor records
- `doctor_schedule` — doctor availability by day and hospital
- `hospital` — hospital records (listed during emergency responses)
- `appointment_type` — consultation type definitions (ID 1 and 2)
- `consultation` — booked consultations
- `payment` — payment records
- `medicines` — medicine catalogue

If you are starting with an empty database, you will need to seed the `specialty`, `doctor`, `doctor_schedule`, `hospital`, `appointment_type`, and `medicines` tables with initial data for the app to be usable.

---

## Running Both Together

Run the Flask backend first, then start the Flutter app. They communicate over HTTP — no shared process is needed.

**Recommended terminal setup:**

Terminal 1 (backend):
```bash
cd server
venv\Scripts\activate
python run.py
```

Terminal 2 (frontend):
```bash
cd client
flutter run
```

---

## Common Issues

### Backend

**`ModuleNotFoundError: No module named 'app'`**

Ensure you are running `python run.py` from inside the `server/` directory, not from the root.

**`sqlalchemy.exc.OperationalError: could not connect to server`**

- Check that `DATABASE_URL` is correctly set in `server/.env`
- Confirm your database provider is active and the database password is correct
- Check that your network allows outbound connections on port 5432

**`GEMINI_API_KEY not set`**

The app will start but AI features will use the keyword-based fallback. Add `GEMINI_API_KEY` to `.env` to enable real Gemini responses.

**`razorpay.errors.BadRequestError`**

Check that `RAZORPAY_KEY_ID` and `RAZORPAY_KEY_SECRET` are set and valid.

---

### Frontend

**`Connection refused` / `SocketException`**

The Flutter app cannot reach the backend. Check:
1. Is Flask running? (`python run.py` should show "Running on http://0.0.0.0:5000")
2. Are the base URLs in `api_constants.dart`, `auth_service.dart`, `symptom_service.dart`, and `medicine_api_service.dart` correct for your device type? (emulator vs physical)
3. Are you on the same Wi-Fi network for physical device testing?

**`flutter pub get` fails**

Run `flutter doctor` to check for SDK issues. Ensure Flutter and Dart are correctly installed and in your PATH.

**Build errors on Android**

Ensure `minSdkVersion` in `android/app/build.gradle` is at least 21. Some Flutter packages (including `razorpay_flutter`) require a recent API level.

---

## Quick Reference

| Task | Command |
|---|---|
| Start backend | `cd server && python run.py` |
| Check database | `cd server && python check_db.py` |
| Install backend deps | `cd server && pip install -r requirements.txt` |
| Start frontend | `cd client && flutter run` |
| Install frontend deps | `cd client && flutter pub get` |
| Check Flutter setup | `flutter doctor` |
| List devices | `flutter devices` |
