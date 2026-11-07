import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/language_provider.dart';
import '../services/account_strings.dart';
import '../services/auth_service.dart';
import '../services/backup_service.dart';
import '../ui/karyab_ui.dart';
import 'login_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AccountScreen - Phase 6: account + opt-in cloud backup.
//
// Reachable from the home More sheet. When signed out it is an
// invitation, never a gate: the app works fully without an account, and
// this screen says so. When signed in it shows the user, the backup
// controls (default OFF, explicit consent), Download my data, sign out
// and Delete my account (Play requirement; in-app).
//
// Restore is always offered, never automatic: on sign-in, if a cloud
// backup exists that is newer than the local data (or local is empty),
// the user is asked once per backup version. Local data is never
// overwritten silently.
// ─────────────────────────────────────────────────────────────────────────────

class AccountScreen extends StatefulWidget {
  final String language;
  final bool voiceMode;

  /// Test seams: default to the app-wide services.
  final AuthService? authService;
  final CloudBackupService? backupService;

  const AccountScreen({
    super.key,
    required this.language,
    this.voiceMode = false,
    this.authService,
    this.backupService,
  });

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _backupEnabled = false;
  DateTime? _lastBackup;
  bool _busy = false;
  bool _restoreChecked = false;

  AuthService get _auth => widget.authService ?? karyabAuth;
  CloudBackupService get _backup => widget.backupService ?? karyabBackup;
  String get _lang => widget.language;
  bool get _isRtl => _lang == 'ps' || _lang == 'fa';

  @override
  void initState() {
    super.initState();
    _loadBackupState();
  }

  Future<void> _loadBackupState() async {
    try {
      final enabled = await _backup.isEnabled();
      final last = await _backup.lastBackupAt();
      if (mounted) {
        setState(() {
          _backupEnabled = enabled;
          _lastBackup = last;
        });
      }
    } catch (_) {
      // Backup state is best-effort UI; defaults are safe (off).
    }
  }

  void _snack(String text) {
    if (!mounted) return;
    kSnack(context, text);
  }

  String _dateText(DateTime at) {
    final d = at.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }

  // ── Restore offer (once per cloud backup version) ─────────────────────

  Future<void> _maybeOfferRestore(KaryabUser user) async {
    if (_restoreChecked || _busy) return;
    _restoreChecked = true;
    try {
      final offer = await _backup.restoreOffer(user.uid);
      if (offer.decision != RestoreDecision.offer ||
          offer.cloudUpdatedAt == null ||
          !mounted) {
        return;
      }
      final cloudAt = offer.cloudUpdatedAt!;
      await _backup.markRestoreSeen(cloudAt);
      if (!mounted) return;
      final restore = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AccountStrings.restoreFoundTitle(_lang)),
          content: Text(
            AccountStrings.restoreFoundBody(_lang, _dateText(cloudAt)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AccountStrings.notNow(_lang)),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(AccountStrings.restoreAction(_lang)),
            ),
          ],
        ),
      );
      if (restore == true) await _doRestore(user);
    } catch (_) {
      // A failed restore CHECK must never disturb the account screen.
    }
  }

  Future<void> _doRestore(KaryabUser user) async {
    setState(() => _busy = true);
    try {
      final snapshot = await _backup.fetchCloudSnapshot(user.uid);
      if (snapshot == null) {
        _snack(AccountStrings.noBackupFound(_lang));
        return;
      }
      await _backup.applyRestore(snapshot);
      _snack(AccountStrings.restoreDone(_lang));
    } catch (_) {
      _snack(AccountStrings.backupFailed(_lang));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restorePressed(KaryabUser user) async {
    setState(() => _busy = true);
    try {
      final offer = await _backup.restoreOffer(user.uid);
      switch (offer.decision) {
        case RestoreDecision.noCloud:
          _snack(AccountStrings.noBackupFound(_lang));
        case RestoreDecision.localNewerOrEqual:
          _snack(AccountStrings.localNewer(_lang));
        case RestoreDecision.alreadySeen:
        case RestoreDecision.offer:
          await _doRestore(user);
      }
    } catch (_) {
      _snack(AccountStrings.backupFailed(_lang));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ── Backup actions ─────────────────────────────────────────────────────

  Future<void> _toggleBackup(bool value, KaryabUser user) async {
    if (!value) {
      await _backup.setEnabled(false);
      if (mounted) setState(() => _backupEnabled = false);
      return;
    }
    // Explicit consent: the full consent text in a dialog; the backup
    // only turns on when the user confirms it there.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AccountStrings.cloudBackup(_lang)),
        content: Text(AccountStrings.backupConsent(_lang)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AccountStrings.cancel(_lang)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AccountStrings.turnOn(_lang)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _backup.setEnabled(true);
    if (mounted) setState(() => _backupEnabled = true);
    // First backup right away, so turning it on has a visible effect.
    await _backupNow(user);
  }

  Future<void> _backupNow(KaryabUser user) async {
    setState(() => _busy = true);
    try {
      final at = await _backup.backupNow(user.uid);
      if (mounted) setState(() => _lastBackup = at);
      _snack(AccountStrings.backupDone(_lang));
    } catch (_) {
      _snack(AccountStrings.backupFailed(_lang));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _downloadMyData() async {
    setState(() => _busy = true);
    try {
      final snapshot = await _backup.buildLocalSnapshot();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/karyab_my_data.json');
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(snapshot),
      );
      await Share.shareXFiles([
        XFile(file.path),
      ], subject: 'KarYab data export');
    } catch (_) {
      _snack(AccountStrings.backupFailed(_lang));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ── Delete account ─────────────────────────────────────────────────────

  Future<void> _deleteAccount(KaryabUser user) async {
    final passwordController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AccountStrings.deleteAccount(_lang)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AccountStrings.deleteAccountBody(_lang)),
            if (user.isEmailUser && !user.isGoogleUser) ...[
              const SizedBox(height: 14),
              Text(AccountStrings.enterPasswordConfirm(_lang)),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: AccountStrings.password(_lang),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AccountStrings.cancel(_lang)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB3261E),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AccountStrings.delete(_lang)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _busy = true);
    try {
      // Cloud backup first: after the account is gone the uid's
      // Firestore document would be orphaned.
      try {
        await _backup.deleteCloudBackup(user.uid);
      } catch (_) {}
      await _auth.deleteAccount(
        password: passwordController.text.isEmpty
            ? null
            : passwordController.text,
      );
      _snack(AccountStrings.accountDeleted(_lang));
    } on AuthException catch (e) {
      _snack(authErrorMessage(e.kind, _lang));
    } catch (_) {
      _snack(AccountStrings.backupFailed(_lang));
    } finally {
      passwordController.dispose();
      if (mounted) setState(() => _busy = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
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
              child: StreamBuilder<KaryabUser?>(
                stream: _auth.authStateChanges,
                initialData: _auth.currentUser,
                builder: (context, snapshot) {
                  final user = snapshot.data;
                  if (user != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _maybeOfferRestore(user);
                    });
                  }
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _header(lang),
                        const SizedBox(height: 18),
                        if (user == null)
                          _signedOut(lang)
                        else
                          _signedIn(lang, user),
                        const SizedBox(height: 18),
                        Text(
                          AccountStrings.privacyNote(lang),
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(String lang) {
    return Row(
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
    );
  }

  Widget _signedOut(String lang) {
    return KGlassSurface(
      borderRadius: 20,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.account_circle_rounded,
            color: KColors.navy,
            size: 52,
          ),
          const SizedBox(height: 12),
          Text(
            AccountStrings.loginBenefit(lang),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: karyabFontFamily(lang),
              color: KColors.navy,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            AccountStrings.noAccountNeeded(lang),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: karyabFontFamily(lang),
              color: KColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          KPrimaryCta(
            icon: Icons.login_rounded,
            label: AccountStrings.signIn(lang),
            isRtl: _isRtl,
            isSelected: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LoginScreen(
                    language: lang,
                    voiceMode: widget.voiceMode,
                    authService: widget.authService,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _avatar(KaryabUser user) {
    final initials = CircleAvatar(
      radius: 30,
      backgroundColor: KColors.mint,
      child: Text(
        user.initials,
        style: const TextStyle(
          color: KColors.greenDark,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
    if (user.photoUrl == null || user.photoUrl!.isEmpty) return initials;
    return CircleAvatar(
      radius: 30,
      backgroundColor: KColors.mint,
      child: ClipOval(
        child: Image.network(
          user.photoUrl!,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Center(
            child: Text(
              user.initials,
              style: const TextStyle(
                color: KColors.greenDark,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _signedIn(String lang, KaryabUser user) {
    final name =
        (user.displayName != null && user.displayName!.trim().isNotEmpty)
        ? user.displayName!
        : (user.email ?? '');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KGlassSurface(
          borderRadius: 20,
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          child: Row(
            children: [
              _avatar(user),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontFamily: karyabFontFamily(lang),
                        color: KColors.navy,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (user.email != null && user.email != name)
                      Text(
                        user.email!,
                        style: TextStyle(
                          fontFamily: karyabFontFamily(lang),
                          color: KColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Backup card
        KGlassCard(
          borderRadius: 20,
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Material(
                type: MaterialType.transparency,
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    AccountStrings.cloudBackup(lang),
                    style: TextStyle(
                      fontFamily: karyabFontFamily(lang),
                      color: KColors.navy,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  value: _backupEnabled,
                  activeThumbColor: KColors.green,
                  onChanged: _busy ? null : (v) => _toggleBackup(v, user),
                ),
              ),
              Text(
                AccountStrings.backupConsent(lang),
                style: TextStyle(
                  fontFamily: karyabFontFamily(lang),
                  color: KColors.textSecondary,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${AccountStrings.lastBackup(lang)}: '
                '${_lastBackup == null ? AccountStrings.never(lang) : _dateText(_lastBackup!)}',
                style: TextStyle(
                  fontFamily: karyabFontFamily(lang),
                  color: KColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _glassButton(
                      label: AccountStrings.backupNow(lang),
                      lang: lang,
                      onTap: (_busy || !_backupEnabled)
                          ? null
                          : () => _backupNow(user),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _glassButton(
                      label: AccountStrings.restore(lang),
                      lang: lang,
                      onTap: _busy ? null : () => _restorePressed(user),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _actionTile(
          icon: Icons.download_rounded,
          label: AccountStrings.downloadMyData(lang),
          lang: lang,
          onTap: _busy ? null : _downloadMyData,
        ),
        const SizedBox(height: 10),
        _actionTile(
          icon: Icons.logout_rounded,
          label: AccountStrings.signOut(lang),
          lang: lang,
          onTap: _busy
              ? null
              : () async {
                  await _auth.signOut();
                },
        ),
        const SizedBox(height: 10),
        _actionTile(
          icon: Icons.delete_forever_rounded,
          label: AccountStrings.deleteAccount(lang),
          lang: lang,
          danger: true,
          onTap: _busy ? null : () => _deleteAccount(user),
        ),
        if (_busy) ...[
          const SizedBox(height: 16),
          const Center(child: CircularProgressIndicator(color: KColors.green)),
        ],
      ],
    );
  }

  // Secondary action button in the kit glass style (same shape as the
  // CV wizard's Back/Skip buttons): 52 high, radius 22, centred label.
  // A null [onTap] renders it disabled (dimmed, no tap).
  Widget _glassButton({
    required String label,
    required String lang,
    required VoidCallback? onTap,
  }) {
    return Opacity(
      opacity: onTap == null ? 0.5 : 1,
      child: SizedBox(
        height: 52,
        child: KGlassCard(
          borderRadius: 22,
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: karyabFontFamily(lang),
                color: KColors.navy,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String label,
    required String lang,
    required VoidCallback? onTap,
    bool danger = false,
  }) {
    final color = danger ? const Color(0xFFC0392B) : KColors.navy;
    return KGlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        type: MaterialType.transparency,
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: color),
          title: Text(
            label,
            style: TextStyle(
              fontFamily: karyabFontFamily(lang),
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
