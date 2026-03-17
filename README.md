<div align="center">

# TaskFlow

### A Full-Stack Task Management Application

**Flutter × Laravel  Modern, Beautiful, and Production-Ready**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Laravel](https://img.shields.io/badge/Laravel-12-FF2D20?logo=laravel&logoColor=white)](https://laravel.com)
[![PHP](https://img.shields.io/badge/PHP-8.2+-777BB4?logo=php&logoColor=white)](https://php.net)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web-lightgrey)]()

*A beautifully crafted, full-stack task management app featuring a liquid-glass UI design system, complete CRUD operations, token-based authentication with GitHub OAuth, dual notification system (server + local), dark mode, and bilingual localization (English/Khmer).*

---

**CS361  Mobile Application Development • Final Project**
**ParagonU International University • Phnom Penh**

</div>

---

##  Table of Contents

- [Overview](#-overview)
- [Key Features](#-key-features)
- [Tech Stack](#-tech-stack)
- [Architecture](#-architecture)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
  - [Prerequisites](#prerequisites)
  - [Backend Setup (Laravel API)](#backend-setup-laravel-api)
  - [Frontend Setup (Flutter)](#frontend-setup-flutter)
- [API Reference](#-api-reference)
- [Database Schema](#-database-schema)
- [Authentication Flow](#-authentication-flow)
- [Screens & UI](#-screens--ui)
- [State Management](#-state-management)
- [Localization](#-localization)
- [Notification System](#-notification-system)
- [Dependencies](#-dependencies)
- [Contributing](#-contributing)
- [License](#-license)

---

##  Overview

**TaskFlow** is a cross-platform task management application built with a modern mobile-first approach. The project demonstrates end-to-end software engineering from designing a RESTful API with Laravel Sanctum authentication to implementing a responsive, animated Flutter client with Provider-based state management.

---

##  Tech Stack

| Layer | Technology | Purpose |
|:---:|:---|:---|
| **Frontend** | Flutter 3.x / Dart 3.10 | Cross-platform mobile & web UI |
| **State Management** | Provider (ChangeNotifier) | Reactive state propagation |
| **Backend** | Laravel 12 / PHP 8.2+ | RESTful API server |
| **Authentication** | Laravel Sanctum | Token-based API authentication |
| **OAuth** | Laravel Socialite | GitHub OAuth 2.0 integration |
| **Database** | MySQL | Relational data persistence |
| **HTTP Client** | `package:http` | REST API communication |
| **Local Storage** | SharedPreferences | Token & settings persistence |
| **Local Notifications** | `flutter_local_notifications` | Scheduled task reminders |
| **Typography** | Google Fonts (Poppins / Kantumruy Pro) | Locale-aware design language |
| **Deep Links** | `app_links` / `url_launcher` | OAuth callback handling |

---

##  Getting Started

### Prerequisites

| Tool | Version | Installation |
|:---|:---|:---|
| Flutter SDK | 3.x+ | [flutter.dev/get-started](https://flutter.dev/docs/get-started/install) |
| Dart SDK | ≥ 3.10 | Included with Flutter |
| PHP | ≥ 8.2 | [php.net](https://php.net) |
| Composer | Latest | [getcomposer.org](https://getcomposer.org) |
| MySQL | 8.0+ | [mysql.com](https://dev.mysql.com/downloads/) |
| Node.js | 18+ | [nodejs.org](https://nodejs.org) *(optional, for Laravel Vite)* |

### Backend Setup (Laravel API)

```bash
# 1. Navigate to the API directory
cd taskflow-api

# 2. Install PHP dependencies
composer install

# 3. Configure environment
cp .env.example .env
php artisan key:generate

# 4. Configure your database in .env
#    DB_CONNECTION=mysql
#    DB_HOST=127.0.0.1
#    DB_PORT=3306
#    DB_DATABASE=taskflow
#    DB_USERNAME=
#    DB_PASSWORD=

# 5. Configure GitHub OAuth in .env (optional)
#    GITHUB_CLIENT_ID=your_github_client_id
#    GITHUB_CLIENT_SECRET=your_github_client_secret
#    GITHUB_REDIRECT_URL=http://127.0.0.1:8000/login/oauth2/code/github

# 6. Run database migrations
php artisan migrate

# 7. Start the development server
php artisan serve
# API will be available at http://127.0.0.1:8000
```

### Frontend Setup (Flutter)

```bash
# 1. Navigate to the project root
cd flutter_final_project_app_with_full_ui_and_api_crud_integration

# 2. Install Flutter dependencies
flutter pub get

# 3. Verify the API base URL in lib/services/api_service.dart
#    Default: http://127.0.0.1:8000/api

# 4. Run on your target platform
flutter run                    # Default connected device
flutter run -d chrome          # Web
flutter run -d ios             # iOS Simulator
flutter run -d android         # Android Emulator

# 5. Build for production
flutter build apk              # Android APK
flutter build ios              # iOS Archive
flutter build web              # Web deployment
```

---

##  Dependencies

### Flutter (Frontend)

| Package | Version | Purpose |
|:---|:---:|:---|
| `provider` | ^6.1.2 | State management (4 ChangeNotifier providers) |
| `http` | ^1.2.1 | HTTP client for REST API |
| `google_fonts` | ^6.2.1 | Poppins & Kantumruy Pro typography |
| `shared_preferences` | ^2.2.3 | Token, settings, and preference persistence |
| `flutter_slidable` | ^3.1.1 | Swipe-to-complete and swipe-to-delete gestures |
| `local_auth` | ^2.3.0 | Biometric authentication |
| `url_launcher` | ^6.2.5 | GitHub OAuth browser launch |
| `app_links` | ^6.3.3 | Deep link handling (`taskflow://auth` callback) |
| `font_awesome_flutter` | ^10.8.0 | GitHub & social icons |
| `intl` | ^0.19.0 | Date formatting & i18n utilities |
| `flutter_local_notifications` | ^18.0.1 | Scheduled task due-date reminders |
| `timezone` | ^0.10.0 | Timezone-aware notification scheduling |
| `flutter_timezone` | ^4.1.1 | Device timezone detection |
| `permission_handler` | ^11.3.1 | Runtime permission requests (Android 13+) |
| `liquid_glass_ui` | ^0.4.0 | Liquid glass UI utilities |

### Laravel (Backend)

| Package | Version | Purpose |
|:---|:---:|:---|
| `laravel/framework` | ^12.0 | Core framework |
| `laravel/sanctum` | ^4.3 | API token authentication |
| `laravel/socialite` | ^5.24 | GitHub OAuth integration |

---

##  Contributing

Contributions are welcome! To contribute:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'feat: add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

Please follow the [Conventional Commits](https://www.conventionalcommits.org/) specification for commit messages.

---

##  License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**Built using Flutter & Laravel**

*TaskFlow | Organize your life, one task at a time.*

</div>
