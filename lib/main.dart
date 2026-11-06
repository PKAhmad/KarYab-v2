import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'constants/app_colors.dart';
import 'data/karyab_data.dart';
import 'ui/karyab_ui.dart';
import 'providers/language_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/education_screen.dart';
import 'screens/permissions_screen.dart';
import 'screens/introduction_screen.dart';
import 'screens/choose_cv_type_screen.dart';
import 'screens/questionnaire_screen.dart';
import 'screens/job_finder_screen.dart';
import 'screens/job_apply_screen.dart';
import 'screens/cv_preview_screen.dart';
import 'screens/ausbildung_screen.dart';
import 'screens/deutsch_courses_screen.dart';
import 'models/user_profile.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // v2 data layer: opens the Drift database and imports the v1
  // SharedPreferences profile/documents on first launch. Never throws -
  // on any failure the app keeps using the v1 store (see data/karyab_data.dart).
  await KaryabData.init();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const KarYabApp());
}

class KarYabApp extends StatelessWidget {
  const KarYabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, _) => MaterialApp(
      title: 'KarYab',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)],
      initialRoute: '/welcome',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        // Phase 5: Pashto/Dari render in the bundled Noto Naskh Arabic,
        // everything else in Roboto. Only styles without an explicit
        // fontFamily inherit this, so Latin screens are unchanged.
        fontFamily: karyabFontFamily(languageProvider.language),
        fontFamilyFallback: karyabFontFallback(languageProvider.language),
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          surface: AppColors.surface,
          onPrimary: Colors.white,
          onSurface: AppColors.textPrimary,
        ),
        useMaterial3: true,
      ),
      onGenerateRoute: (settings) {
        // Phase 5 liquid glide: the app's fade route gains a short
        // upward drift, so card-to-detail navigation feels like one
        // continuous surface. Reduced motion is honoured by the
        // framework's animation system on the device.
        PageRouteBuilder<dynamic> fade(Widget screen) => PageRouteBuilder(
              pageBuilder: (_, __, ___) => screen,
              transitionsBuilder: (_, animation, __, child) {
                final curved = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                );
                return FadeTransition(
                  opacity: curved,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.03),
                      end: Offset.zero,
                    ).animate(curved),
                    child: child,
                  ),
                );
              },
              transitionDuration: const Duration(milliseconds: 400),
            );

        switch (settings.name) {
          case '/welcome':
          case '/':
            return MaterialPageRoute(builder: (_) => const WelcomeScreen());
          case '/education': {
            final args = settings.arguments;
            final lang = args is Map<String, dynamic>
                ? args['language'] as String? ?? 'en'
                : args as String? ?? 'en';
            return fade(EducationScreen(language: lang));
          }
          case '/permissions': {
            final args = settings.arguments;
            String lang = 'en';
            bool voiceMode = false;
            if (args is Map<String, dynamic>) {
              lang      = args['language']  as String? ?? 'en';
              voiceMode = args['voiceMode'] as bool?   ?? false;
            } else if (args is Map) {
              lang      = args['language']  as String? ?? 'en';
              voiceMode = args['voiceMode'] == true;
            }
            return fade(PermissionsScreen(language: lang, voiceMode: voiceMode));
          }
          case '/introduction': {
            final args = settings.arguments;
            String lang = 'en';
            bool voiceMode = false;
            if (args is Map<String, dynamic>) {
              lang      = args['language']  as String? ?? 'en';
              voiceMode = args['voiceMode'] as bool?   ?? false;
            } else if (args is Map) {
              lang      = args['language']  as String? ?? 'en';
              voiceMode = args['voiceMode'] == true;
            }
            return fade(IntroductionScreen(language: lang, voiceMode: voiceMode));
          }
          case '/choose-cv-type': {
            final args = settings.arguments;
            String lang = 'en';
            bool voiceMode = false;
            if (args is Map<String, dynamic>) {
              lang      = args['language']  as String? ?? 'en';
              voiceMode = args['voiceMode'] as bool?   ?? false;
            } else if (args is Map) {
              lang      = args['language']  as String? ?? 'en';
              voiceMode = args['voiceMode'] == true;
            }
            return fade(ChooseCvTypeScreen(language: lang, voiceMode: voiceMode));
          }
          case '/questionnaire': {
            final args = settings.arguments;
            String lang = 'en';
            bool voiceMode = false;
            if (args is Map<String, dynamic>) {
              lang      = args['language']  as String? ?? 'en';
              voiceMode = args['voiceMode'] as bool?   ?? false;
            } else if (args is Map) {
              lang      = args['language']  as String? ?? 'en';
              voiceMode = args['voiceMode'] == true;
            }
            return fade(QuestionnaireScreen(language: lang, voiceMode: voiceMode));
          }
          case '/jobfinder': {
            final args = settings.arguments;
            if (args is Map<String, dynamic>) {
              final lang      = args['language']  as String? ?? 'en';
              final voiceMode = args['voiceMode'] as bool?   ?? false;
              // Phase 5: the home Minijobs card deep-links with the
              // Minijob filter preselected ('mj'/'tz'/'vz').
              final jobType   = args['jobType']   as String?;
              return fade(JobFinderScreen(
                language: lang,
                voiceMode: voiceMode,
                initialJobType: jobType,
              ));
            }
            final lang = args as String? ?? 'en';
            return fade(JobFinderScreen(language: lang));
          }
          case '/job_apply': {
            final args =
                settings.arguments as Map<String, String>? ?? const {};
            return fade(JobApplyScreen(
              jobTitle:       args['jobTitle']       ?? '',
              companyName:    args['companyName']    ?? '',
              jobLocation:    args['jobLocation']    ?? '',
              formUrl:        args['formUrl']        ?? '',
              companyPhone:   args['companyPhone']   ?? '',
              companyEmail:   args['companyEmail']   ?? '',
              companyWebsite: args['companyWebsite'] ?? '',
              refnr:          args['refnr']          ?? '',
              language:       args['language']       ?? 'en',
              voiceMode:      args['voiceMode']      == 'true',
              jobType:        args['jobType']        ?? '',
              isAusbildung:   args['isAusbildung']   == 'true',
            ));
          }
          case '/cv_preview': {
            final profile = settings.arguments;
            if (profile is UserProfile) {
              return fade(CvPreviewScreen(profile: profile));
            }
            return fade(const _CvPreviewPlaceholder());
          }
          case '/ausbildung': {
            final args = settings.arguments;
            if (args is Map<String, dynamic>) {
              final lang      = args['language']  as String? ?? 'en';
              final voiceMode = args['voiceMode'] as bool?   ?? false;
              return fade(AusbildungScreen(language: lang, voiceMode: voiceMode));
            }
            final lang = args as String? ?? 'en';
            return fade(AusbildungScreen(language: lang));
          }
          case '/deutsch-courses': {
            final args = settings.arguments;
            if (args is Map<String, dynamic>) {
              final lang      = args['language']  as String? ?? 'en';
              final voiceMode = args['voiceMode'] as bool?   ?? false;
              return fade(DeutschCoursesScreen(language: lang, voiceMode: voiceMode));
            }
            final lang = args as String? ?? 'en';
            return fade(DeutschCoursesScreen(language: lang));
          }
          default:
            return MaterialPageRoute(builder: (_) => const WelcomeScreen());
        }
      },
        ),
      ),
    );
  }
}

class _CvPreviewPlaceholder extends StatelessWidget {
  const _CvPreviewPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        title: const Text('CV Preview'),
      ),
      body: const Center(
        child: Text(
          'CV Preview coming soon',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
        ),
      ),
    );
  }
}
