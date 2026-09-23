import 'dart:io' show Platform;

import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/error/failure.dart';

/// The Web OAuth client id from Google Cloud Console — required so the ID
/// token's `aud` matches what the backend verifies against. Replace before
/// shipping.
const _googleServerClientId = '356776833372-f0i2k25gei41r908bgjor210rcj98gng.apps.googleusercontent.com';

/// The iOS OAuth client id (same value as `GIDClientID` in Info.plist).
///
/// On iOS, `google_sign_in`'s plugin only honors [_googleServerClientId] if
/// this is *also* passed to `initialize()` — otherwise it silently falls
/// back to a default configuration with no server client id at all, and the
/// ID token comes back audienced to the iOS client instead, which the
/// backend then rejects. Android ignores this value entirely.
const _googleIosClientId = '356776833372-u840lh1lrdqd8qj916f2dt0oqolvskfv.apps.googleusercontent.com';

class GoogleSignInCancelled implements Exception {
  const GoogleSignInCancelled();
}

abstract class GoogleSignInDataSource {
  /// Runs the native Google sign-in flow and returns the ID token to send to
  /// the backend. Throws [GoogleSignInCancelled] if the person dismisses the
  /// picker, or [Failure] on any other error.
  Future<String> signIn();
}

class GoogleSignInDataSourceImpl implements GoogleSignInDataSource {
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await GoogleSignIn.instance.initialize(
      clientId: Platform.isIOS ? _googleIosClientId : null,
      serverClientId: _googleServerClientId,
    );
    _initialized = true;
  }

  @override
  Future<String> signIn() async {
    await _ensureInitialized();
    try {
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw Failure(error: 'Google sign-in did not return an ID token.');
      }
      return idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const GoogleSignInCancelled();
      }
      throw Failure(error: e.description ?? e.code.toString());
    }
  }
}
