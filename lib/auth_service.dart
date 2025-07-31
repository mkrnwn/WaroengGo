// lib/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> registerWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // TAMBAHKAN PRINT INI
      print(
        "AuthService DEBUG: User registered: ${result.user?.email}, UID: ${result.user?.uid}",
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'weak-password') {
        errorMessage = 'Password terlalu lemah.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Email sudah terdaftar.';
      } else {
        errorMessage = 'Gagal mendaftar: ${e.message}';
      }
      // TAMBAHKAN PRINT INI
      print('AuthService DEBUG: Error during registration: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      // TAMBAHKAN PRINT INI
      print('AuthService DEBUG: Unexpected error during registration: $e');
      throw Exception('Terjadi kesalahan tidak dikenal saat mendaftar.');
    }
  }

  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // TAMBAHKAN PRINT INI
      print(
        "AuthService DEBUG: User signed in: ${result.user?.email}, UID: ${result.user?.uid}",
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = 'Pengguna tidak ditemukan untuk email ini.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Password salah.';
      } else {
        errorMessage = 'Gagal login: ${e.message}';
      }
      // TAMBAHKAN PRINT INI
      print('AuthService DEBUG: Error during sign in: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      // TAMBAHKAN PRINT INI
      print('AuthService DEBUG: Unexpected error during sign in: $e');
      throw Exception('Terjadi kesalahan tidak dikenal saat login.');
    }
  }

  Future<void> signOut() async {
    // TAMBAHKAN PRINT INI
    print("AuthService DEBUG: Attempting sign out...");
    await _auth.signOut();
    // TAMBAHKAN PRINT INI
    print("AuthService DEBUG: User signed out.");
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
