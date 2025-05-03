# AI-Powered Book Recommendation & Review App

An all-in-one Flutter mobile app that lets readers search for books, track their reading, write/edit/delete reviews, join discussion boards, and get AI-driven personalized suggestions.

---

## Features

- **Authentication**: Email/password sign-up & login via Firebase Auth  
- **User Profile & Preferences**: Save favorite genres, display name  
- **Book Search**: Google Books API lookup by title/author/ISBN  
- **Book Details**: Metadata, description, rating, reviews, discussion  
- **Reading Lists**: “Want to Read” / “Reading” / “Finished” management  
- **Reviews**: Write, edit, delete your book reviews (1–5 stars)  
- **Discussion Boards**: Threaded posts & replies per book/category  
- **AI Recommendations**: OpenAI-powered suggestions based on your tastes  
- **Offline Support**: Firestore caching for reads, queue writes when offline  

---

## Prerequisites

1. **Flutter & Dart SDK**  
   - Install from [flutter.dev](https://flutter.dev/docs/get-started/install)  
   - Make sure `flutter doctor` reports no critical errors.

2. **Android Toolchain**  
   - Java JDK 17 (e.g. Eclipse Temurin 17)  
     ```bash
     brew install --cask temurin17
     export JAVA_HOME="/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home"
     export PATH="$JAVA_HOME/bin:$PATH"
     ```
   - Android SDK & Platform Tools (via Android Studio)  
   - Set ANDROID_HOME / ANDROID_SDK_ROOT in your shell if needed.

3. **Environment Variables (.env)**  
   - Create a `.env` file at the **project root** (same level as `pubspec.yaml`).  
   - Add your API keys:
     ```
     # Google Books API
     GOOGLE_BOOKS_API_KEY=your_google_books_api_key_here

     # OpenAI API
     OPENAI_API_KEY=your_openai_api_key_here

     # (Optional) Other keys for Goodreads / NYTimes
     GOODREADS_API_KEY=...
     NYTIMES_API_KEY=...
     ```

4. **Firebase Setup**  
   - Create a Firebase project.  
   - Add an Android &/or iOS app to your project.  
   - Download & place `google-services.json` (Android) in `android/app/`  
     and `GoogleService-Info.plist` (iOS) in `ios/Runner/`.  
   - Enable **Authentication** (Email/Password) and **Cloud Firestore**.  
   - In Firestore, create a **single-field** or **composite** index on:
     - `reviews` collection: `bookId` (ascending) + `createdAt` (descending)
     - `discussions` collection: `category` + `parentId` + `createdAt`

5. **FlutterFire Configuration**  
   ```bash
   flutterfire configure \
     --project your-firebase-project-id \
     --out lib/firebase_options.dart
