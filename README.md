# Gym Timer

A minimalist rest timer for the gym, built with Flutter. Track your rest intervals between sets with preset timers, a sets counter, and persistent notifications — all wrapped in 18 beautiful themes.

## Features

- **Preset rest timers** — 30s, 45s, 60s, 90s, 120s, 150s, and 180s with one-tap start
- **Sets counter** — automatically increments on each timer start, tap to reset
- **Persistent notification** — shows countdown in the notification bar while the timer is running
- **Alert notification** — notifies you when rest time is over
- **Vibration feedback** — vibrates on timer completion (configurable)
- **18 built-in themes** — Tokyo Night, Catppuccin, Gruvbox, Nord, Rosé Pine, Kanagawa, Everforest, Solarized, Hackerman, and more
- **3 languages** — Português, English, Español
- **Preferences saved locally** — theme, language, and vibration settings persist across sessions

## Screenshots

<!-- Add screenshots here -->

## Tech Stack

- **Flutter** 3.11+
- **Dart** 3.11+
- **flutter_local_notifications** — timer countdown & alert notifications
- **vibration** — haptic feedback on timer end
- **shared_preferences** — persist user settings
- **flutter_localizations / intl** — i18n support

## Getting Started

### Prerequisites

- Flutter SDK 3.11 or later
- Android SDK (Android only for now)

### Install & Run

```bash
git clone https://github.com/<your-username>/gym_cronometro.git
cd gym_cronometro
flutter pub get
flutter run
```

## Available Themes

| Dark | Light |
|------|-------|
| Tokyo Night | Light |
| Catppuccin | Catppuccin Latte |
| Ethereal | Flexoki Light |
| Everforest | Solarized Light |
| Gruvbox | |
| Hackerman | |
| Kanagawa | |
| Matte Black | |
| Nord | |
| Osaka Jade | |
| Ristretto | |
| Rosé Pine | |
| Solarized Dark | |
| Dark | |

## License

This project is licensed under the [MIT License](LICENSE).
