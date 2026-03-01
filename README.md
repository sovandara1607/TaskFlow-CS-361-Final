<div align="center">

# TaskFlow

### A Full-Stack Task Management Application

**Flutter × Laravel — Modern, Beautiful, and Production-Ready**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Laravel](https://img.shields.io/badge/Laravel-12-FF2D20?logo=laravel&logoColor=white)](https://laravel.com)
[![PHP](https://img.shields.io/badge/PHP-8.2+-777BB4?logo=php&logoColor=white)](https://php.net)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web-lightgrey)]()

*A beautifully crafted, full-stack task management app featuring a liquid-glass UI design system, complete CRUD operations, token-based authentication with GitHub OAuth, dual notification system (server + local), dark mode, and bilingual localization (English/Khmer).*

---

**CS361 — Mobile Application Development • Final Project**
**ParagonU International University • Phnom Penh**

</div>

---

## 📋 Table of Contents

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

## 🔍 Overview

**TaskFlow** is a cross-platform task management application built with a modern mobile-first approach. The project demonstrates end-to-end software engineering — from designing a RESTful API with Laravel Sanctum authentication to implementing a responsive, animated Flutter client with Provider-based state management.

The app empowers users to organize their daily tasks across five customizable categories, track progress with real-time statistics on a time-of-day-aware dashboard, and stay on top of deadlines with a dual notification system (server-side event notifications + client-side local reminders) — all wrapped in a signature **liquid-glass** design language with pervasive backdrop blur, translucent gradients, and 3-D floating elements.

---

## ✨ Key Features

### 🗂 Task Management (Full CRUD)
- **Create** tasks with title, description, due date, category, and status
- **Read** tasks with filtering by status (`Pending`, `In Progress`, `Completed`) and category (`General`, `School`, `Work`, `Home`, `Personal`)
- **Update** tasks inline with pre-populated edit forms or quick-change status via popup menu
- **Delete** tasks with swipe-to-delete and confirmation dialogs
- **Toggle** task completion with swipe-to-complete gestures
- **Search** tasks by title or description in real time

### 🔐 Authentication & Security
- Email/password registration and login via **Laravel Sanctum** (token-based)
- **GitHub OAuth** sign-in with deep link callback (`taskflow://auth`)
- Auto-login with persisted tokens via `SharedPreferences`
- Token-scoped API — all task and notification data is isolated per authenticated user
- Profile editing (username, email, phone) synced to server
- Biometric authentication toggle (extensible via `local_auth`)

### 🎨 UI/UX — Liquid Glass Design System
- **Liquid-glass aesthetic** — pervasive use of `BackdropFilter` blur (σ = 12–40) with translucent gradient fills across navigation bars, drawers, cards, dialogs, and text fields
- **Coral 3-D FAB** — radial gradient floating action button with a custom dashed-ring `CustomPainter`
- **Animated greeting card** — time-of-day adaptive gradients (morning sun → afternoon sky → evening twilight → night moon) with a continuously bobbing icon animation
- **Material 3** with `colorSchemeSeed` and full light/dark theme support
- **Google Fonts** — Poppins (English) + Kantumruy Pro (Khmer) with locale-aware switching
- Smooth animations: splash fade/scale, card transitions, selected-tab pill expansion
- Responsive layout adapting to different screen sizes

### 🌍 Internationalization
- Bilingual support: **English** and **Khmer** (ភាសាខ្មែរ)
- **93 translated UI strings** per locale with runtime locale switching
- Custom in-app localization engine (no build-time code generation required)
- Locale-aware font family switching (Poppins ↔ Kantumruy Pro)

### 📊 Dashboard & Analytics
- Today view with time-of-day aware greeting (Morning / Afternoon / Evening / Night)
- Real-time task statistics in glass bubbles: Total, Pending, Active, Done
- Task lists grouped by status with section headers and counts
- Swipe-to-complete and swipe-to-delete directly from the dashboard
- Pull-to-refresh for live data sync

### 🔔 Dual Notification System
- **Server-side notifications** — Laravel creates records on task creation, task completion, login, and profile updates; displayed in a dedicated Notifications tab with unread badges
- **Client-side local reminders** — `flutter_local_notifications` schedules reminders at 8:00 AM on task due dates; fires immediately for overdue tasks
- Mark as read, mark all as read, swipe-to-dismiss, and clear all

### ⚙️ Settings & Preferences
- Dark mode toggle with system-wide theme propagation
- Language selector (EN/KM) with instant UI refresh
- Push notification toggle (re-schedules or cancels all local reminders)
- Biometric authentication toggle
- Privacy policy dialog
- All preferences persisted across sessions via `SharedPreferences`

---

## 🛠 Tech Stack

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

## 🏗 Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Flutter Client                           │
│                                                                 │
│  ┌───────────┐   ┌───────────────┐   ┌────────────────────┐    │
│  │  Screens   │──▶│   Providers   │──▶│    API Service      │    │
│  │  (11 UI)   │◀──│ (4 providers) │◀──│   (HTTP Client)     │    │
│  └───────────┘   └───────────────┘   └─────────┬──────────┘    │
│                                                 │               │
│  ┌───────────┐   ┌───────────────┐   ┌─────────┴──────────┐    │
│  │  Widgets   │   │    Models     │   │ NotificationService │    │
│  │ (6 glass)  │   │ (Task, Notif) │   │  (Local Reminders)  │    │
│  └───────────┘   └───────────────┘   └────────────────────┘    │
└─────────────────────────────────────────────────┼───────────────┘
                                                  │ HTTP/REST
                                                  │ Bearer Token
┌─────────────────────────────────────────────────┼───────────────┐
│                      Laravel API                │               │
│                                                 ▼               │
│  ┌───────────┐   ┌───────────────┐   ┌────────────────────┐    │
│  │  Routes    │──▶│  Controllers  │──▶│  Eloquent Models    │    │
│  │ (api.php)  │   │ (Auth/Task/   │   │ (User/Task/Notif)   │    │
│  └───────────┘   │  Notification) │   └─────────┬──────────┘    │
│                   └───────────────┘             │               │
│  ┌───────────┐   ┌───────────────┐              │               │
│  │  Sanctum   │   │  Migrations   │              ▼               │
│  │ (Tokens)   │   │  (10 files)   │       ┌──────────┐          │
│  └───────────┘   └───────────────┘       │  MySQL    │          │
│                                           └──────────┘          │
│  ┌─────────────────────────────┐                                │
│  │  NotificationService (PHP)  │ ← Server-side event dispatch   │
│  └─────────────────────────────┘                                │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📁 Project Structure

```
taskflow/
├── lib/                              # Flutter application source
│   ├── main.dart                     # App entry point, 4 providers, 9 named routes, Material 3 theming
│   ├── l10n/
│   │   └── app_localizations.dart    # 93 keys × 2 locales (EN/KM)
│   ├── models/
│   │   ├── task.dart                 # Task model (fromJson, toJson, copyWith, isOverdue)
│   │   └── app_notification.dart     # Notification model (icon, color, timeAgo)
│   ├── screens/
│   │   ├── splash_screen.dart        # Animated splash with elastic scale + auto-login
│   │   ├── login_screen.dart         # Email/password + GitHub OAuth + deep link listener
│   │   ├── register_screen.dart      # Registration form with password strength validation
│   │   ├── main_shell.dart           # 4-tab liquid-glass bottom nav + coral 3-D FAB
│   │   ├── home_screen.dart          # Today dashboard: greeting card, stats, grouped tasks
│   │   ├── task_list_screen.dart     # Searchable/filterable list + detail bottom sheet
│   │   ├── add_task_screen.dart      # Create form with category/status chip selectors
│   │   ├── edit_task_screen.dart     # Pre-populated edit form + delete capability
│   │   ├── profile_screen.dart       # Avatar, stats, account details, edit profile sheet
│   │   ├── settings_screen.dart      # Theme, language, notifications, about
│   │   └── notifications_screen.dart # Server notifications with unread badges & swipe actions
│   ├── services/
│   │   ├── api_service.dart          # REST client (tasks + notifications CRUD)
│   │   ├── auth_service.dart         # Auth API calls (login, register, OAuth, profile update)
│   │   ├── auth_provider.dart        # Auth state (token, user data, auto-login)
│   │   ├── task_provider.dart        # Task state (CRUD, computed stats, notification scheduling)
│   │   ├── app_settings_provider.dart # Settings persistence (theme, locale, toggles)
│   │   ├── notification_provider.dart # Server notifications state (fetch, read, delete)
│   │   └── notification_service.dart  # Local reminders (flutter_local_notifications, timezone)
│   ├── utils/
│   │   ├── constants.dart            # Color palette, dimensions, category/status helpers, glass colors
│   │   └── validators.dart           # 5 form validators (required, email, number, price, minLength)
│   └── widgets/
│       ├── TextTheme.dart            # Locale-aware font system (Poppins / Kantumruy Pro)
│       ├── glass_container.dart      # Reusable liquid-glass card (BackdropFilter + gradient)
│       ├── task_card.dart            # Task card with status popup menu + overdue badge
│       ├── app_drawer.dart           # Frosted-glass drawer with profile header + nav links
│       ├── app_dialogs.dart          # Glass confirmation, success, error dialogs + bottom sheets
│       └── custom_text_field.dart    # Liquid-glass text input with blur effect
│
├── taskflow-api/                     # Laravel backend API
│   ├── app/
│   │   ├── Http/Controllers/Api/
│   │   │   ├── AuthController.php        # Register, login, logout, OAuth, profile update
│   │   │   ├── TaskController.php        # Task CRUD (creates notifications on events)
│   │   │   └── NotificationController.php # Notification CRUD (read, mark, delete)
│   │   ├── Models/
│   │   │   ├── User.php                  # Sanctum tokens, tasks relationship, phone
│   │   │   ├── Task.php                  # Eloquent (status enum, category, user FK)
│   │   │   └── Notification.php          # Type, title, message, data (JSON), read_at
│   │   └── Services/
│   │       └── NotificationService.php   # Event dispatchers (task_created, completed, login, profile)
│   ├── database/migrations/              # 10 migration files
│   ├── routes/
│   │   ├── api.php                       # 14 API endpoints (auth + tasks + notifications)
│   │   └── web.php                       # GitHub OAuth redirect routes
│   └── ...
│
├── test/                             # Widget & unit tests
├── assets/images/                    # Static image assets
├── pubspec.yaml                      # Flutter dependencies
└── README.md                         # You are here
```

---

## 🚀 Getting Started

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
#    DB_USERNAME=root
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

## 📡 API Reference

> **Base URL:** `http://127.0.0.1:8000/api`
> **Authentication:** Bearer Token (Laravel Sanctum)

### Authentication Endpoints

| Method | Endpoint | Description | Auth |
|:---:|:---|:---|:---:|
| `POST` | `/register` | Register a new user | ✗ |
| `POST` | `/login` | Authenticate & receive token | ✗ |
| `POST` | `/auth/github` | GitHub OAuth token exchange | ✗ |
| `GET` | `/user` | Get authenticated user profile | ✓ |
| `PUT` | `/user` | Update profile (username, email, phone) | ✓ |
| `POST` | `/logout` | Revoke current access token | ✓ |

### Task Endpoints (Protected)

| Method | Endpoint | Description | Auth |
|:---:|:---|:---|:---:|
| `GET` | `/tasks` | List all tasks for current user | ✓ |
| `POST` | `/tasks` | Create a new task | ✓ |
| `GET` | `/tasks/{id}` | Get a specific task | ✓ |
| `PUT` | `/tasks/{id}` | Update a task | ✓ |
| `DELETE` | `/tasks/{id}` | Delete a task | ✓ |

### Notification Endpoints (Protected)

| Method | Endpoint | Description | Auth |
|:---:|:---|:---|:---:|
| `GET` | `/notifications` | List all notifications | ✓ |
| `GET` | `/notifications/unread-count` | Get unread notification count | ✓ |
| `PUT` | `/notifications/{id}/read` | Mark a notification as read | ✓ |
| `PUT` | `/notifications/read-all` | Mark all notifications as read | ✓ |
| `DELETE` | `/notifications/{id}` | Delete a notification | ✓ |
| `DELETE` | `/notifications` | Delete all notifications | ✓ |

### Request/Response Examples

<details>
<summary><b>POST /register</b></summary>

**Request:**
```json
{
  "username": "dara",
  "email": "dara@example.com",
  "password": "password123",
  "password_confirmation": "password123"
}
```

**Response (201):**
```json
{
  "user": {
    "id": 1,
    "username": "dara",
    "email": "dara@example.com"
  },
  "token": "1|abc123..."
}
```
</details>

<details>
<summary><b>POST /tasks</b></summary>

**Request:**
```json
{
  "title": "Complete CS361 project",
  "description": "Finish the Flutter CRUD final project",
  "status": "in_progress",
  "category": "school",
  "due_date": "2026-03-01"
}
```

**Response (201):**
```json
{
  "id": 1,
  "title": "Complete CS361 project",
  "description": "Finish the Flutter CRUD final project",
  "status": "in_progress",
  "category": "school",
  "due_date": "2026-03-01",
  "user_id": 1,
  "created_at": "2026-02-25T10:00:00.000000Z",
  "updated_at": "2026-02-25T10:00:00.000000Z"
}
```
</details>

### Validation Rules

| Field | Rules |
|:---|:---|
| `title` | Required, string, max 255 characters |
| `description` | Optional, string |
| `status` | Optional, one of: `pending`, `in_progress`, `completed` |
| `category` | Optional, one of: `general`, `school`, `work`, `home`, `personal` |
| `due_date` | Optional, valid date format |

---

## 🗄 Database Schema

### Users Table
| Column | Type | Constraints |
|:---|:---|:---|
| `id` | BIGINT | Primary Key, Auto Increment |
| `username` | VARCHAR | Required |
| `email` | VARCHAR | Required, Unique |
| `password` | VARCHAR | Nullable (for OAuth users) |
| `phone` | VARCHAR | Nullable |
| `github_id` | VARCHAR | Nullable, Unique |
| `avatar` | VARCHAR | Nullable |
| `email_verified_at` | TIMESTAMP | Nullable |
| `remember_token` | VARCHAR | Nullable |
| `created_at` | TIMESTAMP | Auto-managed |
| `updated_at` | TIMESTAMP | Auto-managed |

### Tasks Table
| Column | Type | Constraints |
|:---|:---|:---|
| `id` | BIGINT | Primary Key, Auto Increment |
| `title` | VARCHAR | Required |
| `description` | TEXT | Nullable |
| `status` | ENUM | `pending`, `in_progress`, `completed` (default: `pending`) |
| `category` | VARCHAR | Default: `general` |
| `due_date` | DATE | Nullable |
| `user_id` | BIGINT | Foreign Key → `users.id` (CASCADE delete) |
| `created_at` | TIMESTAMP | Auto-managed |
| `updated_at` | TIMESTAMP | Auto-managed |

### Notifications Table
| Column | Type | Constraints |
|:---|:---|:---|
| `id` | BIGINT | Primary Key, Auto Increment |
| `user_id` | BIGINT | Foreign Key → `users.id` (CASCADE delete) |
| `type` | VARCHAR | `task_created`, `task_completed`, `login_success`, `profile_updated` |
| `title` | VARCHAR | Notification title |
| `message` | TEXT | Notification body |
| `data` | JSON | Nullable, extra payload |
| `read_at` | TIMESTAMP | Nullable (null = unread) |
| `created_at` | TIMESTAMP | Auto-managed |
| `updated_at` | TIMESTAMP | Auto-managed |

---

## 🔑 Authentication Flow

### Email/Password Authentication
```
User → Login Screen → AuthService.login() → POST /api/login
                                                    ↓
                                            Sanctum Token
                                                    ↓
                              SharedPreferences ← AuthProvider ← Token stored
                                                    ↓
                              ApiService.setToken() → All subsequent requests
                                                      include Bearer token
```

### GitHub OAuth Flow
```
1. User taps "Sign in with GitHub"
2. url_launcher opens → GET /auth/github/redirect (Laravel)
3. Laravel redirects → GitHub Authorization Page
4. User authorizes → GitHub redirects → GET /login/oauth2/code/github (Laravel)
5. Laravel creates/finds user via Socialite → Generates Sanctum token
6. Redirect to deep link → taskflow://auth?token={TOKEN}
7. AppLinks listener captures URI → AuthProvider.loginWithToken()
8. Token persisted → User authenticated
```

### Auto-Login
```
App Launch → SplashScreen (2.5s animated splash)
                    ↓
          AuthProvider.tryAutoLogin()
                    ↓
          SharedPreferences.get('auth_token')
                    ↓
          GET /api/user (validate token)
                    ↓
          Valid? → Navigate to Home (MainShell)
          Invalid? → Navigate to Login
```

---

## 🖥 Screens & UI

### Navigation Structure

The app uses a **4-tab liquid-glass bottom navigation bar** with a floating coral FAB:

| Tab | Icon | Screen | Description |
|:---:|:---:|:---|:---|
| 0 | 🏠 | **Home** | Today dashboard with greeting, stats, grouped tasks |
| 1 | ✅ | **Tasks** | Searchable, filterable task list with detail sheets |
| 2 | 👤 | **Profile** | Avatar, account details, task statistics, edit sheet |
| 3 | 💬 | **Notifications** | Server notifications with unread badges |
| FAB | ➕ | **Add Task** | Create form (pushed as a separate route) |

### All Screens

| # | Screen | Key Features |
|:-:|:---|:---|
| 1 | **Splash** | Animated logo with elastic scale (1200ms), gradient background, auto-login check |
| 2 | **Login** | Glass card form, password visibility toggle, GitHub OAuth button + deep link listener |
| 3 | **Register** | Glass card form, password match validation, 8+ char requirement |
| 4 | **Home (Today)** | Time-of-day greeting card with floating animated icon, 4 stat bubbles, status-grouped task lists, pull-to-refresh |
| 5 | **Task List** | Glass search bar, status filter chips, category filter chips, task cards with swipe gestures, detail bottom sheet with inline status change |
| 6 | **Add Task** | Split layout (colored header + form card), glass title input, date picker, category/status chip selectors |
| 7 | **Edit Task** | Same layout as Add, pre-populated fields, header delete button with confirmation |
| 8 | **Profile** | Gradient avatar with initial, edit profile bottom sheet (username/email/phone), task stat cards, account detail rows, logout |
| 9 | **Settings** | Dark mode toggle, language dropdown, notification toggle (re-schedules reminders), privacy policy, about (v1.0.0), logout |
| 10 | **Notifications** | Mark all read / clear all actions, notification cards with type-based icons and colors, unread dot indicator, swipe-to-delete, relative timestamps |
| 11 | **Navigation Drawer** | Frosted-glass sidebar (blur: 24), profile header, nav groups in glass cards, pinned logout |

### Design System

| Element | Value |
|:---|:---|
| **Primary Color** | `#424242` (Dark Grey) |
| **Primary Light** | `#757575` |
| **Primary Dark** | `#212121` |
| **Pastel Accents** | Pink `#F0C6DB`, Mint `#A8E6CF`, Peach `#FFD3B6`, Lavender `#BDBDBD`, Sky `#B6D8F2` |
| **Semantic** | Success `#6BCB77`, Warning `#FFB347`, Error `#FF6B6B` |
| **Corner Radius** | Cards: `20px`, Inputs: `16px`, Nav Bar: `40px` |
| **Glass Blur** | σ 12 (cards) — σ 40 (nav bar, drawers) |
| **Fonts** | Poppins (EN) / Kantumruy Pro (KM) via Google Fonts |
| **Design Language** | Material 3 + Liquid Glass (BackdropFilter + translucent gradients) |

---

## 🧩 State Management

TaskFlow uses **Provider** with `ChangeNotifier` for reactive state management across four providers:

| Provider | Responsibility |
|:---|:---|
| `AuthProvider` | User authentication state, token management, auto-login, profile updates |
| `TaskProvider` | Task CRUD operations, list management, computed statistics (total/pending/active/done), local notification scheduling |
| `AppSettingsProvider` | Theme mode (light/dark), locale (en/km), notification & biometric toggles |
| `NotificationProvider` | Server notification state — fetch, unread count, mark read, delete |

All providers are injected at the root via `MultiProvider` and consumed with `context.watch<T>()` / `context.read<T>()` throughout the widget tree.

---

## 🌐 Localization

TaskFlow supports full bilingual UI localization:

| Language | Code | Font | Coverage |
|:---|:---:|:---|:---|
| English | `en` | Poppins | ✅ 93 strings |
| Khmer (ភាសាខ្មែរ) | `km` | Kantumruy Pro | ✅ 93 strings |

Language can be switched at runtime from **Settings → Language** and is persisted across sessions via `SharedPreferences`. The font family automatically switches to match the selected locale.

**Localized categories include:** app name, navigation labels, task statuses, category names, greetings (morning/afternoon/evening/night), form labels, validation messages, confirmations, success/error messages, and settings descriptions.

---

## 🔔 Notification System

TaskFlow implements a **dual notification architecture**:

### Server-Side (Laravel → Notifications Tab)
The Laravel backend creates `Notification` records when events occur:

| Event | Type | Trigger |
|:---|:---|:---|
| User logs in | `login_success` | `AuthController@login` |
| Task created | `task_created` | `TaskController@store` |
| Task completed | `task_completed` | `TaskController@update` (status → completed) |
| Profile updated | `profile_updated` | `AuthController@updateProfile` |

These are displayed in the **Notifications tab** with type-based icons, colors, unread indicators, and relative timestamps.

### Client-Side (flutter_local_notifications → System Tray)
The Flutter app schedules **local reminders** via `flutter_local_notifications`:

- Fires at **8:00 AM** on the task's due date
- Fires **immediately** if the task is already overdue at creation
- Automatically re-scheduled when tasks are updated
- Cancelled when tasks are deleted or completed
- Respects the notification toggle in Settings

---

## 📦 Dependencies

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

## 🤝 Contributing

Contributions are welcome! To contribute:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'feat: add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

Please follow the [Conventional Commits](https://www.conventionalcommits.org/) specification for commit messages.

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**Built with ❤️ using Flutter & Laravel**

*TaskFlow — Organize your life, one task at a time.*

</div>
