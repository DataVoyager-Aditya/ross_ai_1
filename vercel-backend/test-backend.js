const axios = require('axios');

// Replace with your actual Vercel app URL
const BASE_URL = 'https://your-app-name.vercel.app/api';

async function testBackend() {
  console.log('🧪 Testing Vercel Backend...\n');

  try {
    // Test 1: Extract Timeline
    console.log('1️⃣ Testing Timeline Extraction...');
    const extractResponse = await axios.post(`${BASE_URL}/extract-timeline`, {
      text: 'On January 15, 2024, a complaint was filed against the defendant. On February 1, 2024, the hearing was scheduled. On March 10, 2024, the verdict was delivered.',
      userId: 'test_user_123'
    });
    
    console.log('✅ Timeline Extraction:', extractResponse.data.success ? 'SUCCESS' : 'FAILED');
    if (extractResponse.data.success) {
      console.log(`   Case ID: ${extractResponse.data.caseId}`);
      console.log(`   Events extracted: ${extractResponse.data.events.length}`);
    }
    console.log('');

    // Test 2: Get Recent Cases
    console.log('2️⃣ Testing Get Recent Cases...');
    const recentResponse = await axios.get(`${BASE_URL}/get-recent-cases?userId=test_user_123`);
    
    console.log('✅ Get Recent Cases:', recentResponse.data.success ? 'SUCCESS' : 'FAILED');
    if (recentResponse.data.success) {
      console.log(`   Cases found: ${recentResponse.data.cases.length}`);
    }
    console.log('');

    // Test 3: Get Specific Case
    if (extractResponse.data.success) {
      console.log('3️⃣ Testing Get Specific Case...');
      const caseResponse = await axios.get(`${BASE_URL}/get-case?userId=test_user_123&caseId=${extractResponse.data.caseId}`);
      
      console.log('✅ Get Specific Case:', caseResponse.data.success ? 'SUCCESS' : 'FAILED');
      if (caseResponse.data.success) {
        console.log(`   Case title: ${caseResponse.data.case.title}`);
      }
      console.log('');

      // Test 4: Delete Case
      console.log('4️⃣ Testing Delete Case...');
      const deleteResponse = await axios.delete(`${BASE_URL}/delete-case`, {
        data: {
          userId: 'test_user_123',
          caseId: extractResponse.data.caseId
        }
      });
      
      console.log('✅ Delete Case:', deleteResponse.data.success ? 'SUCCESS' : 'FAILED');
    }

    console.log('\n🎉 All tests completed!');

  } catch (error) {
    console.error('❌ Test failed:', error.response?.data || error.message);
  }
}

// Run tests
testBackend();
