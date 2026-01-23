# Cinema Booking App (Flutter)

A **modern UI** Flutter app wired to your Laravel API routes:

- `GET /api/movies`
- `GET /api/movies/{id}`
- `GET /api/showtimes`
- `GET /api/showtimes/{showtime}/seats`
- `POST /api/bookings` (auth)
- `GET /api/bookings` (auth)
- `POST /api/login`, `POST /api/register`, `POST /api/logout`, `GET /api/me`

## 1) Create a Flutter project shell (platform folders)
Flutter isn't included in this environment, so **on your machine** do:

```bash
mkdir cinema_booking_app
cd cinema_booking_app
flutter create .
```

Then **copy/replace** these files into the project:
- `pubspec.yaml`
- `analysis_options.yaml`
- `lib/` folder

## 2) Set your API base URL
Edit: `lib/core/config.dart`

Example for Android emulator:
- Laravel on your PC: `http://10.0.2.2:8000/api`

Example for real phone on same Wi‑Fi:
- `http://YOUR_PC_IP:8000/api`

## 3) Run
```bash
flutter pub get
flutter run
```

## Notes about API fields
This app parses JSON defensively. If your backend keys are different, update model parsing in:
- `lib/models/*`
- `lib/core/api/*`
