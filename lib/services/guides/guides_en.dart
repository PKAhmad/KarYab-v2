import 'package:flutter/material.dart';

import 'guide_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Guides content, English (Phase 11). The German file is the reference
// for facts; all four languages say the same thing. Figures checked
// November 2026 against make-it-in-germany.com (visa for vocational
// training, figures as of 2026) and anerkennung-in-deutschland.de.
// No em-dashes in any string.
// ─────────────────────────────────────────────────────────────────────────────

const List<GuideTrack> kGuidesEn = [
  GuideTrack(
    id: 'exam',
    icon: Icons.school_rounded,
    title: 'German exam, step by step',
    subtitle: 'From the right exam to your certificate',
    steps: [
      GuideStep(
        id: 'which_exam',
        icon: Icons.help_outline_rounded,
        title: 'Which exam do I need?',
        paragraphs: [
          'There are different German exams. The right exam depends on your goal.',
          'If you live in Germany and take an integration course, your final exam is the DTZ (Deutsch-Test für Zuwanderer). It tests level A2 and B1.',
          'For an Ausbildung you normally need B1. For many jobs and for a B2 course, offices and companies ask for a telc, Goethe or ÖSD certificate at B1 or B2.',
          'For university you need a high level: telc Deutsch C1 Hochschule, the DSH exam, or TestAS with a language certificate. Ask your university which exams it accepts.',
          'Before you pay for an exam, ask the office or the company which certificate it wants. Then you take the right exam one time.',
        ],
      ),
      GuideStep(
        id: 'know_level',
        icon: Icons.speed_rounded,
        title: 'Know your level',
        paragraphs: [
          'Before the exam, find out your level: A1, A2, B1, B2 or C1.',
          'Many language schools give a free placement test (Einstufungstest). The test is short. You read, write and speak a little. You get your level at once.',
          'Important: if your last certificate is older than about 6 months, many schools ask for a new placement test before the next course.',
          'Be honest with yourself. An exam at the right level is easier to pass.',
        ],
        actions: [GuideAction.deutschCourses],
      ),
      GuideStep(
        id: 'register',
        icon: Icons.how_to_reg_rounded,
        title: 'Register the official way',
        paragraphs: [
          'Register only on the official pages of telc, the Goethe-Institut or ÖSD, or at a licensed exam centre.',
          'Exam places are limited and fill up fast. Register early, as soon as you know your exam date.',
          'Pay only the official exam fee. Keep the receipt and the confirmation.',
        ],
        documents: [
          'Your passport or ID card',
          'The exam fee, paid as the centre asks (card or bank transfer)',
        ],
        warning:
            'Never pay a broker or agent who promises you an exam place or a certificate. In Pakistan, brokers charge about 300 dollars for a Goethe B1 registration. The place is not safe, and a bought certificate is worthless and can bring you big problems. Registration is only safe on the official pages.',
        links: [
          GuideLink(
            url: 'https://www.telc.net/en/',
            label: 'telc, official page',
          ),
          GuideLink(
            url: 'https://www.goethe.de/en',
            label: 'Goethe-Institut, official page',
          ),
        ],
      ),
      GuideStep(
        id: 'prepare',
        icon: Icons.menu_book_rounded,
        title: 'Prepare well',
        paragraphs: [
          'Every exam has 4 parts: Lesen (reading), Hören (listening), Schreiben (writing) and Sprechen (speaking).',
          'Practise with model tests (Modelltests). They show you the real tasks and the time. You find them free on the pages of telc, Goethe and ÖSD.',
          'For Schreiben, learn fixed sentences (Redemittel). A clear structure gives good points: a greeting, your point, a reason, and a friendly end.',
          'Books that many learners use: Grammatik Aktiv for grammar, Aspekte as a course book for B1 and B2, and Hören und Sprechen for listening and speaking practice.',
          'Practise speaking out loud every day, best with a partner or in a course.',
        ],
      ),
      GuideStep(
        id: 'exam_day',
        icon: Icons.event_rounded,
        title: 'On the exam day',
        paragraphs: [
          'Come early, as written in your invitation. If you are late, you cannot enter.',
          'Without your passport or ID card you cannot take the exam.',
          'Phones must be off and put away. In most exams you may not use a dictionary.',
          'The exam goes part by part: Lesen, Hören, Schreiben, Sprechen. The speaking part is often in pairs.',
          'Stay calm. If you do not understand a task, ask the examiners before the part starts.',
        ],
        documents: [
          'Passport or ID card',
          'Your invitation or registration confirmation',
        ],
      ),
      GuideStep(
        id: 'results',
        icon: Icons.workspace_premium_rounded,
        title: 'Results and your certificate',
        paragraphs: [
          'Results take time, usually a few weeks. The centre tells you how you get them, often online or by post.',
          'You pass when you reach enough points in every part of the exam. One very weak part can mean that you do not pass.',
          'When you pass, you get a certificate (Zertifikat) with your level. Keep the original safe and make copies.',
          'Offices and companies often want to see the original or a certified copy. Never give away your only original.',
        ],
      ),
      GuideStep(
        id: 'if_fail',
        icon: Icons.refresh_rounded,
        title: 'If you do not pass',
        paragraphs: [
          'Do not give up. Many people need two tries.',
          'You can take the exam again. With telc you can often repeat only the part you failed, within one year. Ask your exam centre what is possible for your exam.',
          'If you think the result is wrong, you can ask the institute to check your result again. There is a deadline, and sometimes a fee. Ask quickly.',
          'Look at your points. Practise the weak part, then register again.',
        ],
      ),
    ],
  ),
  GuideTrack(
    id: 'ausbildung',
    icon: Icons.engineering_rounded,
    title: 'Ausbildung from abroad, step by step',
    subtitle: 'From your plan at home to your first day in Germany',
    steps: [
      GuideStep(
        id: 'check_yourself',
        icon: Icons.checklist_rounded,
        title: 'Check yourself first',
        paragraphs: [
          'You need a school-leaving certificate. For many Ausbildung jobs, a certificate like the German Hauptschulabschluss or Realschulabschluss is enough. It depends on the company.',
          'There is no fixed age limit for an Ausbildung. Adults can also start.',
          'Choose a field that fits you. These fields look for many trainees: Pflege (care), MFA (medical assistant), Fachinformatiker (IT), Elektroniker (electrician), Mechatroniker, Verkäufer (sales), Koch (cook) and Lagerlogistik (warehouse logistics).',
          'Think honestly: can I learn German, live in Germany, and work in a company and go to school at the same time? That is what an Ausbildung is.',
        ],
      ),
      GuideStep(
        id: 'recognition',
        icon: Icons.verified_rounded,
        title: 'Get your certificates recognised',
        paragraphs: [
          'Germany must know what your school certificate is worth. This is called Anerkennung (recognition).',
          'For a school-leaving certificate, the certificate recognition office (Zeugnisanerkennungsstelle) of the German state where you want to train is responsible. You find the right office with the Recognition Finder on anerkennung-in-deutschland.de.',
          'Your certificate often needs a stamp from the ministry in your country, and a certified translation (beglaubigte Übersetzung) into German by a sworn translator.',
          'Ask before you pay: the Jobcenter or the Agentur für Arbeit sometimes pays the translation, when the papers are needed for work or an Ausbildung.',
        ],
        documents: [
          'Your school-leaving certificate (original)',
          'A stamp or legalisation from the ministry, when your country gives one',
          'A certified German translation of your certificate',
        ],
        links: [
          GuideLink(
            url: 'https://www.anerkennung-in-deutschland.de',
            label: 'Recognition Finder, official page',
          ),
        ],
      ),
      GuideStep(
        id: 'learn_german',
        icon: Icons.translate_rounded,
        title: 'Learn German',
        paragraphs: [
          'For the Ausbildung visa you need, as a rule, German level B1 with a certificate. Many companies are happy about B2, and for nursing and care B2 is often needed.',
          'Learning German takes time. Plan many months of learning for B1, and more time for B2. Start now, in your home country.',
          'Learn in a course and take an exam at the end, so you have a certificate. The exam guide in this app shows you the way, step by step.',
        ],
        actions: [GuideAction.examGuide],
      ),
      GuideStep(
        id: 'find_place',
        icon: Icons.search_rounded,
        title: 'Find an Ausbildungsplatz from abroad',
        paragraphs: [
          'Most Ausbildung starts in August or September. Companies look for trainees early: apply 6 to 12 months before the start.',
          'Search in this app under Ausbildung, and on the job board of the IHK. Read the advertisement well: what does the company want?',
          'Your application is a CV (Lebenslauf) and a cover letter (Anschreiben) in German. This app builds both with you.',
          'Apply to many companies. Do not wait for one answer.',
        ],
        actions: [
          GuideAction.ausbildungSearch,
          GuideAction.cvBuilder,
          GuideAction.coverLetter,
        ],
      ),
      GuideStep(
        id: 'money',
        icon: Icons.euro_rounded,
        title: 'Sign the contract and check the money',
        paragraphs: [
          'When a company says yes, you sign a training contract (Ausbildungsvertrag). Read it well: salary (Vergütung), working hours, holidays and the start date.',
          'For the visa, your money must be enough to live on. The rule for 2026: with a training salary of at least €822 net or €1,048 gross per month, your living money counts as secure.',
          'A school-based Ausbildung often pays no salary. Then you must show at least €959 net per month, from a blocked account, a scholarship, or a declaration of commitment (Verpflichtungserklärung).',
          'If your training salary is lower than the amount above, you must show the missing part in another way, for example with money in a blocked account (Sperrkonto) or a declaration of commitment.',
          'These amounts change. Before your visa appointment, check the newest amounts on make-it-in-germany.com.',
        ],
        documents: [
          'Your training contract (Ausbildungsvertrag)',
          'Proof of your money: the salary in the contract, the blocked account paper, or the declaration of commitment',
        ],
        warning:
            'Never pay an agency that promises you a contract or a visa for a lot of money. A real company never sells its Ausbildungsplatz, and paying does not make a visa safe.',
      ),
      GuideStep(
        id: 'visa',
        icon: Icons.flight_takeoff_rounded,
        title: 'Apply for the visa',
        paragraphs: [
          'With the signed contract, you apply for the visa for vocational training (Section 16a of the Residence Act) at the German embassy or consulate in your country. In many countries you start the application online, in the Consular Services Portal of the Foreign Office.',
          'Book your appointment early. Waiting times can be long.',
          'At the appointment, bring all documents as originals, with copies. The visa fee is €75, paid in your local currency.',
          'You also need health insurance for your travel and your start in Germany. The embassy tells you what it accepts.',
        ],
        documents: [
          'Your passport (valid)',
          'The signed training contract',
          'Your school certificate with recognition and certified translation',
          'Your German language certificate (B1 or more)',
          'Proof of your money (see the step before)',
          'Proof of health insurance',
          'The visa application form and passport photos',
        ],
        warning:
            'No person can promise you a visa. Only the embassy decides. People who sell a guaranteed visa take your money and give you nothing. In the groups, brokers asked people for €9,000 for an Ausbildung visa. That money is lost.',
        links: [
          GuideLink(
            url:
                'https://www.make-it-in-germany.com/en/visa-residence/types/training',
            label: 'Make it in Germany, the training visa',
          ),
        ],
      ),
      GuideStep(
        id: 'arrive',
        icon: Icons.home_rounded,
        title: 'Travel and arrive in Germany',
        paragraphs: [
          'Travel so that you are in Germany before your Ausbildung starts. Your entry visa is only valid for a short time.',
          'In the first 14 days after you move in, register your address at the Bürgerbüro. This is called Anmeldung. You get a paper (Meldebestätigung). You need this paper for everything.',
          'Then make an appointment at the Ausländerbehörde and apply for your residence permit for the Ausbildung, before your entry visa ends.',
          'Open a bank account, so your salary can come to you.',
          'This app can write the letters for your appointments. Use Official letters.',
        ],
        documents: [
          'Your passport with the visa',
          'Your training contract',
          'Your Meldebestätigung (you get it at the Anmeldung)',
        ],
        actions: [GuideAction.officialLetters],
      ),
    ],
  ),
];
