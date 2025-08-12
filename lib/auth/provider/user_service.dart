import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create user profile
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String role,
    String? name,
    String? profilePhoto,
    bool isGuest = false,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'role': role,
        'name': name ?? 'User',
        'profilePhoto': profilePhoto ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'isGuest': isGuest,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating user profile: $e');
      rethrow;
    }
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Update last login
  Future<void> updateLastLogin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating last login: $e');
    }
  }

  // Delete user profile
  Future<void> deleteUserProfile(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
    } catch (e) {
      print('Error deleting user profile: $e');
      rethrow;
    }
  }

  // Check if user profile exists
  Future<bool> userProfileExists(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      return doc.exists;
    } catch (e) {
      print('Error checking user profile existence: $e');
      return false;
    }
  }

  // Get all users (for admin purposes)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }

  // Search users by role
  Future<List<Map<String, dynamic>>> getUsersByRole(String role) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: role)
          .get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting users by role: $e');
      return [];
    }
  }

  // Get current user profile
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      return await getUserProfile(currentUser.uid);
    }
    return null;
  }

  // Update current user profile
  Future<void> updateCurrentUserProfile(Map<String, dynamic> data) async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      await updateUserProfile(currentUser.uid, data);
    }
  }
}
