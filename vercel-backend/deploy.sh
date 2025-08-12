#!/bin/bash

echo "🚀 Deploying Timeline Extraction Backend to Vercel..."
echo ""

# Check if Vercel CLI is installed
if ! command -v vercel &> /dev/null; then
    echo "❌ Vercel CLI not found. Installing..."
    npm install -g vercel
fi

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Deploy to Vercel
echo "🌐 Deploying to Vercel..."
vercel --prod

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📝 Next steps:"
echo "1. Set your environment variables:"
echo "   vercel env add GEMINI_API_KEY"
echo "   vercel env add FIREBASE_PRIVATE_KEY"
echo "   vercel env add FIREBASE_CLIENT_EMAIL"
echo ""
echo "2. Update your Flutter app with the new API URL"
echo "3. Test your endpoints"
echo ""
echo "📚 See VERCEL_BACKEND_SETUP.md for detailed instructions"
