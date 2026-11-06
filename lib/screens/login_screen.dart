import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';
import '../services/account_strings.dart';
import '../services/auth_service.dart';
import '../ui/karyab_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LoginScreen - Phase 6: Google + email sign-in, on the Phase 5 glass kit
// (LiquidBackground + glass panels).
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
  bool get _isRtl => _lang == 'ps' || _lang == 'fa';

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
        setState(() =>
            _error = authErrorMessage(AuthErrorKind.unknown, _lang));
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
          setState(
              () => _notice = AccountStrings.passwordResetSent(_lang));
        }
      });

  TextStyle get _labelStyle => TextStyle(
        fontFamily: karyabFontFamily(_lang),
        color: KLiquid.textOnDarkSoft,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      );

  InputDecoration _fieldDecoration(String label) => InputDecoration(
        labelText: label,
        labelStyle: _labelStyle,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: KLiquid.l2Border),
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
        backgroundColor: KLiquid.navyTop,
        body: LiquidBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        _isRtl
                            ? Icons.arrow_forward_ios_rounded
                            : Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AccountStrings.account(lang),
                    style: TextStyle(
                      fontFamily: karyabFontFamily(lang),
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AccountStrings.loginBenefit(lang),
                    style: TextStyle(
                      fontFamily: karyabFontFamily(lang),
                      color: KLiquid.textOnDarkSoft,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 22),
                  KGlassPanel(
                    level: KGlassLevel.l2,
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Google
                        SizedBox(
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: _busy ? null : _google,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1F1F1F),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            icon: const Text(
                              'G',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF4285F4),
                              ),
                            ),
                            label: Text(
                              AccountStrings.continueWithGoogle(lang),
                              style: TextStyle(
                                fontFamily: karyabFontFamily(lang),
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            const Expanded(
                                child: Divider(color: KLiquid.l2Border)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                AccountStrings.orWithEmail(lang),
                                style: _labelStyle,
                              ),
                            ),
                            const Expanded(
                                child: Divider(color: KLiquid.l2Border)),
                          ],
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          style: const TextStyle(color: Colors.white),
                          decoration:
                              _fieldDecoration(AccountStrings.email(lang)),
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
                          style: const TextStyle(color: Colors.white),
                          decoration: _fieldDecoration(
                              AccountStrings.password(lang)),
                        ),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: TextButton(
                            onPressed: _busy ? null : _forgot,
                            child: Text(
                              AccountStrings.forgotPassword(lang),
                              style: TextStyle(
                                fontFamily: karyabFontFamily(lang),
                                color: KLiquid.textOnDarkSoft,
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
                              color: const Color(0xFFFF9D9D),
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
                              color: KColors.green,
                              fontSize: 14,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _busy ? null : _emailSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: KColors.green,
                              foregroundColor: const Color(0xFF06230A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: _busy
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Color(0xFF06230A),
                                    ),
                                  )
                                : Text(
                                    _signUp
                                        ? AccountStrings.createAccount(lang)
                                        : AccountStrings.signIn(lang),
                                    style: TextStyle(
                                      fontFamily: karyabFontFamily(lang),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
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
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 54,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: KLiquid.l2Border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        AccountStrings.continueWithoutAccount(lang),
                        style: TextStyle(
                          fontFamily: karyabFontFamily(lang),
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
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
                      color: KLiquid.textOnDarkSoft,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
