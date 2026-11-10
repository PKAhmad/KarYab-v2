import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AuthService - Phase 6 accounts (Google + email), guest mode preserved.
//
// Layers:
//  - [AuthBackend] is the raw provider interface. It throws
//    [AuthBackendException] carrying the provider's string code, and it is
//    the seam tests fake. [FirebaseAuthBackend] is the real one.
//  - [AuthService] maps backend codes to [AuthErrorKind] and throws
//    [AuthException]; UI code only ever sees kinds and turns them into
//    user messages with [authErrorMessage] (4 languages, same _msg pattern
//    as the job search errors).
//
// Guest mode is sacred: nothing in the app requires an account. This
// service is only touched from the login / account screens.
//
// Google Sign-In activation note: with the current development
// google-services.json (registered to com.example.karyab, no SHA
// fingerprints in the console) a Google sign-in attempt fails in the
// platform layer. That failure is mapped to
// [AuthErrorKind.googleNotConfigured] so the UI can say "not available
// yet" instead of crashing. Activation is config-only (see the Phase 6
// report checklist); no code change will be needed.
// ─────────────────────────────────────────────────────────────────────────────

/// A signed-in KarYab user, provider-neutral.
class KaryabUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  /// Provider ids, e.g. 'google.com', 'password'.
  final List<String> providers;

  const KaryabUser({
    required this.uid,
    required this.providers,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  bool get isGoogleUser => providers.contains('google.com');
  bool get isEmailUser => providers.contains('password');

  /// Initials for the avatar fallback (first letters of the first two
  /// name words, or of the email local part).
  String get initials {
    final source = (displayName != null && displayName!.trim().isNotEmpty)
        ? displayName!.trim()
        : (email ?? '').split('@').first;
    final words = source.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    if (words.isEmpty) return '?';
    if (words.length == 1) return words.first[0].toUpperCase();
    return (words.first[0] + words.elementAt(1)[0]).toUpperCase();
  }
}

/// Raw provider failure, carrying the provider's string code
/// (FirebaseAuthException.code, a PlatformException code, or one of the
/// synthetic codes 'google-cancelled' / 'google-not-configured').
class AuthBackendException implements Exception {
  final String code;
  const AuthBackendException(this.code);

  @override
  String toString() => 'AuthBackendException($code)';
}

/// The provider interface [AuthService] wraps. Tests implement this.
abstract interface class AuthBackend {
  Stream<KaryabUser?> get authStateChanges;
  KaryabUser? get currentUser;

  /// Throws AuthBackendException('google-cancelled') when the user
  /// dismisses the Google account picker.
  Future<KaryabUser> signInWithGoogle();
  Future<KaryabUser> signUpWithEmail(String email, String password);
  Future<KaryabUser> signInWithEmail(String email, String password);
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();

  /// Deletes the account. For email users, [password] is used to
  /// re-authenticate when Firebase demands a recent login; without it
  /// the backend throws AuthBackendException('requires-recent-login').
  Future<void> deleteAccount({String? password});
}

enum AuthErrorKind {
  invalidEmail,
  weakPassword,
  emailAlreadyInUse,
  wrongCredentials,
  userDisabled,
  network,
  tooManyRequests,
  googleCancelled,
  googleNotConfigured,
  requiresRecentLogin,
  unknown,
}

/// The only exception type UI code catches from [AuthService].
class AuthException implements Exception {
  final AuthErrorKind kind;
  const AuthException(this.kind);

  @override
  String toString() => 'AuthException($kind)';
}

/// Maps a raw backend/provider code to an [AuthErrorKind].
AuthErrorKind mapAuthErrorCode(String code) {
  switch (code) {
    case 'invalid-email':
      return AuthErrorKind.invalidEmail;
    case 'weak-password':
      return AuthErrorKind.weakPassword;
    case 'email-already-in-use':
      return AuthErrorKind.emailAlreadyInUse;
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return AuthErrorKind.wrongCredentials;
    case 'user-disabled':
      return AuthErrorKind.userDisabled;
    case 'network-request-failed':
      return AuthErrorKind.network;
    case 'too-many-requests':
      return AuthErrorKind.tooManyRequests;
    case 'google-cancelled':
      return AuthErrorKind.googleCancelled;
    case 'google-not-configured':
    case 'sign_in_failed':
      return AuthErrorKind.googleNotConfigured;
    case 'requires-recent-login':
      return AuthErrorKind.requiresRecentLogin;
    default:
      return AuthErrorKind.unknown;
  }
}

/// User-facing message for an auth failure, in the app's 4 languages
/// (same pattern as the job search error messages). German falls back
/// like the rest of the app: explicit 'de', 'ps', 'fa', default English
/// is NOT used here - German users get the German text.
String authErrorMessage(AuthErrorKind kind, String lang) {
  String msg({
    required String en,
    required String de,
    required String ps,
    required String fa,
    required String ar,
  }) {
    switch (lang) {
      case 'de':
        return de;
      case 'ps':
        return ps;
      case 'fa':
        return fa;
      case 'ar':
        return ar;
      default:
        return en;
    }
  }

  switch (kind) {
    case AuthErrorKind.invalidEmail:
      return msg(
        en: 'This email address is not valid. Please check it and try again.',
        de: 'Diese E-Mail-Adresse ist nicht gültig. Bitte prüfe sie und versuche es erneut.',
        ps: 'دا برېښنالیک سم نه دی. مهرباني وکړئ وګورئ او بیا هڅه وکړئ.',
        fa: 'این ایمیل درست نیست. لطفا بررسی کنید و دوباره تلاش کنید.',
        ar: 'هذا البريد الإلكتروني غير صحيح. من فضلك راجعه وحاول مرة أخرى.',
      );
    case AuthErrorKind.weakPassword:
      return msg(
        en: 'The password is too weak. Please use at least 6 characters.',
        de: 'Das Passwort ist zu schwach. Bitte verwende mindestens 6 Zeichen.',
        ps: 'پټنوم ډېر کمزوری دی. لږ تر لږه 6 توري وکاروئ.',
        fa: 'رمز عبور خیلی ضعیف است. حداقل 6 حرف استفاده کنید.',
        ar: 'كلمة المرور ضعيفة جدا. من فضلك استخدم 6 أحرف على الأقل.',
      );
    case AuthErrorKind.emailAlreadyInUse:
      return msg(
        en: 'An account with this email already exists. Please sign in instead.',
        de: 'Mit dieser E-Mail gibt es schon ein Konto. Bitte melde dich stattdessen an.',
        ps: 'دې برېښنالیک سره حساب پخوا جوړ شوی دی. مهرباني وکړئ ننوځئ.',
        fa: 'با این ایمیل قبلا حساب ساخته شده است. لطفا وارد شوید.',
        ar: 'يوجد حساب بهذا البريد الإلكتروني من قبل. من فضلك سجل الدخول.',
      );
    case AuthErrorKind.wrongCredentials:
      return msg(
        en: 'Email or password is not correct.',
        de: 'E-Mail oder Passwort ist nicht richtig.',
        ps: 'برېښنالیک یا پټنوم سم نه دی.',
        fa: 'ایمیل یا رمز عبور درست نیست.',
        ar: 'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
      );
    case AuthErrorKind.userDisabled:
      return msg(
        en: 'This account has been disabled.',
        de: 'Dieses Konto wurde deaktiviert.',
        ps: 'دا حساب بند شوی دی.',
        fa: 'این حساب غیرفعال شده است.',
        ar: 'تم تعطيل هذا الحساب.',
      );
    case AuthErrorKind.network:
      return msg(
        en: 'No internet connection. Please check your connection and try again.',
        de: 'Keine Internetverbindung. Bitte prüfe deine Verbindung und versuche es erneut.',
        ps: 'انټرنیټ نشته. خپل اتصال وګورئ او بیا هڅه وکړئ.',
        fa: 'اتصال اینترنت وجود ندارد. اتصال خود را بررسی کنید و دوباره تلاش کنید.',
        ar: 'لا يوجد اتصال بالإنترنت. من فضلك راجع اتصالك وحاول مرة أخرى.',
      );
    case AuthErrorKind.tooManyRequests:
      return msg(
        en: 'Too many attempts. Please wait a little and try again.',
        de: 'Zu viele Versuche. Bitte warte etwas und versuche es erneut.',
        ps: 'ډېرې هڅې وشوې. لږ وخت وروسته بیا هڅه وکړئ.',
        fa: 'تلاش‌های زیادی انجام شد. کمی صبر کنید و دوباره تلاش کنید.',
        ar: 'تمت محاولات كثيرة. من فضلك انتظر قليلا وحاول مرة أخرى.',
      );
    case AuthErrorKind.googleCancelled:
      return msg(
        en: 'Google sign-in was cancelled.',
        de: 'Die Google-Anmeldung wurde abgebrochen.',
        ps: 'د Google ننوتل لغوه شو.',
        fa: 'ورود با Google لغو شد.',
        ar: 'تم إلغاء تسجيل الدخول بواسطة Google.',
      );
    case AuthErrorKind.googleNotConfigured:
      return msg(
        en: 'Google sign-in is not available yet. Please use email or continue without an account.',
        de: 'Google-Anmeldung ist noch nicht verfügbar. Bitte nutze E-Mail oder fahre ohne Konto fort.',
        ps: 'د Google ننوتل لا شتون نه لري. مهرباني وکړئ برېښنالیک وکاروئ یا بې حسابه دوام ورکړئ.',
        fa: 'ورود با Google هنوز در دسترس نیست. لطفا از ایمیل استفاده کنید یا بدون حساب ادامه دهید.',
        ar: 'تسجيل الدخول بواسطة Google غير متاح بعد. من فضلك استخدم البريد الإلكتروني أو تابع بدون حساب.',
      );
    case AuthErrorKind.requiresRecentLogin:
      return msg(
        en: 'For safety, please sign out, sign in again, and then try again.',
        de: 'Zur Sicherheit: Bitte melde dich ab, wieder an und versuche es dann erneut.',
        ps: 'د خوندیتوب لپاره، لومړی ووځئ او بیا ننوځئ، بیا هڅه وکړئ.',
        fa: 'برای امنیت، اول خارج شوید و دوباره وارد شوید، بعد تلاش کنید.',
        ar: 'من أجل الأمان، من فضلك سجل الخروج ثم سجل الدخول مرة أخرى، ثم حاول مرة أخرى.',
      );
    case AuthErrorKind.unknown:
      return msg(
        en: 'Something went wrong. Please try again.',
        de: 'Etwas ist schiefgegangen. Bitte versuche es erneut.',
        ps: 'یو څه سم نه شو. بیا هڅه وکړئ.',
        fa: 'مشکلی پیش آمد. دوباره تلاش کنید.',
        ar: 'حدث خطأ ما. من فضلك حاول مرة أخرى.',
      );
  }
}

/// App-facing auth API. Wraps an [AuthBackend] and only throws
/// [AuthException]. The app-wide instance is [karyabAuth].
class AuthService {
  AuthService(this._backend);

  final AuthBackend _backend;

  Stream<KaryabUser?> get authStateChanges => _backend.authStateChanges;
  KaryabUser? get currentUser => _backend.currentUser;
  bool get isSignedIn => _backend.currentUser != null;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AuthBackendException catch (e) {
      throw AuthException(mapAuthErrorCode(e.code));
    } on FirebaseAuthException catch (e) {
      throw AuthException(mapAuthErrorCode(e.code));
    } on PlatformException catch (e) {
      throw AuthException(mapAuthErrorCode(e.code));
    } catch (_) {
      throw const AuthException(AuthErrorKind.unknown);
    }
  }

  Future<KaryabUser> signInWithGoogle() =>
      _guard(() => _backend.signInWithGoogle());

  Future<KaryabUser> signUpWithEmail(String email, String password) =>
      _guard(() => _backend.signUpWithEmail(email.trim(), password));

  Future<KaryabUser> signInWithEmail(String email, String password) =>
      _guard(() => _backend.signInWithEmail(email.trim(), password));

  Future<void> sendPasswordReset(String email) =>
      _guard(() => _backend.sendPasswordResetEmail(email.trim()));

  Future<void> signOut() => _guard(() => _backend.signOut());

  Future<void> deleteAccount({String? password}) =>
      _guard(() => _backend.deleteAccount(password: password));
}

/// The real backend: Firebase Auth + Google Sign-In.
class FirebaseAuthBackend implements AuthBackend {
  FirebaseAuthBackend({FirebaseAuth? auth, GoogleSignIn? google})
      : _auth = auth ?? FirebaseAuth.instance,
        _google = google ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final GoogleSignIn _google;

  KaryabUser _mapUser(User user) => KaryabUser(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoURL,
        providers:
            user.providerData.map((p) => p.providerId).toList(growable: false),
      );

  @override
  Stream<KaryabUser?> get authStateChanges =>
      _auth.authStateChanges().map((u) => u == null ? null : _mapUser(u));

  @override
  KaryabUser? get currentUser {
    final user = _auth.currentUser;
    return user == null ? null : _mapUser(user);
  }

  Future<T> _firebase<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseAuthException catch (e) {
      throw AuthBackendException(e.code);
    } on PlatformException catch (e) {
      // google_sign_in reports a missing console configuration (no SHA
      // fingerprint / wrong package) as sign_in_failed with an
      // ApiException: 10 (DEVELOPER_ERROR) in the message.
      final text = '${e.code} ${e.message ?? ''} ${e.details ?? ''}';
      if (e.code == 'sign_in_failed' ||
          text.contains('ApiException: 10') ||
          text.contains('DEVELOPER_ERROR')) {
        throw const AuthBackendException('google-not-configured');
      }
      throw AuthBackendException(e.code);
    }
  }

  @override
  Future<KaryabUser> signInWithGoogle() async {
    final googleUser = await _firebase(() => _google.signIn());
    if (googleUser == null) {
      throw const AuthBackendException('google-cancelled');
    }
    final googleAuth = await _firebase(() => googleUser.authentication);
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final result =
        await _firebase(() => _auth.signInWithCredential(credential));
    return _mapUser(result.user!);
  }

  @override
  Future<KaryabUser> signUpWithEmail(String email, String password) async {
    final result = await _firebase(
      () => _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ),
    );
    // Best effort: ask Firebase to send the verification email. A
    // failure here must not fail the sign-up itself.
    try {
      await result.user?.sendEmailVerification();
    } catch (_) {}
    return _mapUser(result.user!);
  }

  @override
  Future<KaryabUser> signInWithEmail(String email, String password) async {
    final result = await _firebase(
      () => _auth.signInWithEmailAndPassword(email: email, password: password),
    );
    return _mapUser(result.user!);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _firebase(() => _auth.sendPasswordResetEmail(email: email));

  @override
  Future<void> signOut() async {
    await _firebase(() => _google.signOut());
    await _firebase(() => _auth.signOut());
  }

  @override
  Future<void> deleteAccount({String? password}) async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthBackendException('no-current-user');
    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code != 'requires-recent-login') {
        throw AuthBackendException(e.code);
      }
      // Re-authenticate, then retry once.
      final providers = user.providerData.map((p) => p.providerId).toList();
      if (providers.contains('password') && password != null) {
        final email = user.email;
        if (email == null) throw AuthBackendException(e.code);
        await _firebase(
          () => user.reauthenticateWithCredential(
            EmailAuthProvider.credential(email: email, password: password),
          ),
        );
      } else if (providers.contains('google.com')) {
        final googleUser = await _firebase(() => _google.signIn());
        if (googleUser == null) {
          throw const AuthBackendException('google-cancelled');
        }
        final googleAuth = await _firebase(() => googleUser.authentication);
        await _firebase(
          () => user.reauthenticateWithCredential(
            GoogleAuthProvider.credential(
              accessToken: googleAuth.accessToken,
              idToken: googleAuth.idToken,
            ),
          ),
        );
      } else {
        throw AuthBackendException(e.code);
      }
      await _firebase(() => user.delete());
    }
  }
}

// ── App-wide accessor (same shape as KaryabData) ──────────────────────────

AuthService? _karyabAuthInstance;

/// The app-wide [AuthService]. Lazily builds the Firebase backend, so
/// importing this file never touches Firebase by itself.
AuthService get karyabAuth =>
    _karyabAuthInstance ??= AuthService(FirebaseAuthBackend());

/// Test seam: replace the app-wide auth service (e.g. with a fake
/// backend) or restore the real one with `debugSetKaryabAuth(null)`.
void debugSetKaryabAuth(AuthService? service) {
  _karyabAuthInstance = service;
}
