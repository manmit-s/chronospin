# ChronoSpin ⏱️

**ChronoSpin** is a premium, modern speedcubing timer app built with Flutter. It is designed for speedcubers who value aesthetics, focus, and detailed analytics. With a distraction-free interface and comprehensive statistics, ChronoSpin helps you track your progress and break your personal bests.

## ✨ Features

### 🧩 **Smart Timer**
*   **Touch-to-Hold**: Professional hold-to-start mechanism with haptic feedback.
*   **Focus Mode**: Automatically hides all UI elements (stats, buttons, profile) while the timer is running for a zero-distraction solving environment.
*   **Real-time Scrambles**: Generates **DUMMY SCRAMBLES** for now. Will be replaced with **WCA-STYLE SCRAMBLES** in the future.

### 📊 **Advanced Analytics**
*   **Quick Stats**: View your Session Mean, Best Single (PB), Ao5, and Ao12 at a glance.
*   **Interactive Graphs**: Visualize your solve trends with dynamic graphs (toggle between last 50 or 100 solves).
*   **Activity Heatmap**: Track your daily practice consistency with a GitHub-style contribution heatmap (Last 90 days), featuring interactive "Quick Glance" tooltips.

### 📝 **History & Management**
*   **Detailed History**: Full log of all your solves with timestamps and penalties.
*   **Solve Details**: Tap any solve to view details, add notes, or apply penalties (+2, DNF).
*   **Local Persistence**: All data is securely saved locally using SQLite as of now, but will lookout for hybrid cloud sync in the future.

### 🎨 **Personalization**
*   **Dynamic Themes**: Choose from curated accent colors (Cyan, Yellow, Monochrome).
*   **Profile Stats**: Dedicated profile page showcasing your all-time analytics and progression.

---

## 🛠️ Technology Stack

*   **Framework**: [Flutter](https://flutter.dev/)
*   **State Management**: [Riverpod](https://riverpod.dev/)
*   **Database**: [sqflite](https://pub.dev/packages/sqflite) (Local SQL Storage)
*   **Charting**: [fl_chart](https://pub.dev/packages/fl_chart)
*   **Typography**: Google Fonts (Space Mono & Inter)

---

## 🚀 Quick Setup Guide

Follow these steps to get ChronoSpin running on your local machine.

### Prerequisites
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
*   An Android Simulator, iOS Simulator, or a physical device connected.

### Installation

1.  **Clone the Repository**
    ```bash
    git clone https://github.com/yourusername/chronospin.git
    cd chronospin
    ```

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Run the App**
    Connect your device and run:
    ```bash
    flutter run
    ```
    *Note: For the best visual experience, run on a physical device or a high-contrast OLED emulator.*

---

## 🔮 Future Roadmap

*   ☁️ **Cloud Sync**: Supabase integration for cross-device data synchronization.
*   🤝 **Social Features**: Share PBs and compete with friends.
*   🧩 **More Puzzles**: Support for 4x4, 2x2, Pyraminx, and other WCA puzzles.

---

**Happy Cubing!** 🟦🟧🟩⬜🟨🟥
