# mercari-client-dart

> **⚠️ Status: Under Development**
> This project is currently a work in progress. APIs may change, and features are still being added.

HTTP client for Mercari written in Dart. 

This library provides a way to interact with Mercari's API programmatically, handling the DPoP (Demonstration of Proof-of-Possession) authentication automatically.

## Prerequisites

- **Flutter SDK:** Required because this package relies on `webcrypto` for secure, native cryptographic operations.

## Getting Started

Follow these steps to get the project running locally.

### 1. Clone the repository

```bash
git clone https://github.com/BruceJian43/mercari-client-dart.git
cd mercari-client-dart
```

### 2. Install dependencies

Fetch the required Flutter packages:

```bash
flutter pub get
```

### 3. Setup WebCrypto

**Important**: This step is required to build the native library if you plan to run scripts directly using `dart run`.

```bash
flutter pub run webcrypto:setup
```

### 4. Run the example:

```bash
dart run example/search.dart "Nintendo Switch"
```

---

## Disclaimer
This is an unofficial library. It is not affiliated with, endorsed by, or connected to Mercari, Inc. Use this software responsibly and in accordance with Mercari's terms of service.
