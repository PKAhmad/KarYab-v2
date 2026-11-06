import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/secrets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FeedbackService - Phase 7 "Send feedback" delivery.
//
// The endpoint is a single named value in the gitignored
// lib/config/secrets.dart (Secrets.feedbackWebhookUrl), the same
// pattern as the Azure TTS key. The CEO activates feedback by pasting
// his n8n webhook URL into his local secrets file; until then the
// value is empty, the service reports [FeedbackResult.unavailable],
// and the feedback sheet offers share_plus so the user can still send
// the text manually. No endpoint is invented anywhere in the code.
//
// The service is injectable (http client + endpoint) for tests.
// ─────────────────────────────────────────────────────────────────────────────

enum FeedbackResult { sent, unavailable, failed }

class FeedbackService {
  FeedbackService({http.Client? client, String? endpoint})
      : _client = client ?? http.Client(),
        endpoint = endpoint ?? Secrets.feedbackWebhookUrl;

  final http.Client _client;

  /// The configured webhook URL ('' when not configured).
  final String endpoint;

  /// App version sent with every feedback payload. Kept in step with
  /// pubspec.yaml (1.0.0+1); package_info_plus is not a dependency.
  static const String appVersion = '1.0.0+1';

  bool get isConfigured => endpoint.trim().isNotEmpty;

  /// The exact JSON payload posted to the webhook.
  static Map<String, dynamic> buildPayload({
    required String text,
    required String language,
    String screen = '',
    DateTime? now,
  }) {
    return {
      'text': text,
      'app_version': appVersion,
      'language': language,
      'screen': screen,
      'timestamp': (now ?? DateTime.now()).toUtc().toIso8601String(),
    };
  }

  Future<FeedbackResult> send({
    required String text,
    required String language,
    String screen = '',
  }) async {
    if (!isConfigured) return FeedbackResult.unavailable;
    final uri = Uri.tryParse(endpoint.trim());
    if (uri == null || !uri.hasScheme) return FeedbackResult.failed;
    try {
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(buildPayload(
              text: text,
              language: language,
              screen: screen,
            )),
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode >= 200 && response.statusCode < 300
          ? FeedbackResult.sent
          : FeedbackResult.failed;
    } catch (_) {
      return FeedbackResult.failed;
    }
  }
}
