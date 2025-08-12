# Timeline Extraction Backend Setup

This document provides setup instructions for the Timeline Extraction feature backend.

## Prerequisites

1. Firebase project with Firestore and Storage enabled
2. Gemini API key from Google AI Studio
3. Node.js 16+ installed (for 1st gen functions)
4. Firebase CLI installed

## Setup Instructions

### 1. Firebase Functions Setup (1st Generation - Free Tier)

Navigate to the functions directory and install dependencies:

```bash
cd functions
npm install
```

**Note**: These are 1st generation functions optimized for the Firebase Spark (free) plan. See `FIRST_GEN_DEPLOYMENT.md` for detailed free tier information.

### 2. Configure Gemini API Key

Set your Gemini API key in Firebase Functions configuration:

```bash
firebase functions:config:set gemini.api_key="YOUR_GEMINI_API_KEY"
```

### 3. Deploy Firebase Functions

Deploy the functions to Firebase:

```bash
firebase deploy --only functions
```

### 4. Update Flutter Dependencies

The following packages have been added to `pubspec.yaml`:

```yaml
dependencies:
  file_picker: ^6.1.1
  path: ^1.8.3
  syncfusion_flutter_pdf: ^24.2.9
  archive: ^3.4.10
```

Run `flutter pub get` to install the dependencies.

### 5. Update Main App

Add the TimelineExtractorProvider to your main app's provider list:

```dart
import 'package:provider/provider.dart';
import 'timeline_extractor/provider/timeline_extractor_provider.dart';

// In your MaterialApp or main widget
MultiProvider(
  providers: [
    // ... other providers
    ChangeNotifierProvider(create: (_) => TimelineExtractorProvider()),
  ],
  child: YourApp(),
)
```

## API Endpoints

The following Firebase Functions endpoints are available:

### POST /extractTimeline
Extract timeline from text using Gemini API.

**Request Body:**
```json
{
  "text": "Your legal case text here...",
  "userId": "user_id",
  "caseId": "optional_case_id"
}
```

**Response:**
```json
{
  "success": true,
  "caseId": "generated_case_id",
  "events": [
    {
      "title": "Filed FIR against the accused",
      "date": "2024-01-03",
      "description": "Formal complaint was registered..."
    }
  ],
  "message": "Timeline extracted successfully"
}
```

### GET /getRecentCases?userId={userId}
Get recent cases for a user.

**Response:**
```json
{
  "success": true,
  "cases": [
    {
      "id": "case_id",
      "caseId": "case_id",
      "title": "Case Title",
      "uploadedAt": "timestamp",
      "eventCount": 5,
      "firstEventDate": "2024-01-03"
    }
  ]
}
```

### GET /getCase?userId={userId}&caseId={caseId}
Get specific case details.

**Response:**
```json
{
  "success": true,
  "case": {
    "id": "case_id",
    "caseId": "case_id",
    "uploadedAt": "timestamp",
    "title": "Case Title",
    "events": [...],
    "userId": "user_id",
    "textLength": 1500
  }
}
```

### DELETE /deleteCase
Delete a case.

**Request Body:**
```json
{
  "userId": "user_id",
  "caseId": "case_id"
}
```

## Firestore Schema

### users/{userId}/cases/{caseId}
```json
{
  "caseId": "string",
  "uploadedAt": "timestamp",
  "title": "string",
  "events": [
    {
      "title": "string",
      "date": "YYYY-MM-DD",
      "description": "string"
    }
  ],
  "userId": "string",
  "textLength": "number"
}
```

### users/{userId}/recentCases/{caseId}
```json
{
  "caseId": "string",
  "title": "string",
  "uploadedAt": "timestamp",
  "eventCount": "number",
  "firstEventDate": "string"
}
```

## Firebase Storage Structure

Files are stored in: `timeline_uploads/{userId}/{caseId}/{filename}`

## Error Handling

The backend includes comprehensive error handling for:

- Invalid file formats
- Empty text content
- API timeouts
- Authentication errors
- Invalid JSON responses from Gemini API

## Performance Considerations

- Text is limited to 4000 characters for Gemini API calls
- Large files are processed in chunks
- Intermediate results are stored in Firestore for debugging
- File uploads are handled asynchronously

## Security Rules

Ensure your Firestore security rules allow authenticated users to access their own data:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Testing

Test the endpoints using tools like Postman or curl:

```bash
# Test timeline extraction
curl -X POST https://us-central1-ross-ai-b6809.cloudfunctions.net/extractTimeline \
  -H "Content-Type: application/json" \
  -d '{"text": "Your test case text", "userId": "test_user"}'
```

## Troubleshooting

1. **Functions not deploying**: Check Node.js version and Firebase CLI installation
2. **API key errors**: Verify Gemini API key is correctly set in Firebase config
3. **CORS errors**: Functions include CORS headers for web access
4. **File upload issues**: Check Firebase Storage rules and authentication
