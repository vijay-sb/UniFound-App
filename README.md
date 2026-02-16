<p align="center">
  <img src="assets/images/unifound_logo.png" alt="UniFound Logo" width="120"/>
</p>

<h1 align="center">UniFound</h1>

<p align="center">
  <b>A campus-wide Lost &amp; Found app — helping students recover what matters.</b>
</p>

<p align="center">
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" alt="Flutter"/></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart" alt="Dart"/></a>
  <a href="https://supabase.com"><img src="https://img.shields.io/badge/Supabase-Storage-3ECF8E?logo=supabase" alt="Supabase"/></a>
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-brightgreen" alt="Platforms"/>
</p>

---

## 📖 Overview

**UniFound** is a cross-platform Flutter application designed for university campuses to streamline the reporting and discovery of lost & found items. Students who find an item can report it — with a photo, category, and location — and the system ensures it reaches the right hands through a structured handover process.

The app connects to a **Go-based REST backend** ([UniFound-Backend](../UniFound-Backend)) for authentication, item management, and admin workflows, and uses **Supabase Storage** for image uploads.

---

## ✨ Features

| Feature | Description |
|---|---|
| 🔐 **JWT Authentication** | Secure email/password login with tokens stored via `flutter_secure_storage` |
| 🗂️ **Blind Discovery Feed** | Browse all verified found items with search & filter — without revealing finder identity |
| 📸 **Report Found Items** | Submit found items with photo (camera/gallery), category, campus zone, and timestamp |
| 📍 **GPS Campus Geo-Fencing** | Verifies the reporter is physically on campus using `geolocator` + polygon checks (`maps_toolkit`) |
| 📋 **My Reports** | View and track all items you've personally reported |
| 🤝 **Handover Instructions** | After submitting, a dialog guides you on which campus office to hand the item to |
| 🎨 **Glassmorphism UI** | Modern dark-themed interface with frosted-glass cards, neon accents, and animated particle backgrounds |

---

## 🏗️ Architecture

```
lib/
├── main.dart                     # App entry point, routing & Supabase init
├── constants.dart                # API base URL and key constants
├── models/
│   ├── item_dto.dart             # Data transfer object for items
│   ├── found_item_request.dart   # Request model for reporting items
│   └── login_request.dart        # Login request payload
├── screens/
│   ├── login_screen.dart         # Animated login with campus image reveal
│   ├── blind_feed_screen.dart    # Main discovery feed (search + filter)
│   ├── found_item_form_screen.dart  # Multi-step form to report a found item
│   └── my_reports_screen.dart    # User's own reported items
├── services/
│   ├── api_service.dart          # Auth API client (login, logout, token mgmt)
│   ├── item_api_service.dart     # Item CRUD operations against the backend
│   └── supabase_upload_service.dart  # Direct image upload to Supabase Storage
└── widgets/
    └── handover_alert.dart       # Post-submission handover instruction dialog
```

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** ≥ 3.0.0 (`flutter --version`)
- **Dart SDK** ≥ 3.0.0
- A running instance of the [UniFound Backend] -> clone https://github.com/vijay-sb/UniFound-Backend.git(Go)
- Android / iOS emulator or a physical device

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/vijay-sb/UniFound-App.git

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
```

### Configuration

Update `lib/constants.dart` to point to your backend:

```dart
const String baseUrl = 'http://localhost:8080/api';
```

Supabase credentials are configured in `lib/main.dart` and `lib/services/supabase_upload_service.dart`. Replace the URL and anon key with your own Supabase project values if needed.

---

## 🧪 Testing

The project includes unit, widget, and logic tests under the `test/` directory.

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

### CI / CD

A **GitHub Actions** workflow (`.github/workflows/flutter_ci.yml`) runs on every push and PR to `main` / `master`:

1. Installs Flutter (stable channel)
2. Runs `flutter analyze`
3. Runs `flutter test`

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter 3.x |
| **Language** | Dart 3.x |
| **Backend** | Go (REST API) |
| **Image Storage** | Supabase Storage |
| **Auth Tokens** | `flutter_secure_storage` |
| **HTTP Client** | `http` package |
| **Location** | `geolocator` + `maps_toolkit` |
| **Camera / Gallery** | `image_picker` |
| **Animations** | Lottie + custom `CustomPainter` |
| **CI** | GitHub Actions |

---

## 📱 Screens

| Screen | Description |
|---|---|
| **Login** | Animated campus-image reveal with email/password fields |
| **Blind Feed** | Scrollable card list of verified found items with search bar |
| **Report Item** | Form with image upload, category/location dropdowns, date-time picker, and GPS verification |
| **My Reports** | Personal dashboard of all items you've reported with status badges |

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is developed as part of a university Software Engineering course.

---

<p align="center">
  Made with ❤️ for campus communities
</p>
