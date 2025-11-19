import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class UserProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  // Initialize user from Firebase Auth
  Future<void> initializeUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        try {
          _user = await _firestoreService.getUser(currentUser.uid);
        } catch (e) {
          debugPrint('Error getting user from Firestore: $e');
          // If Firestore fails, create a basic user object
          _user = null;
        }
        
        if (_user == null) {
          // User document doesn't exist, create it
          _user = UserModel(
            uid: currentUser.uid,
            email: currentUser.email ?? '',
            firstName: '',
            lastName: '',
            role: 'user',
            registrationDate: DateTime.now(),
          );
          try {
            await _firestoreService.createOrUpdateUser(_user!);
            debugPrint('User document created in Firestore');
          } catch (e) {
            debugPrint('Error creating user in Firestore: $e');
            // Even if Firestore fails, keep the user object so they can use the app
            // The user will be created in Firestore on next successful operation
          }
        } else {
          debugPrint('User loaded from Firestore: ${_user!.email}');
        }
      } else {
        _user = null;
        debugPrint('No current user in Firebase Auth');
      }
    } catch (e) {
      debugPrint('Error initializing user: $e');
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('initializeUser completed - user: ${_user?.email ?? "null"}, isLoading: $_isLoading');
    }
  }

  // Register new user
  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String role = 'user',
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userCredential = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential?.user != null) {
        _user = UserModel(
          uid: userCredential!.user!.uid,
          email: email,
          firstName: firstName,
          lastName: lastName,
          role: role,
          registrationDate: DateTime.now(),
        );

        await _firestoreService.createOrUpdateUser(_user!);
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign in
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('Firebase Auth sign in successful');
      
      // After successful sign in, initialize user from Firestore
      await initializeUser();
      debugPrint('After initializeUser - user: ${_user?.email ?? "null"}');
      
      // Ensure user is set after initialization
      if (_user == null && _authService.currentUser != null) {
        debugPrint('User is null after initialization, creating user object');
        // If user document doesn't exist, create it
        _user = UserModel(
          uid: _authService.currentUser!.uid,
          email: _authService.currentUser!.email ?? email,
          firstName: '',
          lastName: '',
          role: 'user',
          registrationDate: DateTime.now(),
        );
        await _firestoreService.createOrUpdateUser(_user!);
        debugPrint('User object created and saved to Firestore');
      }
      
      // Final check - ensure user is set
      if (_user != null) {
        debugPrint('Sign in completed successfully - user: ${_user!.email}');
      } else {
        debugPrint('WARNING: User is still null after sign in!');
      }
    } catch (e) {
      debugPrint('Sign in error: $e');
      _user = null;
      rethrow;
    } finally {
      _isLoading = false;
      debugPrint('Sign in finally - isLoading: $_isLoading, user: ${_user?.email ?? "null"}');
      notifyListeners();
      debugPrint('notifyListeners() called after sign in');
    }
  }

  // Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _user = null;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile
  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? role,
    DateTime? dateOfBirth,
  }) async {
    if (_user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      Map<String, dynamic> updates = {};
      if (firstName != null) updates['firstName'] = firstName;
      if (lastName != null) updates['lastName'] = lastName;
      if (role != null) updates['role'] = role;
      if (dateOfBirth != null) {
        updates['dateOfBirth'] = dateOfBirth.millisecondsSinceEpoch;
      }

      await _firestoreService.updateUserProfile(_user!.uid, updates);

      // Update local user model
      _user = UserModel(
        uid: _user!.uid,
        email: _user!.email,
        firstName: firstName ?? _user!.firstName,
        lastName: lastName ?? _user!.lastName,
        role: role ?? _user!.role,
        registrationDate: _user!.registrationDate,
        dateOfBirth: dateOfBirth ?? _user!.dateOfBirth,
      );
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update email
  Future<void> updateEmail(String newEmail) async {
    if (_user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _authService.updateEmail(newEmail);
      await _firestoreService.updateUserProfile(_user!.uid, {'email': newEmail});
      _user = UserModel(
        uid: _user!.uid,
        email: newEmail,
        firstName: _user!.firstName,
        lastName: _user!.lastName,
        role: _user!.role,
        registrationDate: _user!.registrationDate,
      );
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.updatePassword(newPassword);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
