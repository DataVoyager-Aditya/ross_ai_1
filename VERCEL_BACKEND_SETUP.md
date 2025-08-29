# Vercel Backend Setup Guide (100% Free)

This guide will help you deploy a completely free backend for your Timeline Extraction feature using Vercel.

## 🎯 **Why Vercel?**
- ✅ **100% Free** - No billing setup required
- ✅ **Serverless Functions** - Same functionality as Firebase Functions
- ✅ **Global CDN** - Fast response times worldwide
- ✅ **Easy Deployment** - One command deployment
- ✅ **Automatic HTTPS** - Secure by default

## 📋 **Prerequisites**

1. **Node.js 18+** installed
2. **Vercel CLI** installed: `npm i -g vercel`
3. **Firebase Service Account Key** (for Firestore access)
4. **Gemini API Key** from Google AI Studio

## 🚀 **Setup Steps**

### Step 1: Get Firebase Service Account Key

1. Go to [Firebase Console](https://console.firebase.google.com/project/ross-ai-b6809/settings/serviceaccounts/adminsdk)
2. Click "Generate new private key"
3. Download the JSON file
4. Note down these values:
   - `project_id`
   - `client_email`
   - `private_key`

### Step 2: Install Dependencies

```bash
cd vercel-backend
npm install
```

### Step 3: Deploy to Vercel

```bash
# Login to Vercel (first time only)
vercel login

# Deploy the backend
vercel --prod
```

### Step 4: Set Environment Variables

After deployment, set your environment variables:

```bash
# Set Gemini API Key
vercel env add GEMINI_API_KEY

# Set Firebase credentials
vercel env add FIREBASE_PRIVATE_KEY
vercel env add FIREBASE_CLIENT_EMAIL
```

**Note**: For `FIREBASE_PRIVATE_KEY`, paste the entire private key including `-----BEGIN PRIVATE KEY-----` and `-----END PRIVATE KEY-----`.

### Step 5: Update Flutter App

Update the base URL in your Flutter app:

```dart
// In lib/timeline_extractor/services/timeline_extractor_service.dart
static const String _baseUrl = 'https://your-app-name.vercel.app/api';
```

Replace `your-app-name` with your actual Vercel app name.

## 🔗 **API Endpoints**

Your Vercel backend will provide these endpoints:

- **POST** `/api/extract-timeline` - Extract timeline from text
- **GET** `/api/get-recent-cases` - Get recent cases
- **GET** `/api/get-case` - Get specific case
- **DELETE** `/api/delete-case` - Delete a case

## 💰 **Free Tier Limits (Vercel)**

- **Serverless Function Execution**: 100GB-hours/month
- **Bandwidth**: 100GB/month
- **Build Minutes**: 6,000 minutes/month
- **Function Size**: 50MB max

**For your use case**: You'll likely use less than 1% of these limits!

## 🧪 **Testing Your Backend**

### Test Timeline Extraction
```bash
curl -X POST https://your-app-name.vercel.app/api/extract-timeline \
  -H "Content-Type: application/json" \
  -d '{
    "text": "On January 15, 2024, a complaint was filed. On February 1, 2024, the hearing was scheduled.",
    "userId": "test_user_123"
  }'
```

### Test Get Recent Cases
```bash
curl "https://your-app-name.vercel.app/api/get-recent-cases?userId=test_user_123"
```

## 🔧 **Troubleshooting**

### Common Issues

#### 1. Environment Variables Not Set
```bash
# Check your environment variables
vercel env ls
```

#### 2. Firebase Connection Issues
- Verify your service account key is correct
- Ensure Firestore is enabled in your Firebase project
- Check that your Firebase project ID matches

#### 3. CORS Issues
The backend includes CORS headers, but if you have issues:
- Check that your Flutter app is using the correct URL
- Ensure the request includes proper headers

#### 4. Function Timeout
- Vercel functions have a 10-second timeout by default
- Timeline extraction is set to 30 seconds
- If you need longer, contact Vercel support

## 📊 **Monitoring**

### View Function Logs
```bash
vercel logs
```

### Check Function Performance
- Go to [Vercel Dashboard](https://vercel.com/dashboard)
- Select your project
- View "Functions" tab

## 🔄 **Updating Your Backend**

To update your backend after making changes:

```bash
vercel --prod
```

## 🆚 **Vercel vs Firebase Functions**

| Feature | Vercel | Firebase Functions |
|---------|--------|-------------------|
| **Cost** | 100% Free | Requires Blaze plan |
| **Setup** | Simple | Complex billing setup |
| **Performance** | Excellent | Excellent |
| **Global CDN** | Yes | Yes |
| **HTTPS** | Automatic | Automatic |
| **Monitoring** | Built-in | Built-in |

## 🎉 **Benefits of This Solution**

1. **Zero Cost** - No billing setup required
2. **Same Functionality** - All features work identically
3. **Better Performance** - Global edge network
4. **Easy Maintenance** - Simple deployment process
5. **Scalable** - Handles traffic spikes automatically

## 📞 **Support**

If you encounter issues:
1. Check the Vercel logs: `vercel logs`
2. Verify environment variables: `vercel env ls`
3. Test endpoints manually with curl
4. Check Firebase Console for Firestore issues

Your backend is now ready to use! 🚀
