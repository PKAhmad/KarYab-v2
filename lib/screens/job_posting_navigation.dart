import 'package:flutter/material.dart';

import '../services/job_search_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Phase 7 shared helper: opens the job detail / apply screen for a BA
// posting using the exact '/job_apply' argument contract the finder
// lists have always used, so Saved Jobs and saved-search results open a
// posting the same way a fresh search result does.
// ─────────────────────────────────────────────────────────────────────────────

void openJobPosting(
  BuildContext context,
  BaJob job, {
  required String language,
  bool voiceMode = false,
  bool isAusbildung = false,
}) {
  final addrParts = <String>[];
  if (job.strasseHausnummer.isNotEmpty) addrParts.add(job.strasseHausnummer);
  final cityPart = [job.plz, job.ort].where((s) => s.isNotEmpty).join(' ');
  if (cityPart.isNotEmpty) addrParts.add(cityPart);

  Navigator.pushNamed(
    context,
    '/job_apply',
    arguments: <String, String>{
      'jobTitle': job.title,
      'companyName': job.company,
      'companyAddress': addrParts.join(', '),
      'jobLocation': job.locationDisplay,
      'formUrl':
          'https://www.arbeitsagentur.de/jobsuche/jobdetail/${job.refnr}',
      'companyPhone': '',
      'companyEmail': '',
      'companyWebsite': '',
      'refnr': job.refnr,
      'language': language,
      'voiceMode': voiceMode.toString(),
      'isAusbildung': isAusbildung ? 'true' : 'false',
      'jobType': '',
    },
  );
}
