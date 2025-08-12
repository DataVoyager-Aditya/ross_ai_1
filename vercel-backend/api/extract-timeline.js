const axios = require('axios');
const admin = require('firebase-admin');

// Initialize Firebase Admin if not already initialized
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert({
      projectId: process.env.FIREBASE_PROJECT_ID,
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
      privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
    }),
  });
}

const db = admin.firestore();
const GEMINI_API_URL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

// Extract timeline from text using Gemini API
async function extractTimelineFromText(text) {
  try {
    const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
    if (!GEMINI_API_KEY) {
      throw new Error('Gemini API key not configured');
    }

    const prompt = `Extract chronological legal events from the given case text. 
Return ONLY valid JSON in the format:
[
  {
    "title": "Filed FIR against the accused",
    "date": "YYYY-MM-DD",
    "description": "Formal complaint was registered..."
  },
  ...
]

Case text: ${text.substring(0, 4000)} // Limit to 4000 chars for API

Ensure no extra text, comments, or explanations—only valid JSON array.`;

    const response = await axios.post(
      `${GEMINI_API_URL}?key=${GEMINI_API_KEY}`,
      {
        contents: [{
          parts: [{
            text: prompt
          }]
        }]
      },
      {
        headers: {
          'Content-Type': 'application/json'
        }
      }
    );

    const generatedText = response.data.candidates[0].content.parts[0].text;
    
    // Extract JSON from response
    const jsonMatch = generatedText.match(/\[[\s\S]*\]/);
    if (!jsonMatch) {
      throw new Error('No valid JSON found in response');
    }

    const events = JSON.parse(jsonMatch[0]);
    
    // Validate events structure
    if (!Array.isArray(events)) {
      throw new Error('Response is not an array');
    }

    return events.map(event => ({
      title: event.title || 'Unknown Event',
      date: event.date || 'Unknown Date',
      description: event.description || 'No description available'
    }));

  } catch (error) {
    console.error('Error extracting timeline:', error);
    throw new Error(`Timeline extraction failed: ${error.message}`);
  }
}

// Generate unique case ID
function generateCaseId() {
  return `case_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
}

module.exports = async (req, res) => {
  // Enable CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  // Handle preflight requests
  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  try {
    if (req.method !== 'POST') {
      return res.status(405).json({ error: 'Method not allowed' });
    }

    const { text, userId, caseId } = req.body;

    if (!text || !userId) {
      return res.status(400).json({ error: 'Missing required fields: text, userId' });
    }

    if (!text.trim()) {
      return res.status(400).json({ error: 'Text content cannot be empty' });
    }

    const finalCaseId = caseId || generateCaseId();

    // Extract timeline from text
    const events = await extractTimelineFromText(text);

    if (!events || events.length === 0) {
      return res.status(400).json({ error: 'No events could be extracted from the text' });
    }

    // Save to Firestore
    const caseData = {
      caseId: finalCaseId,
      uploadedAt: admin.firestore.FieldValue.serverTimestamp(),
      title: events[0]?.title || 'Untitled Case',
      events: events,
      userId: userId,
      textLength: text.length
    };

    // Save full case data
    await db.collection('users').doc(userId).collection('cases').doc(finalCaseId).set(caseData);

    // Save to recent cases
    const recentCaseData = {
      caseId: finalCaseId,
      title: caseData.title,
      uploadedAt: caseData.uploadedAt,
      eventCount: events.length,
      firstEventDate: events[0]?.date || 'Unknown'
    };

    await db.collection('users').doc(userId).collection('recentCases').doc(finalCaseId).set(recentCaseData);

    res.status(200).json({
      success: true,
      caseId: finalCaseId,
      events: events,
      message: 'Timeline extracted successfully'
    });

  } catch (error) {
    console.error('Error in extractTimeline:', error);
    res.status(500).json({
      error: 'Internal server error',
      message: error.message
    });
  }
};
