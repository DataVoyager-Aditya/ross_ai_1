# Timeline Extraction Backend (Vercel)

A completely free backend for the Timeline Extraction feature using Vercel Serverless Functions.

## 🚀 Quick Start

### 1. Install Dependencies
```bash
npm install
```

### 2. Deploy to Vercel
```bash
# Install Vercel CLI (if not already installed)
npm install -g vercel

# Deploy
vercel --prod
```

### 3. Set Environment Variables
```bash
vercel env add GEMINI_API_KEY
vercel env add FIREBASE_PRIVATE_KEY
vercel env add FIREBASE_CLIENT_EMAIL
```

### 4. Update Flutter App
Update the base URL in your Flutter app:
```dart
static const String _baseUrl = 'https://your-app-name.vercel.app/api';
```

## 📁 Project Structure

```
vercel-backend/
├── api/
│   ├── extract-timeline.js    # Main timeline extraction endpoint
│   ├── get-recent-cases.js    # Get user's recent cases
│   ├── get-case.js           # Get specific case details
│   └── delete-case.js        # Delete a case
├── package.json              # Dependencies
├── vercel.json              # Vercel configuration
├── deploy.sh                # Deployment script
├── test-backend.js          # Test script
└── README.md               # This file
```

## 🔗 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/extract-timeline` | Extract timeline from text |
| GET | `/api/get-recent-cases` | Get recent cases for user |
| GET | `/api/get-case` | Get specific case details |
| DELETE | `/api/delete-case` | Delete a case |

## 🧪 Testing

Run the test script to verify your backend:
```bash
# Update the BASE_URL in test-backend.js first
node test-backend.js
```

## 💰 Free Tier Limits

- **Function Execution**: 100GB-hours/month
- **Bandwidth**: 100GB/month
- **Build Minutes**: 6,000 minutes/month

## 📚 Documentation

See `VERCEL_BACKEND_SETUP.md` for detailed setup instructions.

## 🔧 Troubleshooting

1. **Environment Variables**: Use `vercel env ls` to check
2. **Logs**: Use `vercel logs` to view function logs
3. **Redeploy**: Use `vercel --prod` to update

## 🆚 Why Vercel?

- ✅ **100% Free** - No billing setup required
- ✅ **Same Functionality** - Identical to Firebase Functions
- ✅ **Better Performance** - Global edge network
- ✅ **Easy Deployment** - One command deployment
