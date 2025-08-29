import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload profile image to Firebase Storage
  Future<String?> uploadProfileImage(File imageFile, String userId) async {
    try {
      debugPrint('Starting upload for user: $userId');

      // Create a reference to the file location
      final storageRef = _storage.ref().child('profile_images/$userId.jpg');

      // Upload the file with metadata
      final uploadTask = storageRef.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Wait for the upload to complete
      final snapshot = await uploadTask;

      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('Successfully uploaded image for user $userId: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
      return null;
    }
  }

  // Upload image from XFile (for web compatibility)
  Future<String?> uploadImageFromXFile(XFile imageFile, String userId) async {
    try {
      debugPrint('Starting XFile upload for user: $userId');
      debugPrint('Image file path: ${imageFile.path}');
      debugPrint('Image file name: ${imageFile.name}');

      if (kIsWeb) {
        // For web, we need to handle it differently
        debugPrint('Web platform detected - using putData method');
        final storageRef = _storage.ref().child('profile_images/$userId.jpg');

        debugPrint('Reading image bytes...');
        // Convert XFile to Uint8List for web
        final bytes = await imageFile.readAsBytes();
        debugPrint(
          'Image bytes read successfully. Size: ${bytes.length} bytes',
        );

        debugPrint('Starting Firebase Storage upload...');
        final uploadTask = storageRef.putData(
          bytes,
          SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {
              'userId': userId,
              'uploadedAt': DateTime.now().toIso8601String(),
              'platform': 'web',
            },
          ),
        );

        debugPrint('Waiting for upload to complete...');

        // Listen to upload progress
        uploadTask.snapshotEvents.listen((snapshot) {
          double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          debugPrint(
            'Upload progress: ${(progress * 100).toStringAsFixed(2)}%',
          );
          debugPrint('State: ${snapshot.state}');
        });

        // Add timeout and better error handling
        final snapshot = await uploadTask.timeout(
          const Duration(minutes: 2),
          onTimeout: () {
            throw Exception('Upload timeout after 2 minutes');
          },
        );

        debugPrint(
          'Upload completed. Bytes transferred: ${snapshot.bytesTransferred}',
        );
        debugPrint('Upload state: ${snapshot.state}');

        debugPrint('Getting download URL...');
        final downloadUrl = await snapshot.ref.getDownloadURL();

        debugPrint(
          'Successfully uploaded image for user $userId (web): $downloadUrl',
        );
        return downloadUrl;
      } else {
        // For mobile platforms
        debugPrint('Converting XFile to File for mobile platform...');
        final file = File(imageFile.path);
        return await uploadProfileImage(file, userId);
      }
    } catch (e) {
      debugPrint('Error uploading image from XFile: $e');
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Full error details: ${e.toString()}');

      if (e.toString().contains('_Namespace')) {
        debugPrint(
          'Platform namespace error detected - this is a known web issue',
        );
      } else if (e.toString().contains('permission')) {
        debugPrint('Permission error detected - check Firebase Storage rules');
      } else if (e.toString().contains('network')) {
        debugPrint('Network error detected - check internet connection');
      } else if (e.toString().contains('timeout')) {
        debugPrint('Timeout error detected - upload took too long');
      }

      return null;
    }
  }

  // Delete profile image
  Future<void> deleteProfileImage(String userId) async {
    try {
      final storageRef = _storage.ref().child('profile_images/$userId.jpg');
      await storageRef.delete();
      debugPrint('Successfully deleted image for user $userId');
    } catch (e) {
      debugPrint('Error deleting profile image: $e');
    }
  }

  // Get profile image URL
  Future<String?> getProfileImageUrl(String userId) async {
    try {
      final storageRef = _storage.ref().child('profile_images/$userId.jpg');
      return await storageRef.getDownloadURL();
    } catch (e) {
      debugPrint('Error getting profile image URL: $e');
      return null;
    }
  }

  // Check if profile image exists
  Future<bool> profileImageExists(String userId) async {
    try {
      final storageRef = _storage.ref().child('profile_images/$userId.jpg');
      await storageRef.getMetadata();
      return true;
    } catch (e) {
      return false;
    }
  }
}
