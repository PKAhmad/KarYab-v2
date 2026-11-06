import 'dart:convert';
import 'dart:typed_data';

// ─────────────────────────────────────────────────────────────────────────────
// Minimal, conservative PDF merger (Phase 4, Bewerbungsmappe).
//
// The `pdf` package writes documents but cannot merge finished PDFs, and
// no merge package is in the dependency set. This merger therefore works
// at the object level: it scans each input for its indirect objects,
// renumbers them into one shared space, rewrites the references in the
// object dictionaries (stream bytes are copied untouched, so /Length
// stays valid), flattens every source page tree under one new /Pages
// root, and writes a fresh document with a classic xref table.
//
// It DELIBERATELY supports only PDFs whose structure it fully
// understands (the shape the `pdf` package produces: plain indirect
// objects, inline /Kids arrays, direct /Length streams). Anything else
// (object streams, indirect stream lengths, missing page tree) makes it
// return null, and the caller treats that part as not embeddable instead
// of shipping a broken file.
// ─────────────────────────────────────────────────────────────────────────────

class _PdfObject {
  final int number;

  /// Dictionary/header part of the object (references are rewritten here).
  final String dictText;

  /// Raw stream bytes, null for non-stream objects.
  final Uint8List? streamBytes;

  _PdfObject(this.number, this.dictText, this.streamBytes);
}

class _ParsedPdf {
  final List<_PdfObject> objects;
  final Map<int, _PdfObject> byNumber;

  /// Leaf page object numbers in document order.
  final List<int> pageNumbers;

  /// Object numbers of the source catalogue / page-tree nodes (skipped
  /// when copying; references to them are rewired to the new root).
  final Set<int> treeNumbers;

  /// Inherited page attributes (e.g. /MediaBox) per page number, gathered
  /// from its page-tree ancestors, for pages that do not carry their own.
  final Map<int, Map<String, String>> inheritedByPage;

  _ParsedPdf(
    this.objects,
    this.byNumber,
    this.pageNumbers,
    this.treeNumbers,
    this.inheritedByPage,
  );
}

final RegExp _objectHeader = RegExp(r'(\d+)\s+(\d+)\s+obj(?![\w])');
final RegExp _refPattern = RegExp(r'(\d+)\s+(\d+)\s+R(?![\w])');
final RegExp _typePattern = RegExp(r'/Type\s*/([A-Za-z]+)');

_ParsedPdf? _parsePdf(Uint8List bytes) {
  final text = latin1.decode(bytes);
  if (!text.startsWith('%PDF-')) return null;
  if (text.contains('/ObjStm')) return null; // object streams: unsupported

  final objects = <_PdfObject>[];
  final byNumber = <int, _PdfObject>{};
  var searchFrom = 0;
  while (true) {
    final m = _objectHeader.firstMatch(text.substring(searchFrom));
    if (m == null) break;
    final number = int.parse(m.group(1)!);
    final bodyStart = searchFrom + m.end;
    final rest = text.substring(bodyStart);
    final endobjAt = rest.indexOf('endobj');
    if (endobjAt < 0) return null;
    // Stream object? A 'stream' keyword followed by an EOL, before endobj.
    final streamMatch = RegExp(r'stream(\r\n|\n|\r)').firstMatch(rest);
    _PdfObject obj;
    if (streamMatch != null && streamMatch.start < endobjAt) {
      final dictText = rest.substring(0, streamMatch.start);
      final lengthMatch = RegExp(r'/Length\s+(\d+)').firstMatch(dictText);
      if (lengthMatch == null) return null; // indirect length: unsupported
      final streamLength = int.parse(lengthMatch.group(1)!);
      final dataStart = bodyStart + streamMatch.end;
      final dataEnd = dataStart + streamLength;
      if (dataEnd > bytes.length) return null;
      final streamBytes = Uint8List.sublistView(bytes, dataStart, dataEnd);
      // The object must close with endstream after the stream data.
      final tail = text.substring(
        dataEnd,
        dataEnd + 24 > text.length ? text.length : dataEnd + 24,
      );
      if (!tail.contains('endstream')) return null;
      obj = _PdfObject(number, dictText.trim(), streamBytes);
      searchFrom = text.indexOf('endobj', dataEnd) + 'endobj'.length;
      if (searchFrom < 'endobj'.length) return null;
    } else {
      obj = _PdfObject(number, rest.substring(0, endobjAt).trim(), null);
      searchFrom = bodyStart + endobjAt + 'endobj'.length;
    }
    if (byNumber.containsKey(number)) return null; // duplicate: suspicious
    objects.add(obj);
    byNumber[number] = obj;
  }
  if (objects.isEmpty) return null;

  // Locate the catalogue and its /Pages root.
  _PdfObject? catalog;
  int? pagesRoot;
  for (final o in objects) {
    if (_typePattern.firstMatch(o.dictText)?.group(1) == 'Catalog') {
      catalog = o;
      final pagesRef = RegExp(
        r'/Pages\s+(\d+)\s+(\d+)\s+R',
      ).firstMatch(o.dictText);
      if (pagesRef != null) pagesRoot = int.parse(pagesRef.group(1)!);
      break;
    }
  }
  if (catalog == null || pagesRoot == null) return null;
  if (!byNumber.containsKey(pagesRoot)) return null;

  final treeNumbers = <int>{catalog.number};
  final pageNumbers = <int>[];
  final inheritedByPage = <int, Map<String, String>>{};

  Map<String, String> pageTreeAttrs(String dictText) {
    final attrs = <String, String>{};
    for (final key in const ['MediaBox', 'CropBox', 'Rotate']) {
      final m = RegExp('/$key\\s+(\\[[^\\]]*\\]|\\d+)').firstMatch(dictText);
      if (m != null) attrs[key] = '/$key ${m.group(1)}';
    }
    return attrs;
  }

  bool walk(int number, Map<String, String> inherited) {
    final node = byNumber[number];
    if (node == null) return false;
    final type = _typePattern.firstMatch(node.dictText)?.group(1);
    if (type == 'Page') {
      pageNumbers.add(number);
      inheritedByPage[number] = inherited;
      return true;
    }
    if (type != 'Pages') return false;
    treeNumbers.add(number);
    final merged = {...inherited, ...pageTreeAttrs(node.dictText)};
    final kidsMatch = RegExp(r'/Kids\s*\[([^\]]*)\]').firstMatch(node.dictText);
    if (kidsMatch == null) return false;
    final kids = _refPattern
        .allMatches(kidsMatch.group(1)!)
        .map((m) => int.parse(m.group(1)!))
        .toList();
    if (kids.isEmpty) return false;
    for (final kid in kids) {
      if (!walk(kid, merged)) return false;
    }
    return true;
  }

  if (!walk(pagesRoot, const {})) return null;
  if (pageNumbers.isEmpty) return null;
  treeNumbers.add(pagesRoot);
  return _ParsedPdf(
    objects,
    byNumber,
    pageNumbers,
    treeNumbers,
    inheritedByPage,
  );
}

String _rewriteRefs(String dictText, Map<int, int> numberMap) {
  return dictText.replaceAllMapped(_refPattern, (m) {
    final old = int.parse(m.group(1)!);
    final mapped = numberMap[old];
    if (mapped == null) return m.group(0)!;
    return '$mapped 0 R';
  });
}

/// Merges [parts] into one PDF, pages in the order the parts are given.
/// Returns null when any part has a structure this merger does not
/// support; callers then fall back to embedding fewer parts.
Uint8List? mergePdfDocuments(List<Uint8List> parts, {String? title}) {
  if (parts.isEmpty) return null;
  final parsed = <_ParsedPdf>[];
  for (final part in parts) {
    final p = _parsePdf(part);
    if (p == null) return null;
    parsed.add(p);
  }

  // New numbering: 1 = catalogue, 2 = shared /Pages root, 3 = info.
  const catalogNumber = 1;
  const pagesRootNumber = 2;
  const infoNumber = 3;
  var nextNumber = 4;
  final bodies = <int, _PdfObject>{};
  final newPageNumbers = <int>[];

  for (final doc in parsed) {
    final numberMap = <int, int>{};
    for (final treeNum in doc.treeNumbers) {
      numberMap[treeNum] = pagesRootNumber;
    }
    final sorted = [...doc.objects]
      ..sort((a, b) => a.number.compareTo(b.number));
    for (final obj in sorted) {
      if (doc.treeNumbers.contains(obj.number)) continue;
      if (_typePattern.firstMatch(obj.dictText)?.group(1) == 'XRef') {
        continue; // the source cross-reference stream is not copied
      }
      numberMap[obj.number] = nextNumber++;
    }
    for (final obj in sorted) {
      if (doc.treeNumbers.contains(obj.number)) continue;
      final newNumber = numberMap[obj.number];
      if (newNumber == null) continue;
      var dictText = _rewriteRefs(obj.dictText, numberMap);
      final isPage = _typePattern.firstMatch(obj.dictText)?.group(1) == 'Page';
      if (isPage) {
        // Rewire the parent to the shared root (the rewrite above already
        // maps tree numbers to it, this also covers indirect parents).
        dictText = dictText.replaceAllMapped(
          RegExp(r'/Parent\s+\d+\s+\d+\s+R'),
          (_) => '/Parent $pagesRootNumber 0 R',
        );
        // Supply inherited attributes the page itself lacks.
        final inherited = doc.inheritedByPage[obj.number] ?? const {};
        final inject = <String>[];
        for (final e in inherited.entries) {
          if (!dictText.contains('/${e.key}')) inject.add(e.value);
        }
        if (inject.isNotEmpty && dictText.startsWith('<<')) {
          dictText = '<<${inject.join(' ')} ${dictText.substring(2)}';
        }
        newPageNumbers.add(newNumber);
      }
      bodies[newNumber] = _PdfObject(newNumber, dictText, obj.streamBytes);
    }
  }
  if (newPageNumbers.isEmpty) return null;

  final out = BytesBuilder();
  final offsets = <int, int>{};
  void writeText(String s) => out.add(latin1.encode(s));

  writeText('%PDF-1.4\n');
  out.add(Uint8List.fromList([0x25, 0xE2, 0xE3, 0xCF, 0xD3, 0x0A]));

  void writeObject(int number, String dictText, Uint8List? streamBytes) {
    offsets[number] = out.length;
    writeText('$number 0 obj\n');
    writeText(dictText);
    if (streamBytes != null) {
      writeText('\nstream\n');
      out.add(streamBytes);
      writeText('\nendstream');
    }
    writeText('\nendobj\n');
  }

  writeObject(
    catalogNumber,
    '<< /Type /Catalog /Pages $pagesRootNumber 0 R >>',
    null,
  );
  writeObject(
    pagesRootNumber,
    '<< /Type /Pages /Kids [${newPageNumbers.map((n) => '$n 0 R').join(' ')}] '
    '/Count ${newPageNumbers.length} >>',
    null,
  );
  final safeTitle = (title ?? 'Bewerbung')
      .replaceAll('\\', '')
      .replaceAll('(', '')
      .replaceAll(')', '');
  writeObject(infoNumber, '<< /Title ($safeTitle) /Producer (KarYab) >>', null);
  final sortedNumbers = bodies.keys.toList()..sort();
  for (final n in sortedNumbers) {
    final obj = bodies[n]!;
    writeObject(n, obj.dictText, obj.streamBytes);
  }

  final size = nextNumber;
  final xrefOffset = out.length;
  final xref = StringBuffer('xref\n0 $size\n');
  xref.write('0000000000 65535 f \n');
  for (var i = 1; i < size; i++) {
    final off = offsets[i];
    if (off == null) return null;
    xref.write('${off.toString().padLeft(10, '0')} 00000 n \n');
  }
  writeText(xref.toString());
  writeText(
    'trailer\n<< /Size $size /Root $catalogNumber 0 R '
    '/Info $infoNumber 0 R >>\nstartxref\n$xrefOffset\n%%EOF',
  );
  return out.toBytes();
}
