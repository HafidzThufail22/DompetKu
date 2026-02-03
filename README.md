# DompetKu 💰

A personal finance management app built with Flutter. Track your income, expenses, and manage multiple wallets with beautiful charts and intuitive interface.

![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?style=flat&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=flat&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## ✨ Features

- **Transaction Management** - Add, edit, and delete income/expense transactions
- **Multi-Wallet Support** - Create and manage multiple wallets (Cash, Bank, E-Wallet, etc.)
- **Category System** - Organize transactions with customizable categories
- **Monthly Reports** - Visual charts and statistics for financial overview
- **Dark Theme** - Modern dark UI design that's easy on the eyes
- **Offline First** - All data stored locally using SQLite
- **Indonesian Locale** - Date formatting and currency in Indonesian Rupiah (Rp)

## 📱 Screenshots

|             Home              |              Report               |               Settings                |
| :---------------------------: | :-------------------------------: | :-----------------------------------: |
| ![Home](screenshots/home.png) | ![Report](screenshots/report.png) | ![Settings](screenshots/settings.png) |

## 🛠️ Tech Stack

- **Framework**: Flutter 3.10+
- **State Management**: Provider
- **Local Database**: SQLite (sqflite)
- **Charts**: fl_chart
- **Preferences**: shared_preferences

## 📦 Dependencies

```yaml
dependencies:
  flutter: sdk
  provider: ^6.1.5
  sqflite: ^2.4.2
  path: ^1.9.1
  intl: ^0.20.2
  fl_chart: ^1.1.1
  shared_preferences: ^2.5.4
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.10 or higher
- Dart SDK 3.0 or higher
- Android Studio / VS Code with Flutter extension

### Installation

1. Clone the repository

   ```bash
   git clone https://github.com/yourusername/dompetku.git
   cd dompetku
   ```

2. Install dependencies

   ```bash
   flutter pub get
   ```

3. Run the app
   ```bash
   flutter run
   ```

### Build APK

```bash
flutter build apk --release
```

The APK will be available at `build/app/outputs/flutter-apk/app-release.apk`

## 📁 Project Structure

```
lib/
├── main.dart                   # App entry point
├── db/
│   └── database_helper.dart    # SQLite database operations
├── models/
│   ├── transaction_model.dart  # Transaction data model
│   ├── category_model.dart     # Category data model
│   └── wallet_model.dart       # Wallet data model
├── providers/
│   └── transaction_provider.dart  # State management
├── screens/
│   ├── main_screen.dart        # Bottom navigation container
│   ├── home_screen.dart        # Home with transactions list
│   ├── report_screen.dart      # Charts and statistics
│   └── settings_screen.dart    # App settings
└── widgets/                    # Reusable widgets
```

## 🎨 Color Scheme

| Color      | Hex       | Usage              |
| ---------- | --------- | ------------------ |
| Primary    | `#D4AF37` | Accent, buttons    |
| Background | `#0D0D0D` | App background     |
| Surface    | `#1A1A2E` | Cards, containers  |
| Income     | `#4CAF50` | Income indicators  |
| Expense    | `#F44336` | Expense indicators |

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

Made with ❤️ using Flutter

---

⭐ Star this repo if you find it helpful!
