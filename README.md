<div align="center">
  <img src="https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white"/>
  <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase"/>
  <h1>VITality</h1>
  <p><strong>Decentralized Academic Collaboration & Social Discovery Network for VIT Pune.</strong></p>
</div>

## 🌐 Overview
**VITality** is a sleek, swipe-based matching application strictly engineered for academic networking, team building, and P2P collaboration at Vishwakarma Institute of Technology (VIT) Pune. 

By leveraging **Mesh-Networking (Nearby Connections)** coupled with an invisible **Firebase Cloud Backend**, VITality allows students to discover active peers in their immediate vicinity, view their tech stacks, and securely exchange end-to-end encrypted payloads (chats)—even in low-connectivity areas like crowded campus cafes or lecture halls.

## ✨ Core Features
- **Sybil-Resistant Registration**: Accounts strictly bound to 8-digit collegiate PRNs.
- **Sleek Dark Neon UI**: A highly responsive, 60fps-capable deep-space neon motif designed to reduce eye strain while looking impeccably modern.
- **Proximity Radar (P2P)**: Offline-capable peer discovery utilizing Bluetooth and WiFi-Direct technologies.
- **Algorithmic Matchmaking**: Find specific connections based on Branches, Year (FY/SY/TY/BTech), and Collaboration Goals (e.g., *Looking for Hackathon Teammates*).
- **Secure Encrypted Tunnels**: Real-time peer-to-peer chatting capabilities between matched nodes.

## ⚙️ Quick Start Installation

**1. Clone & Resolve Dependencies**
```bash
git clone https://github.com/your-repo/vitality.git
cd vitality
flutter pub get
```

**2. Synchronize Cloud Backend (Firebase)**
```bash
# If you don't have the CLI, install it via: npm install -g firebase-tools
firebase login
dart pub global run flutterfire_cli:flutterfire configure
```

**3. Build and Run**
```bash
flutter run
```

## 🛡️ License
Proprietary deployment. All code logic and implementation rights are reserved by its creator.
