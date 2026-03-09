# WealthTracker

**Private. Open. Yours.**

WealthTracker is an open source, end-to-end encrypted personal finance app for tracking your net worth across assets, accounts, and investments. Available on Web, Android, and iOS.

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)

---

## Features

- **End-to-end encrypted** — data is encrypted on your device before it ever leaves. Nobody but you can read your finances.
- **Open source** — full source code is publicly auditable under GPL-3.0.
- **Self-hostable** — run your own backend instance with a single Docker command.
- **Cross-platform** — web, Android, and iOS with automatic encrypted sync.
- **One-time purchase** — no subscriptions, no ads, no data selling.
- **Offline support** — mobile apps cache data locally and sync when back online.

---

## Platforms

| Platform | Where to get it |
|---|---|
| Web | [web.wealthtracker.app](https://web.wealthtracker.app/) — free, no account required |
| Android | [Google Play](https://play.google.com/store/apps/details?id=app.wealthtracker) or APK from [Releases](https://github.com/KristianKalm/wealthtracker/releases) |
| iOS | [App Store](https://apps.apple.com) |

The web app is free to use. The Android and iOS apps are a one-time purchase — no subscriptions.

---

## Project Structure

```
wealthtracker/
├── app/          # Flutter app (Android, iOS, Web)
├── core/         # Shared Dart business logic & encryption
└── landingpage/  # Static landing page
```

The backend API lives in a separate repository: [KristianKalm/kryptic-api](https://github.com/KristianKalm/kryptic-api).

---

## Getting Started (Development)

**Prerequisites:** Flutter SDK ≥ 3.8, Dart SDK ≥ 3.8.

```bash
git clone https://github.com/KristianKalm/wealthtracker.git
cd wealthtracker/app
flutter pub get
flutter run
```

To regenerate code (JSON serialization, Drift DB):

```bash
dart run build_runner build
```

---

## Self-Hosting

You can run your own WealthTracker backend. See the [kryptic-api repository](https://github.com/KristianKalm/kryptic-api) for full setup instructions.

Once your server is running, point the app at your own backend URL in the app settings.

---

## Privacy & Security

- All data is encrypted locally using your password as the key before being sent to any server.
- The server only ever stores encrypted blobs — the server operator cannot read your data.
- We use AES-256 encryption. You can verify this by reading the source code in `core/`.
- **If you lose your password, your data cannot be recovered.** There is no password reset backdoor.
- No analytics SDKs, no trackers, no ads, no data selling.

---

## FAQ

**Can WealthTracker see my financial data?**
No. All data is encrypted on your device before it reaches any server. We have no ability to access or read your finances.

**Do I need an account to use it?**
No. The web app works immediately without an account. You need an account to sync data across devices.

**What happens if I forget my password?**
Your password is the encryption key. There is no recovery option — store it somewhere safe like a password manager.

**Can I export my data?**
Yes. You can export all your data as JSON from the app settings at any time.

**Can I contribute?**
Yes. Open an issue or pull request on GitHub. Bug reports, feature suggestions, translations, and code contributions are all welcome.

---

## License

[GNU General Public License v3.0](LICENSE)
