import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:karyab/services/feedback_service.dart';
import 'package:karyab/widgets/home_dashboard.dart';

// Phase 7 feedback delivery (absent endpoint, payload shape, failing
// endpoint) and the home dashboard's real-count summary row.

void main() {
  group('FeedbackService', () {
    test('absent endpoint reports unavailable and never calls out',
        () async {
      var calls = 0;
      final service = FeedbackService(
        endpoint: '',
        client: MockClient((_) async {
          calls++;
          return http.Response('{}', 200);
        }),
      );
      expect(service.isConfigured, isFalse);
      final result = await service.send(text: 'Hallo', language: 'de');
      expect(result, FeedbackResult.unavailable);
      expect(calls, 0);
    });

    test('configured endpoint receives the documented payload', () async {
      Map<String, dynamic>? body;
      String? contentType;
      final service = FeedbackService(
        endpoint: 'https://hooks.example.invalid/feedback',
        client: MockClient((request) async {
          contentType = request.headers['Content-Type'];
          body = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response('{}', 200);
        }),
      );
      expect(service.isConfigured, isTrue);
      final result = await service.send(
        text: 'Die Suche ist toll',
        language: 'ps',
        screen: 'home',
      );
      expect(result, FeedbackResult.sent);
      expect(contentType, contains('application/json'));
      expect(body?['text'], 'Die Suche ist toll');
      expect(body?['language'], 'ps');
      expect(body?['screen'], 'home');
      expect(body?['app_version'], FeedbackService.appVersion);
      expect(body?['timestamp'], isA<String>());
      expect(
        DateTime.parse(body!['timestamp'] as String).isUtc,
        isTrue,
        reason: 'timestamp must be an ISO-8601 UTC string',
      );
    });

    test('server error and transport failure both report failed', () async {
      final failing = FeedbackService(
        endpoint: 'https://hooks.example.invalid/feedback',
        client: MockClient((_) async => http.Response('no', 500)),
      );
      expect(await failing.send(text: 'x', language: 'en'),
          FeedbackResult.failed);

      final offline = FeedbackService(
        endpoint: 'https://hooks.example.invalid/feedback',
        client: MockClient((_) async => throw http.ClientException('down')),
      );
      expect(await offline.send(text: 'x', language: 'en'),
          FeedbackResult.failed);
    });

    test('payload builder stamps version and UTC time', () {
      final payload = FeedbackService.buildPayload(
        text: 't',
        language: 'fa',
        now: DateTime.utc(2026, 11, 6, 12, 30),
      );
      expect(payload['timestamp'], '2026-11-06T12:30:00.000Z');
      expect(payload['screen'], '');
    });
  });

  group('HomeDashboard Phase 7 summary row', () {
    testWidgets('shows real counts and fires the tap targets', (t) async {
      var savedTapped = false;
      var trackerTapped = false;
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeDashboard(
              language: 'en',
              profilePercent: 40,
              onMinijobs: () {},
              savedJobsCount: 3,
              onSavedJobs: () => savedTapped = true,
              applicationsCount: 5,
              appliedCount: 2,
              onTracker: () => trackerTapped = true,
            ),
          ),
        ),
      );
      await t.pump();
      expect(find.text('3'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('Saved jobs'), findsOneWidget);
      expect(find.text('My applications'), findsOneWidget);
      expect(find.text('2 Applied'), findsOneWidget);

      await t.tap(find.text('Saved jobs'));
      expect(savedTapped, isTrue);
      await t.tap(find.text('My applications'));
      expect(trackerTapped, isTrue);
    });

    testWidgets('no counts means no summary row (Phase 5 behaviour)',
        (t) async {
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeDashboard(
              language: 'en',
              profilePercent: 40,
              onMinijobs: () {},
            ),
          ),
        ),
      );
      await t.pump();
      expect(find.text('Saved jobs'), findsNothing);
      expect(find.text('My applications'), findsNothing);
    });
  });
}
