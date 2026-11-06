import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:karyab/data/repositories.dart';
import 'package:karyab/providers/language_provider.dart';
import 'package:karyab/screens/account_screen.dart';
import 'package:karyab/screens/login_screen.dart';
import 'package:karyab/services/account_strings.dart';
import 'package:karyab/services/auth_service.dart';
import 'package:karyab/services/backup_service.dart';

// Phase 6 (accounts): AuthService over a fake backend, cloud backup
// snapshot + restore decision logic, and the account/login screens in
// signed-in and signed-out states. The signed-out widget tests double
// as the guest-mode regression: the auth surfaces are opt-in only and
// "Continue without account" performs zero sign-in attempts.

class FakeAuthBackend implements AuthBackend {
  final StreamController<KaryabUser?> _controller =
      StreamController<KaryabUser?>.broadcast();
  KaryabUser? user;
  String? nextErrorCode;
  int signInAttempts = 0;
  String? deletedWithPassword;
  bool signedOut = false;

  void _emit() => _controller.add(user);

  void _maybeThrow() {
    if (nextErrorCode != null) {
      final code = nextErrorCode!;
      nextErrorCode = null;
      throw AuthBackendException(code);
    }
  }

  @override
  Stream<KaryabUser?> get authStateChanges => _controller.stream;

  @override
  KaryabUser? get currentUser => user;

  @override
  Future<KaryabUser> signInWithGoogle() async {
    signInAttempts++;
    _maybeThrow();
    user = const KaryabUser(
      uid: 'g1',
      email: 'ahmad@gmail.com',
      displayName: 'Ahmad Ahmadi',
      providers: ['google.com'],
    );
    _emit();
    return user!;
  }

  @override
  Future<KaryabUser> signUpWithEmail(String email, String password) async {
    signInAttempts++;
    _maybeThrow();
    user = KaryabUser(uid: 'e1', email: email, providers: const ['password']);
    _emit();
    return user!;
  }

  @override
  Future<KaryabUser> signInWithEmail(String email, String password) async {
    signInAttempts++;
    _maybeThrow();
    user = KaryabUser(uid: 'e1', email: email, providers: const ['password']);
    _emit();
    return user!;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async => _maybeThrow();

  @override
  Future<void> signOut() async {
    signedOut = true;
    user = null;
    _emit();
  }

  @override
  Future<void> deleteAccount({String? password}) async {
    _maybeThrow();
    deletedWithPassword = password;
    user = null;
    _emit();
  }
}

class FakeBackupStore implements BackupStore {
  final Map<String, Map<String, dynamic>> byUid = {};

  @override
  Future<void> saveSnapshot(String uid, Map<String, dynamic> snapshot) async {
    byUid[uid] = snapshot;
  }

  @override
  Future<Map<String, dynamic>?> loadSnapshot(String uid) async => byUid[uid];

  @override
  Future<void> deleteSnapshot(String uid) async {
    byUid.remove(uid);
  }
}

class FakeBackupData implements BackupDataSource {
  Map<String, dynamic>? profile;
  List<CvDocumentRecord> cvs = [];
  List<LetterDocumentRecord> letters = [];
  List<CertificateRecord> certs = [];
  int _nextId = 100;

  @override
  Future<Map<String, dynamic>?> loadProfileMap() async => profile;

  @override
  Future<void> saveProfileMap(Map<String, dynamic> map) async {
    profile = map;
  }

  @override
  Future<List<CvDocumentRecord>> listCvDocuments() async => cvs;

  @override
  Future<List<LetterDocumentRecord>> listLetterDocuments() async => letters;

  @override
  Future<List<CertificateRecord>> listCertificates() async => certs;

  @override
  Future<int> createCvDocument(CvDocumentRecord r) async {
    cvs.add(CvDocumentRecord(
      id: _nextId++,
      kind: r.kind,
      name: r.name,
      payload: r.payload,
      templateId: r.templateId,
      accentColor: r.accentColor,
      fontSize: r.fontSize,
      spacing: r.spacing,
      showPhoto: r.showPhoto,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    ));
    return _nextId;
  }

  @override
  Future<int> createLetterDocument(LetterDocumentRecord r) async {
    letters.add(LetterDocumentRecord(
      id: _nextId++,
      name: r.name,
      payload: r.payload,
      company: r.company,
      jobTitle: r.jobTitle,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    ));
    return _nextId;
  }

  @override
  Future<int> createCertificate(CertificateRecord r) async {
    certs.add(CertificateRecord(
      id: _nextId++,
      label: r.label,
      kind: r.kind,
      createdAt: r.createdAt,
    ));
    return _nextId;
  }
}

CvDocumentRecord _cv(String name, DateTime at) => CvDocumentRecord(
      id: 1,
      kind: 'job',
      name: name,
      payload: const {'fullName': 'Ahmad'},
      createdAt: at,
      updatedAt: at,
    );

Widget _host(Widget child) {
  return ChangeNotifierProvider(
    create: (_) => LanguageProvider(),
    child: MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: child,
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('error mapping', () {
    test('provider codes map to kinds', () {
      expect(mapAuthErrorCode('wrong-password'), AuthErrorKind.wrongCredentials);
      expect(mapAuthErrorCode('user-not-found'), AuthErrorKind.wrongCredentials);
      expect(mapAuthErrorCode('weak-password'), AuthErrorKind.weakPassword);
      expect(mapAuthErrorCode('email-already-in-use'),
          AuthErrorKind.emailAlreadyInUse);
      expect(mapAuthErrorCode('network-request-failed'), AuthErrorKind.network);
      expect(mapAuthErrorCode('sign_in_failed'),
          AuthErrorKind.googleNotConfigured);
      expect(mapAuthErrorCode('something-else'), AuthErrorKind.unknown);
    });

    test('messages exist in all four languages', () {
      for (final lang in ['en', 'de', 'ps', 'fa']) {
        for (final kind in AuthErrorKind.values) {
          expect(authErrorMessage(kind, lang), isNotEmpty);
        }
      }
      expect(authErrorMessage(AuthErrorKind.wrongCredentials, 'de'),
          contains('nicht richtig'));
      expect(authErrorMessage(AuthErrorKind.googleNotConfigured, 'en'),
          contains('not available yet'));
    });
  });

  group('AuthService over fake backend', () {
    test('email sign-in returns the user and signs in', () async {
      final backend = FakeAuthBackend();
      final auth = AuthService(backend);
      final user = await auth.signInWithEmail('a@b.de', 'secret1');
      expect(user.email, 'a@b.de');
      expect(auth.isSignedIn, isTrue);
      expect(auth.currentUser?.providers, ['password']);
    });

    test('wrong password surfaces as AuthException(wrongCredentials)',
        () async {
      final backend = FakeAuthBackend()..nextErrorCode = 'wrong-password';
      final auth = AuthService(backend);
      await expectLater(
        auth.signInWithEmail('a@b.de', 'bad'),
        throwsA(isA<AuthException>().having(
            (e) => e.kind, 'kind', AuthErrorKind.wrongCredentials)),
      );
    });

    test('google not configured surfaces its dedicated kind', () async {
      final backend = FakeAuthBackend()
        ..nextErrorCode = 'google-not-configured';
      final auth = AuthService(backend);
      await expectLater(
        auth.signInWithGoogle(),
        throwsA(isA<AuthException>().having(
            (e) => e.kind, 'kind', AuthErrorKind.googleNotConfigured)),
      );
    });

    test('deleteAccount forwards the re-auth password', () async {
      final backend = FakeAuthBackend();
      final auth = AuthService(backend);
      await auth.deleteAccount(password: 'secret1');
      expect(backend.deletedWithPassword, 'secret1');
      expect(auth.isSignedIn, isFalse);
    });

    test('initials derive from name, then email', () {
      expect(
        const KaryabUser(uid: 'x', displayName: 'Ahmad Ahmadi', providers: [])
            .initials,
        'AA',
      );
      expect(
        const KaryabUser(uid: 'x', email: 'karim@example.com', providers: [])
            .initials,
        'K',
      );
    });
  });

  group('restore decision', () {
    final t1 = DateTime.utc(2026, 11, 1, 10);
    final t2 = DateTime.utc(2026, 11, 5, 10);

    test('no cloud backup', () {
      expect(
        CloudBackupService.decideRestore(
          cloudUpdatedAt: null,
          localHasData: false,
          localLatestUpdate: null,
          seenCloudUpdatedAt: null,
        ),
        RestoreDecision.noCloud,
      );
    });

    test('empty local device is offered a restore', () {
      expect(
        CloudBackupService.decideRestore(
          cloudUpdatedAt: t1,
          localHasData: false,
          localLatestUpdate: null,
          seenCloudUpdatedAt: null,
        ),
        RestoreDecision.offer,
      );
    });

    test('cloud newer than local is offered', () {
      expect(
        CloudBackupService.decideRestore(
          cloudUpdatedAt: t2,
          localHasData: true,
          localLatestUpdate: t1,
          seenCloudUpdatedAt: null,
        ),
        RestoreDecision.offer,
      );
    });

    test('local newer than cloud is not offered', () {
      expect(
        CloudBackupService.decideRestore(
          cloudUpdatedAt: t1,
          localHasData: true,
          localLatestUpdate: t2,
          seenCloudUpdatedAt: null,
        ),
        RestoreDecision.localNewerOrEqual,
      );
    });

    test('the same backup version is not offered twice', () {
      expect(
        CloudBackupService.decideRestore(
          cloudUpdatedAt: t2,
          localHasData: false,
          localLatestUpdate: null,
          seenCloudUpdatedAt: t2,
        ),
        RestoreDecision.alreadySeen,
      );
    });

    test('profile-only local data cannot prove it is newer, so offer', () {
      expect(
        CloudBackupService.decideRestore(
          cloudUpdatedAt: t1,
          localHasData: true,
          localLatestUpdate: null,
          seenCloudUpdatedAt: null,
        ),
        RestoreDecision.offer,
      );
    });
  });

  group('snapshot build and apply', () {
    test('snapshot shape: cert metadata only, no file paths', () {
      final at = DateTime.utc(2026, 11, 6, 12);
      final snapshot = CloudBackupService.buildSnapshot(
        profile: const {'fullName': 'Ahmad'},
        cvs: [_cv('CV Lager', at)],
        letters: const [],
        certificates: [
          CertificateRecord(
            id: 3,
            label: 'B1 Zertifikat',
            kind: 'language',
            filePath: '/data/cert.jpg',
            createdAt: at,
          ),
        ],
        now: at,
      );
      expect(snapshot['schema'], CloudBackupService.snapshotVersion);
      expect(CloudBackupService.snapshotUpdatedAt(snapshot), at);
      final certs = snapshot['certificates'] as List;
      expect(certs.single['label'], 'B1 Zertifikat');
      expect(certs.single.containsKey('file_path'), isFalse);
      expect(CloudBackupService.snapshotHasData(snapshot), isTrue);
    });

    test('backupNow stores the snapshot under the uid', () async {
      final store = FakeBackupStore();
      final data = FakeBackupData()
        ..profile = {'fullName': 'Ahmad'}
        ..cvs = [_cv('CV Lager', DateTime.utc(2026, 11, 1))];
      final backup = CloudBackupService(store, data: data);
      final at = await backup.backupNow('uid-1');
      expect(store.byUid['uid-1'], isNotNull);
      expect(
        CloudBackupService.snapshotUpdatedAt(store.byUid['uid-1']!),
        at,
      );
      expect(await backup.isEnabled(), isFalse); // default stays OFF
    });

    test('applyRestore adds missing docs and never duplicates', () async {
      final data = FakeBackupData();
      final backup = CloudBackupService(FakeBackupStore(), data: data);
      final at = DateTime.utc(2026, 11, 2);
      final snapshot = CloudBackupService.buildSnapshot(
        profile: const {'fullName': 'Ahmad'},
        cvs: [_cv('CV Lager', at)],
        letters: [
          LetterDocumentRecord(
            id: 9,
            name: 'Brief DHL',
            company: 'DHL',
            payload: const {'blocks': 'x'},
            createdAt: at,
            updatedAt: at,
          ),
        ],
        certificates: [
          CertificateRecord(
              id: 4, label: 'B1', kind: 'language', createdAt: at),
        ],
        now: at,
      );
      final first = await backup.applyRestore(snapshot);
      expect(first.profileRestored, isTrue);
      expect(first.cvsAdded, 1);
      expect(first.lettersAdded, 1);
      expect(first.certificatesAdded, 1);
      expect(data.profile?['fullName'], 'Ahmad');

      final second = await backup.applyRestore(snapshot);
      expect(second.cvsAdded, 0);
      expect(second.lettersAdded, 0);
      expect(second.certificatesAdded, 0);
      expect(data.cvs.length, 1);
    });
  });

  group('account and login screens', () {
    testWidgets('signed-out account screen is an invitation, not a gate',
        (tester) async {
      final backend = FakeAuthBackend();
      final backup = CloudBackupService(
        FakeBackupStore(),
        data: FakeBackupData(),
      );
      await tester.pumpWidget(_host(AccountScreen(
        language: 'en',
        authService: AuthService(backend),
        backupService: backup,
      )));
      await tester.pump();
      expect(find.text(AccountStrings.signIn('en')), findsOneWidget);
      expect(find.text(AccountStrings.noAccountNeeded('en')), findsOneWidget);
      expect(find.text(AccountStrings.deleteAccount('en')), findsNothing);
    });

    testWidgets(
        'login screen: guest path closes it with zero sign-in attempts',
        (tester) async {
      final backend = FakeAuthBackend();
      await tester.pumpWidget(_host(LoginScreen(
        language: 'en',
        authService: AuthService(backend),
      )));
      await tester.pump();
      expect(
          find.text(AccountStrings.continueWithGoogle('en')), findsOneWidget);
      expect(find.text(AccountStrings.continueWithoutAccount('en')),
          findsOneWidget);
      await tester.ensureVisible(
          find.text(AccountStrings.continueWithoutAccount('en')));
      await tester.pump();
      await tester
          .tap(find.text(AccountStrings.continueWithoutAccount('en')));
      await tester.pumpAndSettle();
      expect(backend.signInAttempts, 0);
      expect(find.byType(LoginScreen), findsNothing);
    });

    testWidgets('login screen: email sign-in closes the screen',
        (tester) async {
      final backend = FakeAuthBackend();
      await tester.pumpWidget(_host(LoginScreen(
        language: 'en',
        authService: AuthService(backend),
      )));
      await tester.pump();
      await tester.enterText(
          find.byType(TextField).first, 'ahmad@example.com');
      await tester.enterText(find.byType(TextField).last, 'secret1');
      await tester.tap(find.text(AccountStrings.signIn('en')).last);
      await tester.pumpAndSettle();
      expect(backend.user?.email, 'ahmad@example.com');
      expect(find.byType(LoginScreen), findsNothing);
    });

    testWidgets('signed-in account screen shows user and backup controls',
        (tester) async {
      final backend = FakeAuthBackend()
        ..user = const KaryabUser(
          uid: 'e1',
          email: 'ahmad@example.com',
          displayName: 'Ahmad Ahmadi',
          providers: ['password'],
        );
      final backup = CloudBackupService(
        FakeBackupStore(),
        data: FakeBackupData(),
      );
      await tester.pumpWidget(_host(AccountScreen(
        language: 'en',
        authService: AuthService(backend),
        backupService: backup,
      )));
      await tester.pump();
      expect(find.text('Ahmad Ahmadi'), findsOneWidget);
      expect(find.text('ahmad@example.com'), findsOneWidget);
      expect(find.text(AccountStrings.cloudBackup('en')), findsOneWidget);
      expect(find.text(AccountStrings.deleteAccount('en')), findsOneWidget);
      expect(find.byType(SwitchListTile), findsOneWidget);

      // Sign out returns the screen to the invitation (guest) state.
      await tester.ensureVisible(find.text(AccountStrings.signOut('en')));
      await tester.tap(find.text(AccountStrings.signOut('en')));
      await tester.pump();
      await tester.pump();
      expect(backend.signedOut, isTrue);
      expect(find.text(AccountStrings.noAccountNeeded('en')), findsOneWidget);
    });
  });
}
