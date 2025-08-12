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
    if (req.method !== 'DELETE') {
      return res.status(405).json({ error: 'Method not allowed' });
    }

    const { userId, caseId } = req.body;

    if (!userId || !caseId) {
      return res.status(400).json({ error: 'Missing required fields: userId, caseId' });
    }

    // Delete from both collections
    await db.collection('users').doc(userId).collection('cases').doc(caseId).delete();
    await db.collection('users').doc(userId).collection('recentCases').doc(caseId).delete();

    res.status(200).json({
      success: true,
      message: 'Case deleted successfully'
    });

  } catch (error) {
    console.error('Error in deleteCase:', error);
    res.status(500).json({
      error: 'Internal server error',
      message: error.message
    });
  }
};
