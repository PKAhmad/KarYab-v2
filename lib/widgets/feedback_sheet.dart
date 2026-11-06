import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../services/feedback_service.dart';
import '../services/jobs_strings.dart';
import '../ui/karyab_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Feedback sheet - Phase 7. A glass bottom sheet with one text field.
// When the webhook is configured (FeedbackService.isConfigured), Send
// posts the text with automatic context (app version, language, screen
// name). When it is not configured yet, the sheet says so honestly and
// offers "Share instead" (share_plus) so the text can still leave the
// phone manually. A failed send offers the same fallback.
// ─────────────────────────────────────────────────────────────────────────────

Future<void> showFeedbackSheet(
  BuildContext context, {
  required String language,
  String screen = 'home',
  FeedbackService? service,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _FeedbackSheet(
      language: language,
      screen: screen,
      service: service ?? FeedbackService(),
    ),
  );
}

class _FeedbackSheet extends StatefulWidget {
  final String language;
  final String screen;
  final FeedbackService service;

  const _FeedbackSheet({
    required this.language,
    required this.screen,
    required this.service,
  });

  @override
  State<_FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<_FeedbackSheet> {
  static const Color _navy = KColors.navy;
  static const Color _muted = KColors.textSecondary;

  String get _lang => widget.language;

  final _ctrl = TextEditingController();
  bool _sending = false;
  bool _failed = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _share() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) {
      kSnack(context, JobsStrings.feedbackEmpty(_lang));
      return;
    }
    await Share.share(text);
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) {
      kSnack(context, JobsStrings.feedbackEmpty(_lang));
      return;
    }
    setState(() {
      _sending = true;
      _failed = false;
    });
    final result = await widget.service.send(
      text: text,
      language: _lang,
      screen: widget.screen,
    );
    if (!mounted) return;
    setState(() => _sending = false);
    switch (result) {
      case FeedbackResult.sent:
        Navigator.pop(context);
        kSnack(context, JobsStrings.feedbackThanks(_lang));
      case FeedbackResult.unavailable:
        // Should not happen (the sheet checks isConfigured first), but
        // keep the honest state if configuration changed under us.
        setState(() => _failed = true);
      case FeedbackResult.failed:
        setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final configured = widget.service.isConfigured;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: kSheetDecoration,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: KSheetHandle()),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.feedback_rounded, color: _navy, size: 20),
                const SizedBox(width: 8),
                Text(
                  JobsStrings.sendFeedback(_lang),
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ctrl,
              minLines: 3,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: JobsStrings.feedbackHint(_lang),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: KColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: KColors.border),
                ),
              ),
            ),
            if (!configured) ...[
              const SizedBox(height: 12),
              Text(
                JobsStrings.feedbackUnavailable(_lang),
                style: const TextStyle(color: _muted, fontSize: 13),
              ),
            ],
            if (_failed) ...[
              const SizedBox(height: 12),
              Text(
                JobsStrings.feedbackFailed(_lang),
                style: const TextStyle(color: _muted, fontSize: 13),
              ),
            ],
            const SizedBox(height: 16),
            if (configured)
              ElevatedButton(
                onPressed: _sending ? null : _send,
                style: ElevatedButton.styleFrom(
                  backgroundColor: KColors.green,
                  foregroundColor: _navy,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        JobsStrings.send(_lang),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            if (!configured || _failed) ...[
              if (configured) const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _share,
                icon: const Icon(Icons.share_rounded, size: 18),
                label: Text(JobsStrings.feedbackShareInstead(_lang)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
