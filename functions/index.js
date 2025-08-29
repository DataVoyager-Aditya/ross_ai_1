// Firebase Functions 1st Generation - Free Tier/Blaze Compatible
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const cors = require('cors')({ origin: true });
const axios = require('axios');
const { PDFExtract } = require('pdf.js-extract');
const mammoth = require('mammoth');

// Initialize Firebase Admin
if (admin.apps.length === 0) {
  admin.initializeApp();
}

const db = admin.firestore();

// Gemini API configuration
const GEMINI_API_KEY = (functions.config().gemini && functions.config().gemini.api_key) || process.env.GEMINI_API_KEY;
const GEMINI_API_URL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

async function extractTimelineFromText(text) {
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
  }
]

Case text (truncate if needed):\n${text.slice(0, 12000)}

Ensure no extra text, comments, or explanations—only valid JSON array.`;

  const response = await axios.post(
    `${GEMINI_API_URL}?key=${GEMINI_API_KEY}`,
    {
      contents: [
        {
          parts: [
            { text: prompt }
          ]
        }
      ]
    },
    { headers: { 'Content-Type': 'application/json' } }
  );

  const generatedText = response?.data?.candidates?.[0]?.content?.parts?.[0]?.text || '';
  const jsonMatch = generatedText.match(/\[[\s\S]*\]/);
  if (!jsonMatch) {
    throw new Error('No valid JSON found in model response');
  }

  const events = JSON.parse(jsonMatch[0]);
  if (!Array.isArray(events)) {
    throw new Error('Extracted content is not an array');
  }

  return events.map((e) => ({
    title: e.title || 'Untitled',
    date: e.date || 'Unknown',
    description: e.description || ''
  }));
}

// Extract text from different file formats
async function extractTextFromFile(fileBuffer, fileName) {
  const fileExtension = fileName.split('.').pop().toLowerCase();
  
  try {
    switch (fileExtension) {
      case 'txt':
        return fileBuffer.toString('utf8');
        
      case 'pdf':
        const pdfExtract = new PDFExtract();
        const data = await pdfExtract.extractBuffer(fileBuffer);
        return data.pages.map(page => page.content.map(item => item.str).join(' ')).join('\n');
        
      case 'docx':
        const result = await mammoth.extractRawText({ buffer: fileBuffer });
        return result.value;
        
      default:
        throw new Error(`Unsupported file format: ${fileExtension}`);
    }
  } catch (error) {
    throw new Error(`Failed to extract text from ${fileName}: ${error.message}`);
  }
}

function generateCaseId() {
  return `case_${Date.now()}_${Math.random().toString(36).slice(2, 10)}`;
}

// POST /extractTimeline
exports.extractTimeline = functions
  .runWith({ timeoutSeconds: 540, memory: '256MB' })
  .https.onRequest((req, res) => {
    cors(req, res, async () => {
      try {
        if (req.method !== 'POST') {
          return res.status(405).json({ error: 'Method not allowed' });
        }

        const { text, userId, caseId } = req.body || {};
        if (!text || !userId) {
          return res.status(400).json({ error: 'Missing required fields: text, userId' });
        }

        const finalCaseId = caseId || generateCaseId();
        const events = await extractTimelineFromText(text);
        if (!events.length) {
          return res.status(400).json({ error: 'No events extracted' });
        }

        const caseData = {
          caseId: finalCaseId,
          uploadedAt: admin.firestore.FieldValue.serverTimestamp(),
          title: events[0]?.title || 'Untitled Case',
          events,
          userId,
          textLength: text.length
        };

        await db.collection('users').doc(userId).collection('cases').doc(finalCaseId).set(caseData);

        const recentCase = {
          caseId: finalCaseId,
          title: caseData.title,
          uploadedAt: caseData.uploadedAt,
          eventCount: events.length,
          firstEventDate: events[0]?.date || 'Unknown'
        };
        await db.collection('users').doc(userId).collection('recentCases').doc(finalCaseId).set(recentCase);

        return res.status(200).json({ success: true, caseId: finalCaseId, events, message: 'ok' });
      } catch (err) {
        console.error('extractTimeline error:', err);
        return res.status(500).json({ error: 'Internal error', message: err.message });
      }
    });
  });

// GET /getRecentCases?userId=...
exports.getRecentCases = functions
  .runWith({ timeoutSeconds: 60, memory: '128MB' })
  .https.onRequest((req, res) => {
    cors(req, res, async () => {
      try {
        if (req.method !== 'GET') {
          return res.status(405).json({ error: 'Method not allowed' });
        }
        const { userId } = req.query || {};
        if (!userId) {
          return res.status(400).json({ error: 'Missing required parameter: userId' });
        }

        const snap = await db
          .collection('users')
          .doc(userId)
          .collection('recentCases')
          .orderBy('uploadedAt', 'desc')
          .limit(5)
          .get();

        const cases = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
        return res.status(200).json({ success: true, cases });
      } catch (err) {
        console.error('getRecentCases error:', err);
        return res.status(500).json({ error: 'Internal error', message: err.message });
      }
    });
  });

// GET /getCase?userId=...&caseId=...
exports.getCase = functions
  .runWith({ timeoutSeconds: 60, memory: '128MB' })
  .https.onRequest((req, res) => {
    cors(req, res, async () => {
      try {
        if (req.method !== 'GET') {
          return res.status(405).json({ error: 'Method not allowed' });
        }
        const { userId, caseId } = req.query || {};
        if (!userId || !caseId) {
          return res.status(400).json({ error: 'Missing required parameters: userId, caseId' });
        }

        const doc = await db.collection('users').doc(userId).collection('cases').doc(caseId).get();
        if (!doc.exists) {
          return res.status(404).json({ error: 'Case not found' });
        }
        return res.status(200).json({ success: true, case: { id: doc.id, ...doc.data() } });
      } catch (err) {
        console.error('getCase error:', err);
        return res.status(500).json({ error: 'Internal error', message: err.message });
      }
    });
  });

// POST /processFiles
exports.processFiles = functions
  .runWith({ timeoutSeconds: 540, memory: '512MB' })
  .https.onRequest((req, res) => {
    cors(req, res, async () => {
      try {
        if (req.method !== 'POST') {
          return res.status(405).json({ error: 'Method not allowed' });
        }

        const { files, userId, caseId } = req.body || {};
        if (!files || !Array.isArray(files) || files.length === 0 || !userId) {
          return res.status(400).json({ error: 'Missing required fields: files array, userId' });
        }

        const finalCaseId = caseId || generateCaseId();
        let mergedText = '';

        // Process each file
        for (const fileData of files) {
          const { fileName, fileContent, fileType } = fileData;
          
          if (!fileName || !fileContent) {
            continue;
          }

          // Convert base64 to buffer
          const fileBuffer = Buffer.from(fileContent, 'base64');
          
          // Extract text from file
          const fileText = await extractTextFromFile(fileBuffer, fileName);
          mergedText += `\n\n--- File: ${fileName} ---\n\n${fileText}`;
        }

        if (!mergedText.trim()) {
          return res.status(400).json({ error: 'No text could be extracted from files' });
        }

        // Extract timeline from merged text
        const events = await extractTimelineFromText(mergedText);
        if (!events.length) {
          return res.status(400).json({ error: 'No events extracted' });
        }

        const caseData = {
          caseId: finalCaseId,
          uploadedAt: admin.firestore.FieldValue.serverTimestamp(),
          title: events[0]?.title || 'Untitled Case',
          events,
          userId,
          textLength: mergedText.length,
          fileCount: files.length,
          fileNames: files.map(f => f.fileName)
        };

        await db.collection('users').doc(userId).collection('cases').doc(finalCaseId).set(caseData);

        const recentCase = {
          caseId: finalCaseId,
          title: caseData.title,
          uploadedAt: caseData.uploadedAt,
          eventCount: events.length,
          firstEventDate: events[0]?.date || 'Unknown',
          fileCount: files.length
        };
        await db.collection('users').doc(userId).collection('recentCases').doc(finalCaseId).set(recentCase);

        return res.status(200).json({ success: true, caseId: finalCaseId, events, message: 'ok' });
      } catch (err) {
        console.error('processFiles error:', err);
        return res.status(500).json({ error: 'Internal error', message: err.message });
      }
    });
  });

// DELETE /deleteCase
exports.deleteCase = functions
  .runWith({ timeoutSeconds: 60, memory: '128MB' })
  .https.onRequest((req, res) => {
    cors(req, res, async () => {
      try {
        if (req.method !== 'DELETE') {
          return res.status(405).json({ error: 'Method not allowed' });
        }
        const { userId, caseId } = req.body || {};
        if (!userId || !caseId) {
          return res.status(400).json({ error: 'Missing required fields: userId, caseId' });
        }

        await db.collection('users').doc(userId).collection('cases').doc(caseId).delete();
        await db.collection('users').doc(userId).collection('recentCases').doc(caseId).delete();

        return res.status(200).json({ success: true, message: 'Deleted' });
      } catch (err) {
        console.error('deleteCase error:', err);
        return res.status(500).json({ error: 'Internal error', message: err.message });
      }
    });
  });
