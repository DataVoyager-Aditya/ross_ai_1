# Google Sign-In Setup Guide for ROSS AI

## Issues Fixed ✅

1. **Profile image preview** - Now shows properly in CircleAvatar for both web and mobile
2. **Profile image storage** - Images are now properly uploaded to Firebase Storage and URL stored in Firestore
3. **Android permissions** - Added internet permissions to AndroidManifest.xml
4. **Google Sign-in scopes** - Updated to include proper Google People API scopes
5. **User name handling** - Fixed name from signup form being properly stored

## Required Configuration Steps 🔧

### 1. Firebase Console Configuration

Go to your Firebase project: https://console.firebase.google.com/project/ross-ai-b6809

#### Enable Google People API
1. Go to Google Cloud Console: https://console.cloud.google.com/apis/library?project=ross-ai-b6809
2. Search for "Google People API"
3. Click on "Google People API"
4. Click "ENABLE"

#### Add SHA-1 Fingerprint (CRITICAL for Android)
1. In Firebase Console, go to Project Settings
2. Click on your Android app (com.example.ross_ai_1)
3. Scroll down to "SHA certificate fingerprints"
4. Click "Add Fingerprint"
5. Add this SHA-1 fingerprint: `B7:72:09:82:B6:B1:0C:AB:89:44:4F:1B:B9:38:78:80:4E:0D:04:8B`

#### Firebase Authentication Setup
1. Go to Authentication > Sign-in method
2. Enable "Google" provider
3. Enter your support email
4. Save configuration

### 2. Google Cloud Console Configuration

Go to: https://console.cloud.google.com/apis/credentials?project=ross-ai-b6809

#### Enable Required APIs
1. **Google People API** - For user profile information
2. **Google Sign-In API** - For authentication
3. **Firebase Authentication API** - For Firebase integration

#### OAuth 2.0 Client Configuration
1. Go to "Credentials" tab
2. Find your OAuth 2.0 client ID: `1042853929889-33qo9f34dgraulecq5k591npl2pejt1m.apps.googleusercontent.com`
3. Click on it to edit
4. Under "Authorized redirect URIs", ensure you have:
   - `https://ross-ai-b6809.firebaseapp.com/__/auth/handler`
5. Under "Restrictions", add your package name: `com.example.ross_ai_1`
6. Add the SHA-1 fingerprint: `B7:72:09:82:B6:B1:0C:AB:89:44:4F:1B:B9:38:78:80:4E:0D:04:8B`

### 3. Test the Configuration

After completing the above steps:

1. **Clean and rebuild** your app:
   ```bash
   flutter clean
   flutter pub get
   cd android && ./gradlew clean
   cd .. && flutter run
   ```

2. **Test Google Sign-in**:
   - Click "Continue with Google"
   - Should open Google sign-in dialog
   - After successful sign-in, user should be redirected to home page

3. **Test Image Upload**:
   - During signup, select a profile image
   - Verify image preview appears in the circular avatar
   - After signup, check Firebase Firestore to confirm profilePhoto field contains a URL

### 4. Troubleshooting

#### Common Error Messages and Solutions:

**"Google People API is not enabled"**
- Ensure Google People API is enabled in Google Cloud Console
- Wait 5-10 minutes after enabling for changes to propagate

**"API key not valid"**
- Check that google-services.json is properly placed in android/app/
- Verify API key is enabled for required APIs

**"Sign in failed" with no specific error**
- Verify SHA-1 fingerprint is added to both Firebase and Google Cloud Console
- Check that package name matches exactly: `com.example.ross_ai_1`

**Profile image not uploading**
- Check Firebase Storage rules allow authenticated users to write
- Verify Firebase Storage is enabled in your project

### 5. Firebase Storage Rules (CRITICAL!)

**This is likely the main issue with your empty profilePhoto!**

Go to Firebase Console > Storage > Rules and update your Firebase Storage rules:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Allow authenticated users to upload profile images
    match /profile_images/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Temporary rule for debugging - allows all authenticated users
    // Remove this after testing
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**To apply these rules:**
1. Go to Firebase Console > Storage
2. Click on "Rules" tab
3. Replace the existing rules with the above
4. Click "Publish"

**Default rules might be blocking uploads!** If your rules currently look like this:
```javascript
// Default rules that BLOCK uploads
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

### 6. Production Considerations

For production release:
1. Generate a release keystore
2. Get SHA-1 fingerprint for release keystore
3. Add release SHA-1 to Firebase and Google Cloud Console
4. Update google-services.json if needed
5. Test thoroughly with release build

## Current Configuration Details

- **Project ID**: ross-ai-b6809
- **Package Name**: com.example.ross_ai_1
- **Debug SHA-1**: B7:72:09:82:B6:B1:0C:AB:89:44:4F:1B:B9:38:78:80:4E:0D:04:8B
- **OAuth Client ID**: 1042853929889-33qo9f34dgraulecq5k591npl2pejt1m.apps.googleusercontent.com

## What Was Fixed in Code

1. **lib/auth/signup.dart**:
   - Added proper image preview for web using MemoryImage
   - Fixed name parameter passing to auth provider

2. **lib/auth/provider/auth_provider.dart**:
   - Added Google People API scopes
   - Fixed user name handling
   - Updated method signature for name parameter

3. **android/app/src/main/AndroidManifest.xml**:
   - Added internet and network state permissions

All code changes maintain the existing functionality while fixing the identified issues.
