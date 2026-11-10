import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';
import '../services/account_strings.dart';
import '../services/auth_service.dart';
import '../ui/karyab_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LoginScreen - Phase 6: Google + email sign-in, on the shared light
// glass kit (KBackgroundGlow + glass surfaces), unified with the rest
// of the app in Phase 10.
//
// Guest mode is sacred: this screen is only ever reached when the user
// taps an account entry point. "Continue without account" is a first
// class, equally visible path and simply closes the screen. Nothing in
// the app is gated behind this screen.
//
// If Google Sign-In is not activated yet in the Firebase console (the
// development state until the final package + SHA fingerprints land),
// the backend maps that to AuthErrorKind.googleNotConfigured and the
// user sees a friendly "not available yet" message, never a crash.
// ─────────────────────────────────────────────────────────────────────────────

class LoginScreen extends StatefulWidget {
  final String language;
  final bool voiceMode;

  /// Test seam: defaults to the app-wide [karyabAuth].
  final AuthService? authService;

  const LoginScreen({
    super.key,
    required this.language,
    this.voiceMode = false,
    this.authService,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _signUp = false;
  bool _busy = false;
  String? _error;
  String? _notice;

  AuthService get _auth => widget.authService ?? karyabAuth;
  String get _lang => widget.language;
  bool get _isRtl => _lang == 'ps' || _lang == 'fa' || _lang == 'ar';

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
    });
    try {
      await action();
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => _error = authErrorMessage(e.kind, _lang));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = authErrorMessage(AuthErrorKind.unknown, _lang));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _google() => _run(() async {
    await _auth.signInWithGoogle();
    if (mounted) Navigator.pop(context, true);
  });

  Future<void> _emailSubmit() => _run(() async {
    if (_signUp) {
      await _auth.signUpWithEmail(_email.text, _password.text);
    } else {
      await _auth.signInWithEmail(_email.text, _password.text);
    }
    if (mounted) Navigator.pop(context, true);
  });

  Future<void> _forgot() => _run(() async {
    await _auth.sendPasswordReset(_email.text);
    if (mounted) {
      setState(() => _notice = AccountStrings.passwordResetSent(_lang));
    }
  });

  TextStyle get _labelStyle => TextStyle(
    fontFamily: karyabFontFamily(_lang),
    color: KColors.textSecondary,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  InputDecoration _fieldDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: _labelStyle,
    filled: true,
    fillColor: Colors.white,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: KColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: KColors.green),
    ),
  );

  @override
  Widget build(BuildContext context) {
    // Keep the language in sync with the app-wide provider (the screen
    // also receives it as a nav argument, like every other screen).
    final providerLang = context.watch<LanguageProvider>().language;
    final lang = providerLang.isNotEmpty ? providerLang : _lang;
    return Directionality(
      textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: KColors.pageBase,
        body: Stack(
          children: [
            const KBackgroundGlow(),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        KNavButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            AccountStrings.account(lang),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: karyabFontFamily(lang),
                              color: KColors.navy,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 44),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      AccountStrings.loginBenefit(lang),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: karyabFontFamily(lang),
                        color: KColors.textSecondary,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 22),
                    KGlassSurface(
                      borderRadius: 20,
                      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Google
                          SizedBox(
                            height: 54,
                            child: KGlassCard(
                              borderRadius: 16,
                              onTap: _busy ? null : _google,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'G',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF4285F4),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    AccountStrings.continueWithGoogle(lang),
                                    style: TextStyle(
                                      fontFamily: karyabFontFamily(lang),
                                      color: KColors.navy,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(color: KColors.border),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Text(
                                  AccountStrings.orWithEmail(lang),
                                  style: _labelStyle,
                                ),
                              ),
                              const Expanded(
                                child: Divider(color: KColors.border),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          TextField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            style: const TextStyle(color: KColors.navy),
                            decoration: _fieldDecoration(
                              AccountStrings.email(lang),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _password,
                            obscureText: true,
                            autofillHints: [
                              _signUp
                                  ? AutofillHints.newPassword
                                  : AutofillHints.password,
                            ],
                            style: const TextStyle(color: KColors.navy),
                            decoration: _fieldDecoration(
                              AccountStrings.password(lang),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: TextButton(
                              onPressed: _busy ? null : _forgot,
                              child: Text(
                                AccountStrings.forgotPassword(lang),
                                style: TextStyle(
                                  fontFamily: karyabFontFamily(lang),
                                  color: KColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          if (_error != null) ...[
                            Text(
                              _error!,
                              style: TextStyle(
                                fontFamily: karyabFontFamily(lang),
                                color: const Color(0xFFC0392B),
                                fontSize: 14,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                          if (_notice != null) ...[
                            Text(
                              _notice!,
                              style: TextStyle(
                                fontFamily: karyabFontFamily(lang),
                                color: KColors.greenDark,
                                fontSize: 14,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                          Stack(
                            children: [
                              KPrimaryCta(
                                icon: Icons.login_rounded,
                                label: _signUp
                                    ? AccountStrings.createAccount(lang)
                                    : AccountStrings.signIn(lang),
                                isRtl: _isRtl,
                                isSelected: false,
                                onTap: () {
                                  if (!_busy) _emailSubmit();
                                },
                              ),
                              if (_busy)
                                Positioned.directional(
                                  textDirection: _isRtl
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                  start: 8,
                                  top: 13,
                                  child: Container(
                                    width: 38,
                                    height: 38,
                                    padding: const EdgeInsets.all(9),
                                    decoration: const BoxDecoration(
                                      color: KColors.ctaStart,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const CircularProgressIndicator(
                                      color: KColors.green,
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          TextButton(
                            onPressed: _busy
                                ? null
                                : () => setState(() {
                                    _signUp = !_signUp;
                                    _error = null;
                                    _notice = null;
                                  }),
                            child: Text(
                              _signUp
                                  ? AccountStrings.signIn(lang)
                                  : AccountStrings.createAccount(lang),
                              style: TextStyle(
                                fontFamily: karyabFontFamily(lang),
                                color: KColors.navy,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 56,
                      child: KGlassCard(
                        borderRadius: 22,
                        onTap: () => Navigator.pop(context, false),
                        child: Center(
                          child: Text(
                            AccountStrings.continueWithoutAccount(lang),
                            style: TextStyle(
                              fontFamily: karyabFontFamily(lang),
                              color: KColors.navy,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AccountStrings.noAccountNeeded(lang),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: karyabFontFamily(lang),
                        color: KColors.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
