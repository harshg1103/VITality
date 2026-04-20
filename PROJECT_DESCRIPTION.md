# VITality — Master Project Description & Technical Schema

This document serves as the absolute canonical blueprint for the **VITality** codebase. It meticulously deconstructs the architecture, technology choices, data pipelines, and administrative directives designed into the application.

---

## 1. Executive Concept
**VITality** fundamentally reimagines campus interaction. Operating mechanically as a highly intuitive swipe-based networking application, it conceptually functions as an encrypted **Campus Mesh Network**. Students ("Nodes") ping each other using local hardware capabilities. They search for academic synergy based on pre-defined overlapping tags (e.g., *Flutter*, *Firebase*, *C++*, *Hackathon Teams*). 

This allows strangers in a massive campus setting to instantly locate talented peers sitting a few benches away.

---

## 2. Technology Stack
* **Framework:** Flutter (Dart) — SDK Constraints `>3.0.0 <4.0.0`.
* **Proximity Protocol:** Google `nearby_connections` (Bluetooth / Low-Energy / WiFi-Direct).
* **Local Caching Interface:** `Hive` (High-performance lightweight NoSQL for Dart).
* **Remote Sync Interface:** `cloud_firestore` (NoSQL Document Cloud) & `firebase_auth`.
* **State Management:** Provider Architecture (`ChangeNotifier`).
* **UI/UX Accelerators:** `flutter_animate` (Micro-interactions), `appinio_swiper` (Gesture-based card swipe engine), `google_fonts` (Outfit Sans typography).

---

## 3. High-Level Coding Architecture

The architecture relies on a **Hybrid Dual-Stream Design**, intentionally isolating local device networking speeds from reliant cloud-polling logic to guarantee 100% responsiveness regardless of College WiFi stability.

### The Application Provider (`app_provider.dart`)
This serves as the single source of truth (SSOT) or the central "Brain".
- It listens intrinsically to `AuthService`, `P2PService`, and `DatabaseService`.
- **Flow:** When the PRN logs in, `app_provider` caches the active `UserModel`, kickstarts the `_p2p` proximity radar, and pulls `_loadMatches()` from the local Hive cache so there is **zero load time** for the user interface to populate.

### The P2P Engine (`p2p_service.dart`)
- Continuously broadcasts the device's endpoint ID under the namespace `vitality_node`.
- Listens for returning endpoints. Upon establishing a connection metric, payload streams are converted to byte arrays, encrypted, and mapped directly into the UI list arrays.

### The Database Engine (`database_service.dart`)
- **Background Worker:** Every time a node matches or fires a local message across the mesh, the `database_service` is spun up in the background asynchronously to **dual-write** the result into `Firebase Firestore`.
- By syncing only tiny logic triggers out to the web instead of routing all interaction through it, the app remains latency-free while generating a verifiable cloud paper-trail.

---

## 4. The Data Model Infrastructure

### 4.1 Local Cache Models (Hive `typeId`)
- `UserModel (0)`: Highly classified root instance. Holds hashed passwords locally if not on Firebase, along with extensive arrays for `goals` and `tags`.
- `MatchModel (1)`: Contains the `matchId`, the target `peerPrn`, their photo directory, and a local string array `messages[]` prefixed with `me:` or `them:`.

### 4.2 Cloud Synchronized Collections (Firestore)
- `/users/{PRN}`: Document containing `{ name, prn, branch, year, photoPath }`.
- `/matches/{MatchID}`: Document containing the exact moment of synergistic matching between two PRN strings.
- `/matches/{MatchID}/messages/{TimeStamp}`: Sub-collection explicitly retaining the conversational payloads of the students.

---

## 5. Security & Administrative Directives ("God Mode")

### 5.1 Firebase Security Matrix
Users are heavily sandboxed:
- A node authenticates using `FirebaseAuth` utilizing a pseudo-email (`12345678@vitality.app`) bound directly to the user-entered password.
- **Rule Design:** Nodes may only `READ` or `WRITE` to their respective `/users/{PRN}` documents, unless the Firestore request originates from a user with the boolean trigger `isAdmin == true`.

### 5.2 The 12413129 Citadel Authorization
The system is hard-coded to recognize PRN **`12413129`** as the absolute administrator. 
- During `DatabaseService.saveUser()`, the script autonomously appends `isAdmin: true` permanently to this singular PRN.

### 5.3 Features of the Admin God-View (`admin_dashboard.dart`)
When the admin accesses the UI shield:
1. **Directory God-View:** A continuously streamed read-out of every node currently operational within the campus network, displaying their names, specific hardware bindings, and tracking data.
2. **Conversation Auditing:** By streaming top-level collections from `/matches/`, the admin has total, unrestricted access to monitor peer-to-peer payloads, allowing enforcement of strict academic-only platform hygiene.
3. **Ghost Deletion:** The administrator wields hard "delete" privileges capable of annihilating matching arrays directly off the Firestore cloud, forcibly severing user connections in real-time.

---

## 6. Future Expansion Roadmap

### The PRN Whitelisting Overhaul
Currently, the registration node runs a regex string check (`^\d{8}$`) combined with an anti-collision check. However, inside the Firebase backend, a silent collection protocol `/prn_whitelist` is pre-designed.
- **Implementation Goal:** The administrator will upload a raw JSON or CSV list of valid, actively enrolled VIT students.
- **Lock-Out Logic:** When a generic user attempts a bootstrap registration, the `DatabaseService` will ping the `/prn_whitelist/{Entered_PRN}`. If the name, generated photo metrics, or Branch string do not mathematically correspond to this true registry, the Node Bootstrap will be aggressively rejected, rendering "Catfishing" or "Fake IDs" completely impossible on VIT campus. 
