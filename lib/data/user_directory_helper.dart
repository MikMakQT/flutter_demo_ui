import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserDirectoryHelper {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> ensureCurrentUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    try {
      await _db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email?.trim().toLowerCase(),
        'displayName': user.displayName,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      debugPrint(
        'Failed to sync user profile (${e.code}): ${e.message ?? 'No message'}',
      );
    } catch (e) {
      debugPrint('Failed to sync user profile: $e');
    }
  }

  static Future<String?> resolveUserUid(String value) async {
    final lookupValue = value.trim();
    if (lookupValue.isEmpty) {
      return null;
    }

    if (!lookupValue.contains('@')) {
      final directDoc = await _db.collection('users').doc(lookupValue).get();
      if (directDoc.exists) {
        return directDoc.id;
      }
      return null;
    }

    final emailQuery = await _db
        .collection('users')
        .where('email', isEqualTo: lookupValue.toLowerCase())
        .limit(1)
        .get();

    if (emailQuery.docs.isEmpty) {
      return null;
    }

    return emailQuery.docs.first.id;
  }
}
