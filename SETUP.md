# Netflix Clone Setup Instructions

Follow these steps to set up and run the Netflix Clone on your local machine.

## Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed and configured.
- [Firebase account](https://console.firebase.google.com/) and a new project created.
- [Node.js](https://nodejs.org/) (optional, for some Firebase CLI tools).

## Step 1: Firebase Configuration
1.  **Create a Firebase Project** in the Firebase Console.
2.  **Add Android/iOS Apps**:
    - For Android: Register the app with package name `com.example.netflix_clone`. Download `google-services.json` and place it in `android/app/`.
    - For iOS: Download `GoogleService-Info.plist` and place it in `ios/Runner/`.
3.  **Enable Firebase Services**:
    - **Authentication**: Enable Email/Password login.
    - **Firestore**: Create a database in "Start in test mode" (or set proper rules).
    - **Storage**: Set up storage for hosting video files (optional if using external URLs).
4.  **FlutterFire CLI (Recommended)**:
    - Run `dart pub global activate flutterfire_cli`.
    - Run `flutterfire configure` in the project root to automatically set up Firebase.

## Step 2: Firestore Database Setup
The app expects a collection named `movies` with documents containing:
- `title` (string)
- `description` (string)
- `thumbnailUrl` (string)
- `videoUrl` (string)
- `category` (string: "Trending", "Popular", "Recommended", etc.)
- `cast` (array of strings)
- `isTrending` (boolean)
- `isPopular` (boolean)

*Note: The app includes a fallback "seed data" method in `MovieProvider` if no data is found in Firestore.*

## Step 3: Run the App
1.  Connect your physical device or start an emulator.
2.  Open the terminal in the project root.
3.  Run `flutter pub get` to fetch dependencies.
4.  Run `flutter run`.

## Tech Stack
- **Framework**: Flutter
- **State Management**: Provider
- **Backend**: Firebase (Auth, Firestore)
- **Video Player**: Chewie & Video Player
- **Images**: Cached Network Image
- **Icons**: Material Icons
- **Fonts**: Google Fonts (Noto Sans)

## Key Features
- **User Authentication**: Sign up and login with email/password.
- **Home Screen**: Dynamic banner carousel and categorized movie lists.
- **Movie Details**: Synopsys, cast details, and actions.
- **Video Playback**: Full-screen player with controls.
- **Search**: Real-time movie searching.
- **Watchlist**: Save your favorite movies to "My List".
