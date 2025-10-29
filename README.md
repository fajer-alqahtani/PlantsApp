# 🌿 Planto — Smart Plant Care Reminders

**Planto** is a modern iOS app built with **SwiftUI** and **SwiftData** that helps users keep their plants healthy and thriving.  
With Planto, users can add plants, set personalized watering reminders, and get automatic notifications when it’s time to water them — all in a clean, calming interface.

---

## ✨ Features

- 🪴 **Smart Plant Tracking** — Add plants with details like name, room, light type, watering days, and water amount.  
- 🔔 **Custom Notifications** — Automatically reminds you when it’s time to water your plants.  
- 💧 **Progress Indicators** — Visual cues show which plants have been watered today.  
- 🌈 **Fluid Animations** — Beautiful transitions and progress bars with SwiftUI.  
- 🧠 **Local Data Storage** — Uses `SwiftData` for local persistence — no internet required.  
- 🌗 **Dark Mode First** — Fully optimized for dark mode UI.  
- 🖼️ **Custom App Icon & Notifications Banner** — Uses a clean 1024×1024 non-transparent app icon for consistency across iOS.

---

## 🧩 Architecture

Planto follows a **MVVM-inspired SwiftUI structure**:

| Component | File | Description |
|------------|------|-------------|
| `Plant.swift` | Model | Defines the Plant object stored in SwiftData |
| `PlantsListView.swift` | View | Displays all plants with progress indicators & actions |
| `SetReminder.swift` | View | Sheet for adding new plants/reminders |
| `NotificationManager.swift` | Utility | Handles scheduling of local notifications |
| `ContentView.swift` | Entry | Launch screen that welcomes users |
| `Plants_AppApp.swift` | App Entry | Initializes SwiftData container and sets main view |

---

## ⚙️ Technologies Used

- **SwiftUI** – Declarative UI design  
- **SwiftData** – Lightweight persistence layer for models  
- **UserNotifications Framework** – Local notifications scheduling  
- **MVVM Pattern** – Clean separation of UI and data logic  

---

## 🪴 Notification Setup

The app automatically requests permission for notifications on first launch.  
It uses `NotificationManager.swift` to schedule reminders for each plant.

<img width="1021" height="565" alt="‏لقطة الشاشة ١٤٤٧-٠٥-٠٧ في ١٠ ١٦ ٣٠ ص" src="https://github.com/user-attachments/assets/ef1c11b4-08ca-4aac-9581-1bbfdccc9144" />


