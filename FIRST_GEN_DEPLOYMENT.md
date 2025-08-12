# Firebase Functions 1st Generation Deployment Guide

## Overview
This project uses Firebase Functions 1st Generation, which is compatible with the **Firebase Spark (free) plan**. This ensures you won't be charged for function executions within the free tier limits.

## Free Tier Limits (Firebase Spark Plan)
- **Function invocations**: 125K per month
- **GB-seconds**: 40K per month
- **CPU-seconds**: 40K per month
- **Outbound networking**: 5GB per month
- **Function timeout**: 540 seconds (9 minutes) max
- **Memory**: 256MB max

## Current Configuration
Our functions are optimized for the free tier:

### extractTimeline
- **Memory**: 256MB (free tier max)
- **Timeout**: 540 seconds (9 minutes)
- **Purpose**: AI-powered timeline extraction using Gemini API

### getRecentCases, getCase, deleteCase
- **Memory**: 128MB (optimized for free tier)
- **Timeout**: 60 seconds
- **Purpose**: Database operations

## Deployment Steps

### 1. Install Dependencies
```bash
cd functions
npm install
```

### 2. Set Gemini API Key
```bash
firebase functions:config:set gemini.api_key="YOUR_GEMINI_API_KEY"
```

### 3. Deploy Functions
```bash
firebase deploy --only functions
```

### 4. Verify Deployment
```bash
firebase functions:list
```

## Function URLs
After deployment, your functions will be available at:
- `https://us-central1-ross-ai-b6809.cloudfunctions.net/extractTimeline`
- `https://us-central1-ross-ai-b6809.cloudfunctions.net/getRecentCases`
- `https://us-central1-ross-ai-b6809.cloudfunctions.net/getCase`
- `https://us-central1-ross-ai-b6809.cloudfunctions.net/deleteCase`

## Cost Optimization Tips

### 1. Monitor Usage
```bash
firebase functions:log
```

### 2. Set Up Billing Alerts
- Go to Firebase Console > Usage and billing
- Set up budget alerts to avoid unexpected charges

### 3. Optimize Function Calls
- Batch operations when possible
- Use caching for frequently accessed data
- Implement proper error handling to avoid unnecessary retries

### 4. Memory Optimization
- Current functions use minimal memory (128MB-256MB)
- Text processing is optimized for free tier limits

## Troubleshooting

### Common Issues

#### 1. Function Timeout
If functions timeout, check:
- Text length (limited to 4000 chars for API)
- Network connectivity
- Gemini API response time

#### 2. Memory Issues
If you hit memory limits:
- Reduce text chunk size
- Optimize data processing
- Consider upgrading to Blaze plan if needed

#### 3. Cold Starts
1st gen functions may have cold starts:
- Functions warm up after first invocation
- Consider keeping functions warm with periodic calls

## Migration from 2nd Gen (if needed)
If you were using 2nd gen functions, the main differences are:
- Different import syntax
- Different configuration methods
- Different deployment commands
- Free tier compatibility

## Support
For issues with 1st gen functions:
- Check Firebase Console > Functions
- Review function logs
- Ensure you're within free tier limits
