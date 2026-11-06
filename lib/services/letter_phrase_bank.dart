// ─────────────────────────────────────────────────────────────────────────────
// Anschreiben phrase bank v2 (Phase 4).
//
// Replaces the v1 approach in cv_pdf_generator.dart, where each section
// had exactly 2 variants and one was picked with Random on every compose,
// so reopening or regenerating a letter silently produced different text.
//
// Here every section has at least 6 variants. Each variant carries:
//   - a tone tag: formal / friendly / confident
//   - sector tags: warehouse, care, gastronomy, retail, cleaning,
//     construction, driving, office, or general (matches every sector)
//   - a German template with {tokens} that are filled ONLY from data the
//     user entered or picked ({jobTitle}, {company}, {skill1}, {skill2},
//     {experience}, {school}, {startDate}, {city}). A variant whose tokens
//     cannot all be filled is never offered - the app invents nothing.
//   - Pashto and Dari translations of the same template (same tokens),
//     used by the editor's "Understand my letter" mode. They are for
//     comprehension only and are never printed.
//
// Recommendation is deterministic scoring (see [scoreLetterPhrase]):
// sector match weighs most, then the user's chosen tone, then how
// specific the filled text is. No randomness anywhere.
// No em-dashes in any phrase (app rule).
// ─────────────────────────────────────────────────────────────────────────────

/// Letter body sections that draw from this bank, in default print order.
/// 'betreff' (subject) is composed deterministically, not from the bank;
/// 'anlagen' is built from the user's document list.
abstract final class LetterSection {
  static const String betreff = 'betreff';
  static const String einleitung = 'einleitung';
  static const String erfahrung = 'erfahrung';
  static const String kenntnisse = 'kenntnisse';
  static const String warum = 'warum';
  static const String verfuegbarkeit = 'verfuegbarkeit';
  static const String schluss = 'schluss';
  static const String anlagen = 'anlagen';

  /// Sections the user may reorder among themselves (Phase 4 item 3).
  static const List<String> reorderable = [erfahrung, kenntnisse, warum];

  /// Sections the user may hide (Phase 4 item 3).
  static const List<String> hideable = [warum, verfuegbarkeit];

  /// Default block order of a new letter.
  static const List<String> defaultOrder = [
    betreff,
    einleitung,
    erfahrung,
    kenntnisse,
    warum,
    verfuegbarkeit,
    schluss,
    anlagen,
  ];
}

abstract final class LetterTone {
  static const String formal = 'formal';
  static const String friendly = 'friendly';
  static const String confident = 'confident';
  static const List<String> all = [formal, friendly, confident];
}

class LetterPhrase {
  final String id;
  final String section;
  final String tone;

  /// Sector keys this variant is written for; 'general' matches any job.
  final List<String> sectors;

  /// German template with {tokens}.
  final String de;

  /// Pashto translation of [de] (same tokens), for Understand mode.
  final String ps;

  /// Dari translation of [de] (same tokens), for Understand mode.
  final String fa;

  const LetterPhrase({
    required this.id,
    required this.section,
    required this.tone,
    required this.sectors,
    required this.de,
    required this.ps,
    required this.fa,
  });

  /// The {tokens} this template needs.
  List<String> get tokens => letterTokensIn(de);

  /// True when every token can be filled from [values].
  bool canFill(Map<String, String> values) =>
      tokens.every((t) => (values[t] ?? '').trim().isNotEmpty);

  /// The German text with tokens replaced by [values]. Callers must check
  /// [canFill] first; unfilled tokens are left as-is so the token guard
  /// can catch them instead of silently printing a broken sentence.
  String fill(Map<String, String> values) => fillLetterTokens(de, values);

  /// Translation template for [lang] ('ps'/'fa'); falls back to German.
  String translationFor(String lang) =>
      lang == 'ps' ? ps : (lang == 'fa' ? fa : de);
}

/// All {token} names occurring in [text].
List<String> letterTokensIn(String text) {
  final found = <String>[];
  for (final m in RegExp(r'\{([a-zA-Z][a-zA-Z0-9]*)\}').allMatches(text)) {
    final t = m.group(1)!;
    if (!found.contains(t)) found.add(t);
  }
  return found;
}

/// Replaces {tokens} in [template] from [values]; unknown tokens stay.
String fillLetterTokens(String template, Map<String, String> values) {
  var out = template;
  for (final t in letterTokensIn(template)) {
    final v = values[t];
    if (v != null && v.trim().isNotEmpty) {
      out = out.replaceAll('{$t}', v.trim());
    }
  }
  return out;
}

/// Unfilled placeholders in a finished letter text: leftover {tokens} or
/// bracketed placeholders like [Position] / [Unternehmen]. The export
/// guard blocks the PDF while any of these remain (CEO rule: documents
/// never ship placeholders).
List<String> findLetterPlaceholders(String text) {
  final found = <String>[];
  for (final m in RegExp(r'\{[a-zA-Z][a-zA-Z0-9]*\}').allMatches(text)) {
    if (!found.contains(m.group(0))) found.add(m.group(0)!);
  }
  for (final m in RegExp(r'\[[^\[\]\n]{1,40}\]').allMatches(text)) {
    if (!found.contains(m.group(0))) found.add(m.group(0)!);
  }
  return found;
}

// ── The bank ────────────────────────────────────────────────────────────────
// 37 phrases: 6 per section, 7 for Kenntnisse (extra warehouse variant).

const List<LetterPhrase> kLetterPhrases = [
  // ── Einleitung ──────────────────────────────────────────────────────────
  LetterPhrase(
    id: 'einleitung_formal_job',
    section: LetterSection.einleitung,
    tone: LetterTone.formal,
    sectors: ['general'],
    de: 'mit großem Interesse habe ich Ihre Stellenausschreibung gelesen und bewerbe mich hiermit um die Stelle als {jobTitle}. Die Aufgaben entsprechen genau meinen Fähigkeiten und meinem beruflichen Ziel.',
    ps: 'ما په ډېرې لېوالتیا سره ستاسو د دندې اعلان ولوست او په دې توګه د {jobTitle} دندې لپاره غوښتنه کوم. دندې په سمه توګه زما له وړتیاوو او مسلکي موخې سره سمون لري.',
    fa: 'با علاقه زیادی آگهی شغلی شما را خواندم و بدین‌وسیله برای سمت {jobTitle} درخواست می‌دهم. وظایف دقیقاً با توانایی‌ها و هدف شغلی من مطابقت دارد.',
  ),
  LetterPhrase(
    id: 'einleitung_formal_anzeige',
    section: LetterSection.einleitung,
    tone: LetterTone.formal,
    sectors: ['general'],
    de: 'bezugnehmend auf Ihre Stellenausschreibung bewerbe ich mich hiermit als {jobTitle} bei {company}. Gern möchte ich meine Kenntnisse und meine Arbeitsweise in Ihr Unternehmen einbringen.',
    ps: 'ستاسو د دندې اعلان ته په اشارې سره زه په دې توګه په {company} کې د {jobTitle} په توګه غوښتنه کوم. زه غواړم خپلې پوهې او کاري طریقې ستاسو شرکت ته راوړم.',
    fa: 'با اشاره به آگهی شغلی شما، بدین‌وسیله به‌عنوان {jobTitle} در {company} درخواست می‌دهم. دوست دارم دانش و شیوه کاری خود را به شرکت شما بیاورم.',
  ),
  LetterPhrase(
    id: 'einleitung_friendly_job',
    section: LetterSection.einleitung,
    tone: LetterTone.friendly,
    sectors: ['general'],
    de: 'Ihre Stellenausschreibung hat mich sofort angesprochen, weil die Stelle als {jobTitle} sehr gut zu mir passt. Deshalb bewerbe ich mich hiermit und freue mich, mich Ihnen vorzustellen.',
    ps: 'ستاسو د دندې اعلان سمدلاسه زما پام ځان ته واړاوه، ځکه چې د {jobTitle} دنده له ما سره ډېر ښه سمون لري. له همدې امله زه غوښتنه کوم او خوښ یم چې ځان دروپېژنم.',
    fa: 'آگهی شغلی شما فوراً توجه مرا جلب کرد، چون سمت {jobTitle} بسیار خوب با من تناسب دارد. به همین دلیل درخواست می‌دهم و خوشحالم که خودم را به شما معرفی کنم.',
  ),
  LetterPhrase(
    id: 'einleitung_friendly_company',
    section: LetterSection.einleitung,
    tone: LetterTone.friendly,
    sectors: ['general'],
    de: 'schon lange verfolge ich die Arbeit von {company} mit Interesse. Umso mehr freue ich mich, mich bei Ihnen als {jobTitle} bewerben zu können.',
    ps: 'له ډېر وخت راهیسې زه د {company} کار په لېوالتیا سره څارم. له همدې امله ډېر خوښ یم چې ستاسو سره د {jobTitle} په توګه غوښتنه کولی شم.',
    fa: 'از مدت‌ها پیش کار {company} را با علاقه دنبال می‌کنم. به همین دلیل بسیار خوشحالم که می‌توانم نزد شما به‌عنوان {jobTitle} درخواست بدهم.',
  ),
  LetterPhrase(
    id: 'einleitung_confident_job',
    section: LetterSection.einleitung,
    tone: LetterTone.confident,
    sectors: ['general'],
    de: 'Sie suchen eine zuverlässige Person als {jobTitle} und ich bringe genau die Motivation und Sorgfalt mit, die diese Aufgabe braucht. Deshalb bewerbe ich mich hiermit bei Ihnen.',
    ps: 'تاسو د {jobTitle} په توګه د باور وړ کس په لټه کې یاست او زه هماغه هڅونه او پاملرنه لرم چې دې دندې ته اړتیا ده. له همدې امله زه تاسو ته غوښتنه کوم.',
    fa: 'شما به دنبال یک فرد قابل اعتماد به‌عنوان {jobTitle} هستید و من دقیقاً همان انگیزه و دقتی را دارم که این کار نیاز دارد. به همین دلیل نزد شما درخواست می‌دهم.',
  ),
  LetterPhrase(
    id: 'einleitung_confident_company',
    section: LetterSection.einleitung,
    tone: LetterTone.confident,
    sectors: ['general'],
    de: 'als {jobTitle} möchte ich bei {company} arbeiten, weil ich dort meine Stärken am besten einsetzen kann. Mit dieser Bewerbung stelle ich mich Ihnen gern persönlich vor.',
    ps: 'زه غواړم په {company} کې د {jobTitle} په توګه کار وکړم، ځکه چې هلته خپل قوتونه په غوره توګه کارولی شم. په دې غوښتنلیک سره زه په خوښۍ ځان تاسو ته پېژنم.',
    fa: 'می‌خواهم به‌عنوان {jobTitle} در {company} کار کنم، چون در آنجا می‌توانم نقاط قوتم را به بهترین شکل به کار بگیرم. با این درخواست با خوشحالی خودم را به شما معرفی می‌کنم.',
  ),

  // ── Erfahrung ───────────────────────────────────────────────────────────
  LetterPhrase(
    id: 'erfahrung_formal_exp',
    section: LetterSection.erfahrung,
    tone: LetterTone.formal,
    sectors: ['general'],
    de: 'Durch meine bisherige Erfahrung als {experience} konnte ich bereits wertvolle praktische Kenntnisse sammeln, die ich gern in die neue Aufgabe einbringen möchte.',
    ps: 'د {experience} په توګه زما د پخوانۍ تجربې له لارې ما ارزښتناکه عملي پوهه ترلاسه کړې ده چې غواړم په نوې دنده کې یې وکاروم.',
    fa: 'از طریق تجربه قبلی‌ام به‌عنوان {experience} توانستم دانش عملی ارزشمندی به دست بیاورم که دوست دارم در کار جدید به کار بگیرم.',
  ),
  LetterPhrase(
    id: 'erfahrung_formal_school',
    section: LetterSection.erfahrung,
    tone: LetterTone.formal,
    sectors: ['general'],
    de: 'Meine schulische Ausbildung an der {school} hat mich gut auf diesen Beruf vorbereitet. Dort habe ich gelernt, sorgfältig und verantwortungsvoll zu arbeiten.',
    ps: 'زما ښوونځي زده کړو په {school} کې زه دې مسلک ته ښه چمتو کړم. هلته مې زده کړل چې په پاملرنې او مسؤلیت سره کار وکړم.',
    fa: 'تحصیلات مدرسه‌ای من در {school} مرا به‌خوبی برای این شغل آماده کرد. در آنجا یاد گرفتم که با دقت و مسئولیت کار کنم.',
  ),
  LetterPhrase(
    id: 'erfahrung_friendly_exp',
    section: LetterSection.erfahrung,
    tone: LetterTone.friendly,
    sectors: ['general'],
    de: 'In meiner bisherigen Arbeit als {experience} habe ich viel gelernt und Freude an dieser Tätigkeit gefunden. Diese Erfahrung möchte ich nun bei Ihnen fortsetzen und ausbauen.',
    ps: 'زما په پخواني کار کې د {experience} په توګه ما ډېر څه زده کړل او له دې کار څخه مې خوند واخیست. زه غواړم دا تجربه اوس ستاسو سره دوام ورکړم او پراخه یې کړم.',
    fa: 'در کار قبلی‌ام به‌عنوان {experience} چیزهای زیادی یاد گرفتم و از این کار لذت بردم. حالا می‌خواهم این تجربه را نزد شما ادامه دهم و گسترش بدهم.',
  ),
  LetterPhrase(
    id: 'erfahrung_friendly_none',
    section: LetterSection.erfahrung,
    tone: LetterTone.friendly,
    sectors: ['general'],
    de: 'Auch wenn ich noch am Anfang meines beruflichen Weges in Deutschland stehe, bringe ich große Motivation und Freude an praktischer Arbeit mit. Ich lerne schnell und arbeite mich gern in neue Aufgaben ein.',
    ps: 'که څه هم زه لا په آلمان کې د خپل مسلکي لارې په پیل کې یم، زه ډېره هڅونه او له عملي کار سره مینه لرم. زه ژر زده کوم او په خوښۍ نوي کارونه زده کوم.',
    fa: 'حتی اگر هنوز در آغاز مسیر شغلی‌ام در آلمان باشم، انگیزه زیادی و علاقه به کار عملی دارم. سریع یاد می‌گیرم و با خوشحالی وظایف جدید را یاد می‌گیرم.',
  ),
  LetterPhrase(
    id: 'erfahrung_confident_exp',
    section: LetterSection.erfahrung,
    tone: LetterTone.confident,
    sectors: ['general'],
    de: 'Als {experience} habe ich bewiesen, dass ich Aufgaben selbstständig, pünktlich und in guter Qualität erledige. Auf diese Erfahrung können Sie sich auch in Ihrem Unternehmen verlassen.',
    ps: 'د {experience} په توګه ما ثابته کړې ده چې زه کارونه په خپلواکه توګه، په وخت او په ښه کیفیت ترسره کوم. تاسو په خپل شرکت کې هم په دې تجربه باور کولی شئ.',
    fa: 'به‌عنوان {experience} ثابت کرده‌ام که وظایف را مستقل، سر وقت و با کیفیت خوب انجام می‌دهم. در شرکت شما هم می‌توانید به این تجربه اعتماد کنید.',
  ),
  LetterPhrase(
    id: 'erfahrung_confident_none',
    section: LetterSection.erfahrung,
    tone: LetterTone.confident,
    sectors: ['general'],
    de: 'Was mir an Berufserfahrung in Deutschland noch fehlt, gleiche ich mit Einsatzbereitschaft, Zuverlässigkeit und schnellem Lernen aus. Geben Sie mir die Chance, das in der Praxis zu zeigen.',
    ps: 'هغه څه چې زه یې په آلمان کې په مسلکي تجربه کې کم لرم، په ژمنتیا، باوريتوب او چټکې زده کړې سره پوره کوم. ماته فرصت راکړئ چې دا په عملي توګه وښیم.',
    fa: 'آنچه را که هنوز در تجربه شغلی در آلمان کم دارم، با آمادگی، قابل اعتماد بودن و یادگیری سریع جبران می‌کنم. به من فرصت بدهید تا این را در عمل نشان دهم.',
  ),

  // ── Kenntnisse und Stärken ──────────────────────────────────────────────
  LetterPhrase(
    id: 'kenntnisse_formal_two',
    section: LetterSection.kenntnisse,
    tone: LetterTone.formal,
    sectors: ['general'],
    de: 'Zu meinen Stärken zählen unter anderem {skill1} und {skill2}. Ich arbeite zuverlässig, sorgfältig und gern im Team und bringe die nötige Motivation mit, mich in neue Aufgaben einzuarbeiten.',
    ps: 'زما په قوتونو کې د نورو په منځ کې {skill1} او {skill2} شامل دي. زه په باوري او پاملرنې سره کار کوم، په ډله کې کار کول خوښوم او اړینه هڅونه لرم چې نوي کارونه زده کړم.',
    fa: 'از نقاط قوت من از جمله {skill1} و {skill2} است. من قابل اعتماد و دقیق کار می‌کنم، کار تیمی را دوست دارم و انگیزه لازم برای یادگیری وظایف جدید را دارم.',
  ),
  LetterPhrase(
    id: 'kenntnisse_formal_one',
    section: LetterSection.kenntnisse,
    tone: LetterTone.formal,
    sectors: ['general'],
    de: 'Besonders im Bereich {skill1} konnte ich bereits gute Erfahrungen sammeln. Dazu kommen Zuverlässigkeit, Pünktlichkeit und eine sorgfältige Arbeitsweise.',
    ps: 'په ځانګړي توګه د {skill1} په برخه کې ما ښه تجربه ترلاسه کړې ده. پر دې سربېره باوريتوب، وخت پابندي او پاملرنې کاري طریقه لرم.',
    fa: 'به‌ویژه در زمینه {skill1} توانستم تجربه خوبی به دست بیاورم. علاوه بر آن، قابل اعتماد بودن، وقت‌شناسی و شیوه کاری دقیق دارم.',
  ),
  LetterPhrase(
    id: 'kenntnisse_friendly_two',
    section: LetterSection.kenntnisse,
    tone: LetterTone.friendly,
    sectors: ['general'],
    de: 'Gern bringe ich meine Kenntnisse in {skill1} und {skill2} in Ihr Team ein. Ich arbeite mich schnell ein, bleibe freundlich im Kontakt mit Kunden und Kollegen und packe überall mit an.',
    ps: 'زه په خوښۍ خپلې پوهې په {skill1} او {skill2} کې ستاسو ډلې ته راوړم. زه ژر کار زده کوم، له پیرودونکو او همکارانو سره دوستانه چلند کوم او هر ځای مرسته کوم.',
    fa: 'با خوشحالی دانشم را در {skill1} و {skill2} به تیم شما می‌آورم. سریع کار را یاد می‌گیرم، در تماس با مشتریان و همکاران دوستانه می‌مانم و همه‌جا کمک می‌کنم.',
  ),
  LetterPhrase(
    id: 'kenntnisse_friendly_none',
    section: LetterSection.kenntnisse,
    tone: LetterTone.friendly,
    sectors: ['general'],
    de: 'Ich bin zuverlässig, freundlich und arbeite gern mit Menschen zusammen. Neue Aufgaben sehe ich als Chance zu lernen, und ich freue mich darauf, Ihr Team zu unterstützen.',
    ps: 'زه باوري، دوستانه یم او له خلکو سره کار کول خوښوم. نوي کارونه د زده کړې فرصت ګڼم، او ستاسو د ډلې ملاتړ ته سترګې په لار یم.',
    fa: 'من قابل اعتماد و دوستانه هستم و کار کردن با مردم را دوست دارم. وظایف جدید را فرصتی برای یادگیری می‌دانم و مشتاقانه منتظر حمایت از تیم شما هستم.',
  ),
  LetterPhrase(
    id: 'kenntnisse_confident_two',
    section: LetterSection.kenntnisse,
    tone: LetterTone.confident,
    sectors: ['general'],
    de: 'Meine Stärken {skill1} und {skill2} bringe ich vom ersten Tag an ein. Ich übernehme Verantwortung, halte Termine ein und liefere saubere Arbeit ab.',
    ps: 'زما قوتونه {skill1} او {skill2} له لومړۍ ورځې څخه راوړم. زه مسؤلیت اخلم، وختونه ساتم او پاک کار وړاندې کوم.',
    fa: 'نقاط قوتم {skill1} و {skill2} را از روز اول به کار می‌گیرم. مسئولیت می‌پذیرم، به مهلت‌ها پایبندم و کار تمیز تحویل می‌دهم.',
  ),
  LetterPhrase(
    id: 'kenntnisse_confident_one',
    section: LetterSection.kenntnisse,
    tone: LetterTone.confident,
    sectors: ['general'],
    de: 'Wer mich einstellt, bekommt eine Person, die {skill1} sicher beherrscht und auch unter Zeitdruck ruhig und genau arbeitet.',
    ps: 'څوک چې ما وګوماري، داسې کس ترلاسه کوي چې په {skill1} کې ډاډه مهارت لري او د وخت تر فشار لاندې هم په ارامۍ او دقت سره کار کوي.',
    fa: 'کسی که مرا استخدام کند، فردی را به دست می‌آورد که در {skill1} مهارت مطمئن دارد و تحت فشار زمانی هم آرام و دقیق کار می‌کند.',
  ),
  LetterPhrase(
    id: 'kenntnisse_warehouse',
    section: LetterSection.kenntnisse,
    tone: LetterTone.formal,
    sectors: ['warehouse'],
    de: 'Im Lager bringe ich praktische Erfahrung in {skill1} mit. Kommissionieren, Sortieren und ein sicherer Umgang mit Ware sind für mich selbstverständlich.',
    ps: 'په ګودام کې زه په {skill1} کې عملي تجربه لرم. د مالونو برابرول، جلا کول او خوندي چلند زما لپاره عادي خبره ده.',
    fa: 'در انبار در {skill1} تجربه عملی دارم. آماده‌سازی سفارش، مرتب‌سازی و برخورد ایمن با کالا برای من امری بدیهی است.',
  ),

  // ── Warum diese Firma ───────────────────────────────────────────────────
  LetterPhrase(
    id: 'warum_formal_company',
    section: LetterSection.warum,
    tone: LetterTone.formal,
    sectors: ['general'],
    de: 'Ich bewerbe mich bei {company}, weil Ihr Unternehmen für Qualität und Verlässlichkeit steht. Gern möchte ich mit meiner Arbeit zu Ihrem Erfolg beitragen.',
    ps: 'زه په {company} کې غوښتنه کوم، ځکه چې ستاسو شرکت د کیفیت او باوريتوب لپاره ولاړ دی. زه غواړم په خپل کار سره ستاسو بریا ته ونډه ورکړم.',
    fa: 'نزد {company} درخواست می‌دهم، چون شرکت شما نماد کیفیت و قابل اعتماد بودن است. دوست دارم با کارم در موفقیت شما سهم داشته باشم.',
  ),
  LetterPhrase(
    id: 'warum_formal_growth',
    section: LetterSection.warum,
    tone: LetterTone.formal,
    sectors: ['general'],
    de: 'Ich suche eine Aufgabe mit Perspektive, bei der ich mich weiterentwickeln und langfristig einbringen kann. Ihr Unternehmen bietet dafür gute Möglichkeiten.',
    ps: 'زه د راتلونکې لرونکې دندې په لټه کې یم چې پکې پرمختګ وکړم او اوږدمهاله ونډه واخلم. ستاسو شرکت د دې لپاره ښه امکانات وړاندې کوي.',
    fa: 'به دنبال کاری با آینده هستم که در آن پیشرفت کنم و درازمدت سهم بگیرم. شرکت شما برای این کار امکانات خوبی ارائه می‌دهد.',
  ),
  LetterPhrase(
    id: 'warum_friendly_near',
    section: LetterSection.warum,
    tone: LetterTone.friendly,
    sectors: ['general'],
    de: 'Da ich in {city} lebe, ist Ihr Unternehmen für mich sehr gut erreichbar. Kurze Wege sind auch für Sie ein Vorteil, denn ich bin pünktlich und flexibel einsetzbar.',
    ps: 'څرنګه چې زه په {city} کې اوسېږم، ستاسو شرکت زما لپاره ډېر ښه رسېدونکی دی. لنډې لارې ستاسو لپاره هم ګټه ده، ځکه چې زه پر وخت او په انعطاف سره کار کولی شم.',
    fa: 'از آنجا که در {city} زندگی می‌کنم، شرکت شما برای من بسیار خوب در دسترس است. مسیر کوتاه برای شما هم یک مزیت است، چون من وقت‌شناس و انعطاف‌پذیر هستم.',
  ),
  LetterPhrase(
    id: 'warum_friendly_company',
    section: LetterSection.warum,
    tone: LetterTone.friendly,
    sectors: ['general'],
    de: 'Von Freunden und Bekannten habe ich viel Gutes über {company} gehört. In einem solchen Team zu arbeiten, würde mir große Freude machen.',
    ps: 'له ملګرو او پېژندګلو څخه مې د {company} په اړه ډېر ښه شیان اورېدلي دي. په داسې ډله کې کار کول به ما ته ډېره خوښي راکړي.',
    fa: 'از دوستان و آشنایان درباره {company} چیزهای خوب زیادی شنیده‌ام. کار کردن در چنین تیمی برای من بسیار لذت‌بخش خواهد بود.',
  ),
  LetterPhrase(
    id: 'warum_confident_fit',
    section: LetterSection.warum,
    tone: LetterTone.confident,
    sectors: ['general'],
    de: 'Bei {company} sehe ich die besten Möglichkeiten, meine Fähigkeiten sinnvoll einzusetzen und mich weiterzuentwickeln. Darum fällt meine Wahl bewusst auf Ihr Unternehmen.',
    ps: 'په {company} کې زه غوره امکانات وینم چې خپلې وړتیاوې په ګټوره توګه وکاروم او پرمختګ وکړم. له همدې امله زما انتخاب په شعوري توګه ستاسو شرکت دی.',
    fa: 'در {company} بهترین امکانات را می‌بینم تا توانایی‌هایم را به‌طور مفید به کار بگیرم و پیشرفت کنم. به همین دلیل انتخاب من آگاهانه شرکت شما است.',
  ),
  LetterPhrase(
    id: 'warum_confident_training',
    section: LetterSection.warum,
    tone: LetterTone.confident,
    sectors: ['general'],
    de: 'Ihr Unternehmen bildet aus und gibt jungen Menschen eine echte Chance. Diese Haltung überzeugt mich, und ich möchte meinen beruflichen Weg bei Ihnen beginnen.',
    ps: 'ستاسو شرکت روزنه ورکوي او ځوانانو ته رښتینی فرصت ورکوي. دا چلند ما قانع کوي، او زه غواړم خپله مسلکي لاره ستاسو سره پیل کړم.',
    fa: 'شرکت شما آموزش می‌دهد و به جوانان فرصت واقعی می‌دهد. این رویکرد مرا قانع می‌کند و می‌خواهم مسیر شغلی‌ام را نزد شما شروع کنم.',
  ),

  // ── Verfügbarkeit ───────────────────────────────────────────────────────
  LetterPhrase(
    id: 'verfuegbarkeit_formal_now',
    section: LetterSection.verfuegbarkeit,
    tone: LetterTone.formal,
    sectors: ['general'],
    de: 'Ein Eintritt ist für mich ab sofort möglich. Auch die Arbeit im Schichtdienst sowie an Wochenenden und Feiertagen ist für mich selbstverständlich.',
    ps: 'زما لپاره له همدا اوس څخه پیل ممکن دی. په شفټونو کې کار او همدارنګه د اونۍ په پای او رخصتیو کې کار زما لپاره عادي خبره ده.',
    fa: 'شروع کار برای من از همین حالا ممکن است. کار در شیفت‌ها و همچنین در آخر هفته‌ها و تعطیلات برای من امری بدیهی است.',
  ),
  LetterPhrase(
    id: 'verfuegbarkeit_formal_date',
    section: LetterSection.verfuegbarkeit,
    tone: LetterTone.formal,
    sectors: ['general'],
    de: 'Gern stehe ich Ihnen ab dem {startDate} zur Verfügung. Über eine Einladung zu einem persönlichen Gespräch freue ich mich sehr.',
    ps: 'زه په خوښۍ له {startDate} څخه ستاسو په خدمت کې یم. د شخصي مرکې بلنې ته به ډېر خوشحاله شم.',
    fa: 'با خوشحالی از {startDate} در خدمت شما هستم. از دعوت به یک گفت‌وگوی حضوری بسیار خوشحال می‌شوم.',
  ),
  LetterPhrase(
    id: 'verfuegbarkeit_friendly_now',
    section: LetterSection.verfuegbarkeit,
    tone: LetterTone.friendly,
    sectors: ['general'],
    de: 'Ich kann ab sofort bei Ihnen anfangen und bin zeitlich flexibel. Auch ein kurzes Probearbeiten ist für mich gern möglich.',
    ps: 'زه له همدا اوس څخه ستاسو سره پیل کولی شم او په وخت کې انعطاف لرم. لنډ ازمېښتي کار هم زما لپاره په خوښۍ ممکن دی.',
    fa: 'می‌توانم از همین حالا نزد شما شروع کنم و از نظر زمانی انعطاف‌پذیر هستم. یک کار آزمایشی کوتاه هم با خوشحالی برای من ممکن است.',
  ),
  LetterPhrase(
    id: 'verfuegbarkeit_friendly_date',
    section: LetterSection.verfuegbarkeit,
    tone: LetterTone.friendly,
    sectors: ['general'],
    de: 'Ab dem {startDate} kann ich bei Ihnen starten. Bis dahin bereite ich mich gut vor, damit ich von Anfang an richtig mithelfen kann.',
    ps: 'له {startDate} څخه زه ستاسو سره پیل کولی شم. تر هغه وخته ښه چمتووالی نیسم، ترڅو له پیل څخه سمه مرسته وکړم.',
    fa: 'از {startDate} می‌توانم نزد شما شروع کنم. تا آن زمان خوب آماده می‌شوم تا از ابتدا درست کمک کنم.',
  ),
  LetterPhrase(
    id: 'verfuegbarkeit_confident_now',
    section: LetterSection.verfuegbarkeit,
    tone: LetterTone.confident,
    sectors: ['general'],
    de: 'Ich bin ab sofort verfügbar und kann auch kurzfristig einspringen, wenn bei Ihnen jemand ausfällt. Auf mich ist Verlass, wenn es schnell gehen muss.',
    ps: 'زه له همدا اوس څخه چمتو یم او په لنډ وخت کې هم راتلی شم، که ستاسو څوک نه وي. کله چې ژر کار وي، په ما باور کیدی شي.',
    fa: 'من از همین حالا آماده‌ام و در کوتاه‌مدت هم می‌توانم جای خالی را پر کنم، اگر کسی از شما غایب باشد. وقتی کار فوری است، می‌توان روی من حساب کرد.',
  ),
  LetterPhrase(
    id: 'verfuegbarkeit_confident_trial',
    section: LetterSection.verfuegbarkeit,
    tone: LetterTone.confident,
    sectors: ['general'],
    de: 'Überzeugen Sie sich gern selbst von meiner Arbeitsweise und laden Sie mich zu einem Probearbeiten ein. Ich bin bereit, sofort zu beginnen.',
    ps: 'په خوښۍ زما د کار له طریقې څخه پخپله ډاډ ترلاسه کړئ او ما ازمېښتي کار ته راوبلئ. زه چمتو یم چې سمدلاسه پیل وکړم.',
    fa: 'با خوشحالی خودتان از شیوه کار من مطمئن شوید و مرا به یک کار آزمایشی دعوت کنید. آماده‌ام فوراً شروع کنم.',
  ),

  // ── Schluss ─────────────────────────────────────────────────────────────
  LetterPhrase(
    id: 'schluss_formal_interview',
    section: LetterSection.schluss,
    tone: LetterTone.formal,
    sectors: ['general'],
    de: 'Über eine Einladung zu einem persönlichen Vorstellungsgespräch freue ich mich sehr. Für Rückfragen stehe ich Ihnen jederzeit gern zur Verfügung.',
    ps: 'د شخصي مرکې بلنې ته به ډېر خوشحاله شم. د پوښتنو لپاره هر وخت ستاسو په خدمت کې یم.',
    fa: 'از دعوت به یک مصاحبه حضوری بسیار خوشحال می‌شوم. برای پرسش‌ها هر زمان با خوشحالی در خدمت شما هستم.',
  ),
  LetterPhrase(
    id: 'schluss_formal_documents',
    section: LetterSection.schluss,
    tone: LetterTone.formal,
    sectors: ['general'],
    de: 'Meine vollständigen Unterlagen finden Sie im Anhang. Gern stelle ich mich Ihnen in einem persönlichen Gespräch näher vor.',
    ps: 'زما بشپړ اسناد په ضمیمه کې موندلی شئ. په خوښۍ به په شخصي مرکه کې ځان نور هم دروپېژنم.',
    fa: 'مدارک کامل مرا در پیوست پیدا می‌کنید. با خوشحالی در یک گفت‌وگوی حضوری خودم را بیشتر معرفی می‌کنم.',
  ),
  LetterPhrase(
    id: 'schluss_friendly_interview',
    section: LetterSection.schluss,
    tone: LetterTone.friendly,
    sectors: ['general'],
    de: 'Ich würde mich sehr freuen, Sie in einem persönlichen Gespräch kennenzulernen und mehr über die Aufgabe zu erfahren.',
    ps: 'زه به ډېر خوشحاله شم چې په شخصي مرکه کې مو وپېژنم او د دندې په اړه نور معلومات ترلاسه کړم.',
    fa: 'بسیار خوشحال می‌شوم که در یک گفت‌وگوی حضوری با شما آشنا شوم و درباره کار بیشتر بدانم.',
  ),
  LetterPhrase(
    id: 'schluss_friendly_thanks',
    section: LetterSection.schluss,
    tone: LetterTone.friendly,
    sectors: ['general'],
    de: 'Vielen Dank, dass Sie sich Zeit für meine Bewerbung nehmen. Ich freue mich auf Ihre Rückmeldung und ein mögliches Kennenlernen.',
    ps: 'ډېره مننه چې زما غوښتنلیک ته مو وخت ورکړ. ستاسو ځواب او ممکنه پېژندګلوۍ ته سترګې په لار یم.',
    fa: 'بسیار سپاسگزارم که برای درخواست من وقت می‌گذارید. منتظر پاسخ شما و آشنایی احتمالی هستم.',
  ),
  LetterPhrase(
    id: 'schluss_confident_interview',
    section: LetterSection.schluss,
    tone: LetterTone.confident,
    sectors: ['general'],
    de: 'Ich bin sicher, dass ich gut in Ihr Team passe, und freue mich darauf, das in einem persönlichen Gespräch zu zeigen.',
    ps: 'زه ډاډه یم چې ستاسو ډلې ته ښه مناسب یم، او سترګې په لار یم چې دا په شخصي مرکه کې وښیم.',
    fa: 'مطمئن هستم که به‌خوبی با تیم شما تناسب دارم و منتظرم این را در یک گفت‌وگوی حضوری نشان دهم.',
  ),
  LetterPhrase(
    id: 'schluss_confident_ready',
    section: LetterSection.schluss,
    tone: LetterTone.confident,
    sectors: ['general'],
    de: 'Geben Sie mir die Gelegenheit, Sie in einem Gespräch und im Probearbeiten von mir zu überzeugen. Ich freue mich auf Ihre Antwort.',
    ps: 'ماته فرصت راکړئ چې په مرکه او ازمېښتي کار کې مو قانع کړم. ستاسو ځواب ته سترګې په لار یم.',
    fa: 'به من فرصت بدهید تا در گفت‌وگو و کار آزمایشی شما را متقاعد کنم. منتظر پاسخ شما هستم.',
  ),
];

// ── Recommendation scoring ────────────────────────────────────────────────
// Deterministic: the same context always produces the same ranking. A
// sector match weighs most (the phrase was written for this kind of job),
// then the tone the user chose, then specificity (phrases that use more of
// the user's own data rank above generic ones). Bank order breaks ties,
// so results are stable across runs and devices.

class LetterRecommendation {
  final LetterPhrase phrase;
  final int score;

  /// Why this phrase won: 'sector', 'tone', 'specific' or 'general'.
  final String reasonKey;

  /// The matched sector key when [reasonKey] is 'sector', else ''.
  final String reasonValue;

  const LetterRecommendation({
    required this.phrase,
    required this.score,
    required this.reasonKey,
    required this.reasonValue,
  });
}

int scoreLetterPhrase(
  LetterPhrase phrase, {
  required Map<String, String> values,
  required String sectorHint,
  required String tone,
}) {
  var score = 0;
  if (sectorHint != 'general' && phrase.sectors.contains(sectorHint)) {
    score += 100;
  }
  if (phrase.sectors.contains('general')) score += 10;
  if (phrase.tone == tone) score += 40;
  score += phrase.tokens.length * 5;
  return score;
}

LetterRecommendation _recommendationFor(
  LetterPhrase phrase,
  int score, {
  required String sectorHint,
  required String tone,
}) {
  if (sectorHint != 'general' && phrase.sectors.contains(sectorHint)) {
    return LetterRecommendation(
      phrase: phrase,
      score: score,
      reasonKey: 'sector',
      reasonValue: sectorHint,
    );
  }
  if (phrase.tone == tone) {
    return LetterRecommendation(
      phrase: phrase,
      score: score,
      reasonKey: 'tone',
      reasonValue: tone,
    );
  }
  if (phrase.tokens.isNotEmpty) {
    return LetterRecommendation(
      phrase: phrase,
      score: score,
      reasonKey: 'specific',
      reasonValue: '',
    );
  }
  return LetterRecommendation(
    phrase: phrase,
    score: score,
    reasonKey: 'general',
    reasonValue: '',
  );
}

/// All phrases of [section] that can be filled from [values], best first.
/// Phrases with unfillable tokens are never offered (nothing is invented).
List<LetterRecommendation> rankLetterPhrases(
  String section, {
  required Map<String, String> values,
  required String sectorHint,
  required String tone,
}) {
  final candidates = <({int index, LetterRecommendation rec})>[];
  var index = 0;
  for (final phrase in kLetterPhrases) {
    if (phrase.section == section && phrase.canFill(values)) {
      final score = scoreLetterPhrase(
        phrase,
        values: values,
        sectorHint: sectorHint,
        tone: tone,
      );
      candidates.add((
        index: index,
        rec: _recommendationFor(
          phrase,
          score,
          sectorHint: sectorHint,
          tone: tone,
        ),
      ));
    }
    index++;
  }
  candidates.sort((a, b) {
    final byScore = b.rec.score.compareTo(a.rec.score);
    return byScore != 0 ? byScore : a.index.compareTo(b.index);
  });
  return [for (final c in candidates) c.rec];
}

/// Looks up one bank phrase by id (null when unknown).
LetterPhrase? letterPhraseById(String? id) {
  if (id == null) return null;
  for (final p in kLetterPhrases) {
    if (p.id == id) return p;
  }
  return null;
}
