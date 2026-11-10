import 'package:flutter/material.dart';

import 'guide_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Guides content, German (Phase 11). This file is the reference for
// the facts; the other languages say the same thing in simpler words.
// Figures checked November 2026 against make-it-in-germany.com (visa
// for vocational training, figures as of 2026) and
// anerkennung-in-deutschland.de. No em-dashes in any string.
// ─────────────────────────────────────────────────────────────────────────────

const List<GuideTrack> kGuidesDe = [
  GuideTrack(
    id: 'exam',
    icon: Icons.school_rounded,
    title: 'Deutschprüfung, Schritt für Schritt',
    subtitle: 'Von der richtigen Prüfung bis zum Zertifikat',
    steps: [
      GuideStep(
        id: 'which_exam',
        icon: Icons.help_outline_rounded,
        title: 'Welche Prüfung brauche ich?',
        paragraphs: [
          'Es gibt verschiedene Deutschprüfungen. Die richtige Prüfung hängt von Ihrem Ziel ab.',
          'Wenn Sie in Deutschland leben und einen Integrationskurs machen, ist Ihre Abschlussprüfung der DTZ (Deutsch-Test für Zuwanderer). Er prüft die Stufen A2 und B1.',
          'Für eine Ausbildung brauchen Sie normalerweise B1. Für viele Jobs und für einen B2-Kurs fragen Ämter und Firmen nach einem telc-, Goethe- oder ÖSD-Zertifikat auf B1 oder B2.',
          'Für die Universität brauchen Sie ein hohes Niveau: telc Deutsch C1 Hochschule, die DSH-Prüfung oder TestAS mit einem Sprachzertifikat. Fragen Sie Ihre Universität, welche Prüfungen sie akzeptiert.',
          'Fragen Sie vor der Bezahlung das Amt oder die Firma, welches Zertifikat es will. Dann machen Sie die richtige Prüfung nur einmal.',
        ],
      ),
      GuideStep(
        id: 'know_level',
        icon: Icons.speed_rounded,
        title: 'Kennen Sie Ihr Niveau',
        paragraphs: [
          'Finden Sie vor der Prüfung Ihr Niveau heraus: A1, A2, B1, B2 oder C1.',
          'Viele Sprachschulen geben einen kostenlosen Einstufungstest. Der Test ist kurz. Sie lesen, schreiben und sprechen ein wenig. Sie bekommen Ihr Niveau sofort.',
          'Wichtig: Wenn Ihr letztes Zertifikat älter als etwa 6 Monate ist, verlangen viele Schulen vor dem nächsten Kurs einen neuen Einstufungstest.',
          'Seien Sie ehrlich zu sich selbst. Eine Prüfung auf dem richtigen Niveau ist leichter zu bestehen.',
        ],
        actions: [GuideAction.deutschCourses],
      ),
      GuideStep(
        id: 'register',
        icon: Icons.how_to_reg_rounded,
        title: 'Melden Sie sich offiziell an',
        paragraphs: [
          'Melden Sie sich nur auf den offiziellen Seiten von telc, dem Goethe-Institut oder ÖSD an, oder bei einem lizenzierten Prüfungszentrum.',
          'Prüfungsplätze sind begrenzt und schnell weg. Melden Sie sich früh an, sobald Sie Ihren Prüfungstermin kennen.',
          'Bezahlen Sie nur die offizielle Prüfungsgebühr. Bewahren Sie die Quittung und die Bestätigung auf.',
        ],
        documents: [
          'Ihr Reisepass oder Personalausweis',
          'Die Prüfungsgebühr, bezahlt wie das Zentrum es verlangt (Karte oder Überweisung)',
        ],
        warning:
            'Bezahlen Sie niemals einen Vermittler oder Agenten, der Ihnen einen Prüfungsplatz oder ein Zertifikat verspricht. In Pakistan verlangen Vermittler etwa 300 Dollar für eine Goethe-B1-Anmeldung. Der Platz ist nicht sicher, und ein gekauftes Zertifikat ist wertlos und kann Ihnen große Probleme bringen. Sicher ist die Anmeldung nur auf den offiziellen Seiten.',
        links: [
          GuideLink(
            url: 'https://www.telc.net',
            label: 'telc, offizielle Seite',
          ),
          GuideLink(
            url: 'https://www.goethe.de',
            label: 'Goethe-Institut, offizielle Seite',
          ),
        ],
      ),
      GuideStep(
        id: 'prepare',
        icon: Icons.menu_book_rounded,
        title: 'Bereiten Sie sich gut vor',
        paragraphs: [
          'Jede Prüfung hat 4 Teile: Lesen, Hören, Schreiben und Sprechen.',
          'Üben Sie mit Modelltests. Sie zeigen Ihnen die echten Aufgaben und die Zeit. Sie finden sie kostenlos auf den Seiten von telc, Goethe und ÖSD.',
          'Lernen Sie für Schreiben feste Sätze (Redemittel). Ein klarer Aufbau gibt gute Punkte: eine Begrüßung, Ihr Anliegen, ein Grund und ein freundlicher Schluss.',
          'Bücher, die viele Lernende nutzen: Grammatik Aktiv für Grammatik, Aspekte als Kursbuch für B1 und B2, und Hören und Sprechen zum Üben von Hören und Sprechen.',
          'Üben Sie jeden Tag laut sprechen, am besten mit einem Partner oder in einem Kurs.',
        ],
      ),
      GuideStep(
        id: 'exam_day',
        icon: Icons.event_rounded,
        title: 'Am Prüfungstag',
        paragraphs: [
          'Kommen Sie früh, wie es in Ihrer Einladung steht. Wenn Sie zu spät kommen, dürfen Sie nicht hinein.',
          'Ohne Reisepass oder Personalausweis können Sie die Prüfung nicht machen.',
          'Handys müssen aus sein und weggelegt werden. In den meisten Prüfungen dürfen Sie kein Wörterbuch benutzen.',
          'Die Prüfung geht Teil für Teil: Lesen, Hören, Schreiben, Sprechen. Der Sprechteil ist oft zu zweit.',
          'Bleiben Sie ruhig. Wenn Sie eine Aufgabe nicht verstehen, fragen Sie die Prüfer, bevor der Teil beginnt.',
        ],
        documents: [
          'Reisepass oder Personalausweis',
          'Ihre Einladung oder Anmeldebestätigung',
        ],
      ),
      GuideStep(
        id: 'results',
        icon: Icons.workspace_premium_rounded,
        title: 'Ergebnisse und Ihr Zertifikat',
        paragraphs: [
          'Ergebnisse brauchen Zeit, meistens einige Wochen. Das Zentrum sagt Ihnen, wie Sie sie bekommen, oft online oder per Post.',
          'Sie bestehen, wenn Sie in jedem Teil der Prüfung genug Punkte erreichen. Ein sehr schwacher Teil kann bedeuten, dass Sie nicht bestehen.',
          'Wenn Sie bestehen, bekommen Sie ein Zertifikat mit Ihrem Niveau. Bewahren Sie das Original sicher auf und machen Sie Kopien.',
          'Ämter und Firmen wollen oft das Original oder eine beglaubigte Kopie sehen. Geben Sie Ihr einziges Original niemals weg.',
        ],
      ),
      GuideStep(
        id: 'if_fail',
        icon: Icons.refresh_rounded,
        title: 'Wenn Sie nicht bestehen',
        paragraphs: [
          'Geben Sie nicht auf. Viele Menschen brauchen zwei Versuche.',
          'Sie können die Prüfung wiederholen. Bei telc können Sie oft nur den Teil wiederholen, den Sie nicht bestanden haben, innerhalb eines Jahres. Fragen Sie Ihr Prüfungszentrum, was bei Ihrer Prüfung möglich ist.',
          'Wenn Sie glauben, das Ergebnis ist falsch, können Sie das Institut bitten, Ihr Ergebnis noch einmal zu prüfen. Es gibt eine Frist und manchmal eine Gebühr. Fragen Sie schnell.',
          'Schauen Sie auf Ihre Punkte. Üben Sie den schwachen Teil und melden Sie sich dann wieder an.',
        ],
      ),
    ],
  ),
  GuideTrack(
    id: 'ausbildung',
    icon: Icons.engineering_rounded,
    title: 'Ausbildung aus dem Ausland, Schritt für Schritt',
    subtitle: 'Von Ihrem Plan zu Hause bis zu Ihrem ersten Tag in Deutschland',
    steps: [
      GuideStep(
        id: 'check_yourself',
        icon: Icons.checklist_rounded,
        title: 'Prüfen Sie sich zuerst selbst',
        paragraphs: [
          'Sie brauchen einen Schulabschluss. Für viele Ausbildungsberufe reicht ein Abschluss wie der deutsche Hauptschulabschluss oder Realschulabschluss. Es hängt von der Firma ab.',
          'Es gibt keine feste Altersgrenze für eine Ausbildung. Auch Erwachsene können anfangen.',
          'Wählen Sie einen Bereich, der zu Ihnen passt. Diese Bereiche suchen viele Azubis: Pflege, MFA (Medizinische Fachangestellte), Fachinformatiker, Elektroniker, Mechatroniker, Verkäufer, Koch und Lagerlogistik.',
          'Denken Sie ehrlich nach: Kann ich Deutsch lernen, in Deutschland leben und gleichzeitig in einer Firma arbeiten und in die Schule gehen? Genau das ist eine Ausbildung.',
        ],
      ),
      GuideStep(
        id: 'recognition',
        icon: Icons.verified_rounded,
        title: 'Lassen Sie Ihre Zeugnisse anerkennen',
        paragraphs: [
          'Deutschland muss wissen, was Ihr Schulabschluss wert ist. Das heißt Anerkennung.',
          'Für einen Schulabschluss ist die Zeugnisanerkennungsstelle des Bundeslandes zuständig, in dem Sie Ihre Ausbildung machen wollen. Die richtige Stelle finden Sie mit dem Anerkennungs-Finder auf anerkennung-in-deutschland.de.',
          'Ihr Zeugnis braucht oft einen Stempel des Ministeriums in Ihrem Land und eine beglaubigte Übersetzung ins Deutsche von einem vereidigten Übersetzer.',
          'Fragen Sie, bevor Sie bezahlen: Das Jobcenter oder die Agentur für Arbeit bezahlt manchmal die Übersetzung, wenn die Unterlagen für Arbeit oder eine Ausbildung gebraucht werden.',
        ],
        documents: [
          'Ihr Schulabschluss (Original)',
          'Ein Stempel oder eine Legalisierung des Ministeriums, wenn Ihr Land einen gibt',
          'Eine beglaubigte deutsche Übersetzung Ihres Zeugnisses',
        ],
        links: [
          GuideLink(
            url: 'https://www.anerkennung-in-deutschland.de',
            label: 'Anerkennungs-Finder, offizielle Seite',
          ),
        ],
      ),
      GuideStep(
        id: 'learn_german',
        icon: Icons.translate_rounded,
        title: 'Lernen Sie Deutsch',
        paragraphs: [
          'Für das Ausbildungsvisum brauchen Sie in der Regel Deutsch auf Niveau B1 mit einem Zertifikat. Viele Firmen freuen sich über B2, und für Pflege wird oft B2 gebraucht.',
          'Deutschlernen braucht Zeit. Planen Sie viele Monate Lernen für B1 ein, und mehr Zeit für B2. Fangen Sie jetzt an, in Ihrem Heimatland.',
          'Lernen Sie in einem Kurs und machen Sie am Ende eine Prüfung, damit Sie ein Zertifikat haben. Der Prüfungswegweiser in dieser App zeigt Ihnen den Weg, Schritt für Schritt.',
        ],
        actions: [GuideAction.examGuide],
      ),
      GuideStep(
        id: 'find_place',
        icon: Icons.search_rounded,
        title: 'Finden Sie einen Ausbildungsplatz aus dem Ausland',
        paragraphs: [
          'Die meisten Ausbildungen beginnen im August oder September. Firmen suchen ihre Azubis früh: Bewerben Sie sich 6 bis 12 Monate vor dem Start.',
          'Suchen Sie in dieser App unter Ausbildung, und auf ausbildung.de und in der Stellenbörse der IHK. Lesen Sie die Anzeige gut: Was will die Firma?',
          'Ihre Bewerbung ist ein Lebenslauf und ein Anschreiben auf Deutsch. Diese App baut beides mit Ihnen.',
          'Bewerben Sie sich bei vielen Firmen. Warten Sie nicht auf eine einzige Antwort.',
        ],
        actions: [
          GuideAction.ausbildungSearch,
          GuideAction.cvBuilder,
          GuideAction.coverLetter,
        ],
        links: [
          GuideLink(
            url: 'https://www.ausbildung.de',
            label: 'ausbildung.de, offizielle Suchseite',
          ),
        ],
      ),
      GuideStep(
        id: 'money',
        icon: Icons.euro_rounded,
        title: 'Unterschreiben Sie den Vertrag und prüfen Sie das Geld',
        paragraphs: [
          'Wenn eine Firma Ja sagt, unterschreiben Sie einen Ausbildungsvertrag. Lesen Sie ihn gut: die Vergütung, die Arbeitszeiten, der Urlaub und das Startdatum.',
          'Für das Visum muss Ihr Geld zum Leben reichen. Die Regel für 2026: Mit einer Ausbildungsvergütung von mindestens 822 Euro netto oder 1.048 Euro brutto im Monat gilt Ihr Lebensunterhalt als gesichert.',
          'Eine schulische Ausbildung bezahlt oft kein Gehalt. Dann müssen Sie mindestens 959 Euro netto im Monat zeigen, aus einem Sperrkonto, einem Stipendium oder einer Verpflichtungserklärung.',
          'Wenn Ihre Ausbildungsvergütung niedriger ist als der Betrag oben, müssen Sie den fehlenden Teil anders zeigen, zum Beispiel mit Geld auf einem Sperrkonto oder mit einer Verpflichtungserklärung.',
          'Diese Beträge ändern sich. Prüfen Sie vor Ihrem Visumtermin die neuesten Beträge auf make-it-in-germany.com.',
        ],
        documents: [
          'Ihr Ausbildungsvertrag',
          'Der Nachweis für Ihr Geld: das Gehalt im Vertrag, der Sperrkonto-Nachweis oder die Verpflichtungserklärung',
        ],
        warning:
            'Bezahlen Sie niemals eine Agentur, die Ihnen für viel Geld einen Vertrag oder ein Visum verspricht. Eine echte Firma verkauft ihren Ausbildungsplatz nicht, und Bezahlen macht ein Visum nicht sicher.',
      ),
      GuideStep(
        id: 'visa',
        icon: Icons.flight_takeoff_rounded,
        title: 'Beantragen Sie das Visum',
        paragraphs: [
          'Mit dem unterschriebenen Vertrag beantragen Sie das Visum für die Berufsausbildung (Paragraf 16a Aufenthaltsgesetz) bei der deutschen Botschaft oder dem Konsulat in Ihrem Land. In vielen Ländern starten Sie den Antrag online, im Konsularischen Dienstleistungsportal des Auswärtigen Amts.',
          'Buchen Sie Ihren Termin früh. Die Wartezeiten können lang sein.',
          'Bringen Sie zum Termin alle Unterlagen als Originale mit, mit Kopien. Die Visumgebühr ist 75 Euro, bezahlt in Ihrer Landeswährung.',
          'Sie brauchen auch eine Krankenversicherung für Ihre Reise und Ihren Start in Deutschland. Die Botschaft sagt Ihnen, was sie akzeptiert.',
        ],
        documents: [
          'Ihr Reisepass (gültig)',
          'Der unterschriebene Ausbildungsvertrag',
          'Ihr Schulabschluss mit Anerkennung und beglaubigter Übersetzung',
          'Ihr Deutsch-Zertifikat (B1 oder mehr)',
          'Der Nachweis für Ihr Geld (siehe Schritt davor)',
          'Der Nachweis Ihrer Krankenversicherung',
          'Das Visumantragsformular und Passfotos',
        ],
        warning:
            'Niemand kann Ihnen ein Visum versprechen. Nur die Botschaft entscheidet. Menschen, die ein garantiertes Visum verkaufen, nehmen Ihr Geld und geben Ihnen nichts. In den Gruppen haben Vermittler 9.000 Euro für ein Ausbildungsvisum verlangt. Dieses Geld ist verloren.',
        links: [
          GuideLink(
            url:
                'https://www.make-it-in-germany.com/en/visa-residence/types/training',
            label: 'Make it in Germany, das Ausbildungsvisum',
          ),
        ],
      ),
      GuideStep(
        id: 'arrive',
        icon: Icons.home_rounded,
        title: 'Reisen Sie ein und kommen Sie an',
        paragraphs: [
          'Reisen Sie so, dass Sie vor dem Start Ihrer Ausbildung in Deutschland sind. Ihr Einreisevisum gilt nur kurze Zeit.',
          'In den ersten 14 Tagen nach Ihrem Einzug melden Sie Ihre Adresse beim Bürgerbüro an. Das heißt Anmeldung. Sie bekommen ein Papier (Meldebestätigung). Sie brauchen dieses Papier für alles.',
          'Dann machen Sie einen Termin bei der Ausländerbehörde und beantragen Ihre Aufenthaltserlaubnis für die Ausbildung, bevor Ihr Einreisevisum endet.',
          'Eröffnen Sie ein Bankkonto, damit Ihr Gehalt zu Ihnen kommen kann.',
          'Diese App kann die Briefe für Ihre Termine schreiben. Nutzen Sie die Behördenbriefe.',
        ],
        documents: [
          'Ihr Reisepass mit dem Visum',
          'Ihr Ausbildungsvertrag',
          'Ihre Meldebestätigung (bekommen Sie bei der Anmeldung)',
        ],
        actions: [GuideAction.officialLetters],
      ),
    ],
  ),
];
