# My Office — Document Archive Mobile App

A Flutter mobile app to digitize document management for a real business — a notary office handling vehicle ownership transfers and authorizations. Built to replace paper-based document tracking with searchable digital archives.

> **🚧 Status:** Active development. Frontend in progress. Backend integration with Firebase coming next.

---

## The Problem

My family runs a notary services office that handles dozens of vehicle ownership transfers, sale deeds, and authorization documents every week. All paperwork is currently tracked on paper, making it hard to:

- Find past transactions quickly
- Verify document status (pending vs. completed)
- Securely store and back up sensitive legal paperwork

**This app aims to solve that.**

---

## Tech Stack

- **Framework:** Flutter (Dart)
- **Planned Backend:** Firebase Auth + Firestore + Firebase Storage
- **Document Scanning:** `cunning_document_scanner` package (planned)
- **Design References:** Real-world UI patterns from Dribbble and Mobbin

---

## Features

### ✅ Built so far
- Home screen with horizontal scrollable Quick Access cards (Identification Documents, Vehicle Sale Deeds, Sale Power of Attorney, Special Power of Attorney)
- Searchable transaction list with status indicators (completed / pending)
- Clean Material Design UI built with custom widgets

### 🛠️ Coming next
- [ ] Firebase Authentication (Admin login)
- [ ] Firestore integration for transaction data
- [ ] Document scanning via camera
- [ ] Firebase Storage for scanned documents and PDFs
- [ ] Transaction details screen
- [ ] Filter by document type

---

## Screenshots

> *Coming soon as more screens are built.*

---

## Why I'm Building This

I'm a CS graduate learning Flutter, and I wanted my first mobile app to solve a real problem rather than be another todo list. Building this app teaches me:

- Flutter widget composition and layout
- State management patterns
- Firebase backend integration
- Mobile UI/UX from real-world design references
- Working with cameras, file uploads, and cloud storage

Progress is iterative — small commits, daily improvements.

---

## Development Setup

### Requirements

- Flutter **3.41.9** (the same version CI uses, see `.github/workflows/ci.yml`)
- Xcode and CocoaPods (iOS only; the app targets iOS 15+)

### Firebase (one-time)

The Firebase config file is **not** in this repository. Each developer adds their own copy locally.

1. In the [Firebase console](https://console.firebase.google.com), create a project. The free **Spark** plan is enough for login and Firestore.
2. Add an **iOS app** with the bundle ID `com.omarkhaled.myoffice` and download `GoogleService-Info.plist`.
3. Copy it to `ios/Runner/GoogleService-Info.plist`, open `ios/Runner.xcworkspace` in Xcode and drag the file into the `Runner` group (target **Runner** checked).
   - The file is git-ignored. Never commit it.
4. **Authentication → Sign-in method:** enable **Email/Password**.
5. **Authentication → Users → Add user:** create the staff accounts. The app has no sign-up screen.
   - To reset a password, use the user's menu in the same list.

### Data location

Firestore and Storage both use **`europe-west1` (Belgium)**. The location is permanent once a database or bucket is created, so pick it when creating them:

- Firestore database: when Firestore is added.
- Storage bucket: when document uploads are added.

### Storage: Blaze plan and budget alert

Cloud Storage requires the pay-as-you-go **Blaze** plan. Before creating the Storage bucket:

1. Upgrade the project to **Blaze**.
2. In Google Cloud **Billing → Budgets & alerts**, create a **$5/month** budget with email alerts.

Budget alerts only send notifications. They do **not** stop charges.

### Run

```bash
flutter pub get
flutter run --release   # on a connected iPhone
flutter test
```

---

## Author

**Omar Khaled** — Computer Science graduate from Beirut Arab University.

- 🔗 [LinkedIn](https://www.linkedin.com/in/omar-khaled-b2b351311)
- 💻 [GitHub](https://github.com/Omaark97)