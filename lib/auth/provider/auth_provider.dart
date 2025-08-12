import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'user_service.dart';
import 'storage_service.dart';

class FirebaseAuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'https://www.googleapis.com/auth/userinfo.profile',
      'https://www.googleapis.com/auth/userinfo.email',
    ],
    clientId: kIsWeb
        ? '1042853929889-33qo9f34dgraulecq5k591npl2pejt1m.apps.googleusercontent.com'
        : null,
  );
  final UserService _userService = UserService();
  final StorageService _storageService = StorageService();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

  FirebaseAuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _currentUser = user;
      _isAuthenticated = user != null;
      notifyListeners();
      _saveUserSession(user);
    });
    _loadUserSession();
  }

  // Save user session to SharedPreferences
  Future<void> _saveUserSession(User? user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (user != null) {
        await prefs.setString('user_uid', user.uid);
        await prefs.setString('user_email', user.email ?? '');
        await prefs.setBool('is_authenticated', true);
        await prefs.setInt(
          'login_timestamp',
          DateTime.now().millisecondsSinceEpoch,
        );
      } else {
        await prefs.remove('user_uid');
        await prefs.remove('user_email');
        await prefs.setBool('is_authenticated', false);
        await prefs.remove('login_timestamp');
      }
    } catch (e) {
      debugPrint('Error saving user session: $e');
    }
  }

  // Load user session from SharedPreferences
  Future<void> _loadUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isAuthenticated = prefs.getBool('is_authenticated') ?? false;
      final loginTimestamp = prefs.getInt('login_timestamp') ?? 0;

      // Check if session is still valid (24 hours)
      final now = DateTime.now().millisecondsSinceEpoch;
      final sessionValid = (now - loginTimestamp) < (24 * 60 * 60 * 1000);

      if (isAuthenticated && sessionValid) {
        _isAuthenticated = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user session: $e');
    }
  }

  // Sign up with email and password
  Future<User?> signUpWithEmailAndPassword(
    String email,
    String password,
    String role,
    String name, {
    String? profilePhotoUrl,
    File? profileImage,
    XFile? profileImageXFile,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      debugPrint('Starting signup process for email: $email');

      // Add timeout to prevent hanging
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Signup timeout - please try again');
            },
          );

      debugPrint('Firebase auth successful, creating user profile...');

      if (userCredential.user != null) {
        String? finalProfilePhotoUrl = profilePhotoUrl;

        // Create user profile first, then handle image upload separately
        await _userService.createUserProfile(
          uid: userCredential.user!.uid,
          email: email,
          role: role,
          name: name.isNotEmpty ? name : 'User',
          profilePhoto: finalProfilePhotoUrl ?? '',
          isGuest: false,
        );

        debugPrint('User profile created successfully in Firestore');

        // Handle image upload (blocking during signup for immediate feedback)
        if (profileImage != null || profileImageXFile != null) {
          await _handleImageUpload(
            userCredential.user!.uid,
            profileImage,
            profileImageXFile,
          );
        }
      }

      debugPrint('Signup process completed successfully');
      return userCredential.user;
    } catch (e) {
      debugPrint('Error during signup: $e');
      _errorMessage = _getErrorMessage(e.toString());
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Handle image upload separately (non-blocking)
  Future<void> _handleImageUpload(
    String userId,
    File? profileImage,
    XFile? profileImageXFile,
  ) async {
    try {
      debugPrint('Starting image upload for user: $userId');

      String? uploadedUrl;

      if (kIsWeb && profileImageXFile != null) {
        // For web, use XFile
        uploadedUrl = await _storageService.uploadImageFromXFile(
          profileImageXFile,
          userId,
        );
      } else if (profileImage != null) {
        // For mobile, use File
        uploadedUrl = await _storageService.uploadProfileImage(
          profileImage,
          userId,
        );
      }

      if (uploadedUrl != null) {
        debugPrint('✅ Image upload completed successfully!');
        debugPrint('📸 Image URL: $uploadedUrl');

        // Update user profile with the new image URL
        await _userService.updateUserProfile(userId, {
          'profilePhoto': uploadedUrl,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        debugPrint('✅ User profile updated with new image URL in Firestore');
        debugPrint('🔄 Profile photo should now be visible in database');
      } else {
        debugPrint('❌ Image upload failed or returned null URL');
        debugPrint('🚨 Profile photo will remain empty in database');
      }
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
      // Don't fail the signup process if image upload fails
    }
  }

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Update last login
        await _userService.updateLastLogin(userCredential.user!.uid);
      }

      return userCredential.user;
    } catch (e) {
      _errorMessage = _getErrorMessage(e.toString());
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Google Sign In
  Future<User?> signInWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      debugPrint('Starting Google Sign-In process...');

      // Sign out from Google first to ensure fresh sign-in
      try {
        await _googleSignIn.signOut();
        debugPrint('Signed out from Google successfully');
      } catch (e) {
        debugPrint('Error signing out from Google: $e');
        // Continue anyway
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('Google Sign-In was cancelled by user');
        _isLoading = false;
        notifyListeners();
        return null;
      }

      debugPrint('Google Sign-In successful for: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      debugPrint('Creating Firebase credential...');

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      debugPrint('Firebase authentication successful');

      if (userCredential.user != null) {
        // Check if user profile exists, if not create one
        bool profileExists = await _userService.userProfileExists(
          userCredential.user!.uid,
        );

        if (!profileExists) {
          debugPrint('Creating new user profile for Google user');
          await _userService.createUserProfile(
            uid: userCredential.user!.uid,
            email: userCredential.user!.email ?? '',
            role: 'Legal Assistant', // Default role
            name:
                userCredential.user!.displayName ??
                googleUser.displayName ??
                'User',
            profilePhoto:
                userCredential.user!.photoURL ?? googleUser.photoUrl ?? '',
            isGuest: false,
          );
        } else {
          debugPrint('Updating last login for existing user');
          // Update last login
          await _userService.updateLastLogin(userCredential.user!.uid);
        }
      }

      debugPrint('Google Sign-In completed successfully');
      return userCredential.user;
    } catch (e) {
      debugPrint('Error in Google Sign-In: $e');
      _errorMessage = _getErrorMessage(e.toString());
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Guest access
  Future<User?> signInAsGuest() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      UserCredential userCredential = await _auth.signInAnonymously();

      if (userCredential.user != null) {
        // Create guest user profile
        await _userService.createUserProfile(
          uid: userCredential.user!.uid,
          email: '',
          role: 'Guest',
          name: 'Guest User',
          profilePhoto: '',
          isGuest: true,
        );
      }

      return userCredential.user;
    } catch (e) {
      _errorMessage = _getErrorMessage(e.toString());
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      await _saveUserSession(null);
    } catch (e) {
      _errorMessage = _getErrorMessage(e.toString());
      notifyListeners();
    }
  }

  // Upload profile image
  Future<String?> uploadProfileImage(File imageFile) async {
    if (_currentUser == null) return null;
    return await _storageService.uploadProfileImage(
      imageFile,
      _currentUser!.uid,
    );
  }

  // Upload profile image from XFile (for web)
  Future<String?> uploadProfileImageFromXFile(XFile imageFile) async {
    if (_currentUser == null) return null;
    return await _storageService.uploadImageFromXFile(
      imageFile,
      _currentUser!.uid,
    );
  }

  // Update current user's profile photo
  Future<bool> updateCurrentUserProfilePhoto(
    XFile? imageFile,
    File? imageFileMobile,
  ) async {
    if (_currentUser == null) return false;

    try {
      String? uploadedUrl;

      if (kIsWeb && imageFile != null) {
        uploadedUrl = await _storageService.uploadImageFromXFile(
          imageFile,
          _currentUser!.uid,
        );
      } else if (imageFileMobile != null) {
        uploadedUrl = await _storageService.uploadProfileImage(
          imageFileMobile,
          _currentUser!.uid,
        );
      }

      if (uploadedUrl != null) {
        await _userService.updateUserProfile(_currentUser!.uid, {
          'profilePhoto': uploadedUrl,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        debugPrint('Profile photo updated successfully: $uploadedUrl');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating profile photo: $e');
      return false;
    }
  }

  // Get user profile from Firestore
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    return await _userService.getUserProfile(uid);
  }

  // Update user profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _userService.updateUserProfile(uid, data);
  }

  // Get current user profile
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    return await _userService.getCurrentUserProfile();
  }

  // Update current user profile
  Future<void> updateCurrentUserProfile(Map<String, dynamic> data) async {
    await _userService.updateCurrentUserProfile(data);
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Get user-friendly error message
  String _getErrorMessage(String error) {
    debugPrint('Processing error: $error');

    if (error.contains('weak-password')) {
      return 'The password provided is too weak. Please use at least 6 characters.';
    } else if (error.contains('email-already-in-use')) {
      return 'An account already exists for that email. Please sign in instead.';
    } else if (error.contains('user-not-found')) {
      return 'No account found for that email. Please create an account first.';
    } else if (error.contains('wrong-password')) {
      return 'Wrong password provided. Please check your password.';
    } else if (error.contains('invalid-email')) {
      return 'Invalid email address. Please enter a valid email.';
    } else if (error.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection.';
    } else if (error.contains('popup-closed-by-user')) {
      return 'Google sign-in was cancelled.';
    } else if (error.contains('popup-blocked')) {
      return 'Google sign-in popup was blocked. Please allow popups and try again.';
    } else if (error.contains('account-exists-with-different-credential')) {
      return 'An account already exists with the same email address but different sign-in credentials.';
    } else if (error.contains('requires-recent-login')) {
      return 'This operation requires recent authentication. Please sign in again.';
    } else if (error.contains('sign_in_failed')) {
      return 'Google sign-in failed. Please try again.';
    } else if (error.contains('network_error')) {
      return 'Network error. Please check your internet connection and try again.';
    } else if (error.contains('_Namespace')) {
      return 'Platform error. Please restart the app and try again.';
    } else if (error.contains('appClientId != null')) {
      return 'Google Sign-In configuration error. Please check your Firebase setup.';
    } else if (error.contains('people.googleapis.com') ||
        error.contains('SERVICE_DISABLED')) {
      return 'Google People API is not enabled. Please contact the administrator to enable it.';
    } else if (error.contains('PERMISSION_DENIED')) {
      return 'Google API permission denied. Please check your Google Cloud Console settings.';
    } else {
      return 'An error occurred. Please try again. Error: $error';
    }
  }
}
