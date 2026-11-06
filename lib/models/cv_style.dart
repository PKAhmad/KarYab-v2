// ─────────────────────────────────────────────────────────────────────────────
// Per-CV template customisation (Phase 3).
//
// One [CvCustomisation] belongs to one CV document. It is stored in the
// cv_documents columns Phase 2 reserved (accent_color / font_size / spacing /
// show_photo) and, for the profile-based preview flows that predate
// documents, as a small JSON map in the document-domain key/value store.
//
// The default instance (accent unset, font 'normal', spacing 'normal',
// photo shown) renders EXACTLY like the pre-Phase-3 app: the PDF generator
// treats a null customisation and the default customisation identically.
// ─────────────────────────────────────────────────────────────────────────────

class CvCustomisation {
  /// Hex string like '#1B4CA1', or null for the template's own accent.
  final String? accentColorHex;

  /// 'compact' | 'normal' | 'large'
  final String fontSize;

  /// 'compact' | 'normal'
  final String spacing;

  final bool showPhoto;

  const CvCustomisation({
    this.accentColorHex,
    this.fontSize = 'normal',
    this.spacing = 'normal',
    this.showPhoto = true,
  });

  static const CvCustomisation defaults = CvCustomisation();

  bool get isDefault =>
      accentColorHex == null &&
      fontSize == 'normal' &&
      spacing == 'normal' &&
      showPhoto;

  /// Multiplier applied to body/section font sizes in the PDF generator.
  double get fontScale => switch (fontSize) {
        'compact' => 0.92,
        'large' => 1.09,
        _ => 1.0,
      };

  /// Multiplier applied to vertical section gaps in the PDF generator.
  double get spacingScale => spacing == 'compact' ? 0.78 : 1.0;

  CvCustomisation copyWith({
    String? accentColorHex,
    bool clearAccent = false,
    String? fontSize,
    String? spacing,
    bool? showPhoto,
  }) {
    return CvCustomisation(
      accentColorHex:
          clearAccent ? null : (accentColorHex ?? this.accentColorHex),
      fontSize: fontSize ?? this.fontSize,
      spacing: spacing ?? this.spacing,
      showPhoto: showPhoto ?? this.showPhoto,
    );
  }

  Map<String, dynamic> toMap() => {
        'accentColor': accentColorHex,
        'fontSize': fontSize,
        'spacing': spacing,
        'showPhoto': showPhoto,
      };

  factory CvCustomisation.fromMap(Map<String, dynamic> map) {
    return CvCustomisation(
      accentColorHex: map['accentColor'] as String?,
      fontSize: (map['fontSize'] as String?) ?? 'normal',
      spacing: (map['spacing'] as String?) ?? 'normal',
      showPhoto: (map['showPhoto'] as bool?) ?? true,
    );
  }

  /// Builds a customisation from a cv_documents row's nullable columns
  /// (see DocumentRepository / CvDocumentRecord).
  factory CvCustomisation.fromColumns({
    String? accentColor,
    String? fontSize,
    String? spacing,
    bool? showPhoto,
  }) {
    return CvCustomisation(
      accentColorHex: accentColor,
      fontSize: fontSize ?? 'normal',
      spacing: spacing ?? 'normal',
      showPhoto: showPhoto ?? true,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is CvCustomisation &&
      other.accentColorHex == accentColorHex &&
      other.fontSize == fontSize &&
      other.spacing == spacing &&
      other.showPhoto == showPhoto;

  @override
  int get hashCode => Object.hash(accentColorHex, fontSize, spacing, showPhoto);
}

/// One accent colour the user can pick. All six are dark, print-safe colours
/// (they carry white or dark text in the templates and survive cheap
/// black-and-white printing as a mid grey).
class CvAccentOption {
  final String hex;
  final String labelDe;
  const CvAccentOption(this.hex, this.labelDe);
}

const List<CvAccentOption> kCvAccentPalette = [
  CvAccentOption('#1B4CA1', 'Blau'),
  CvAccentOption('#2E3E50', 'Dunkelblau'),
  CvAccentOption('#6B4226', 'Braun'),
  CvAccentOption('#0E6B5C', 'Grün'),
  CvAccentOption('#7A2230', 'Bordeaux'),
  CvAccentOption('#3C4858', 'Graphit'),
];
