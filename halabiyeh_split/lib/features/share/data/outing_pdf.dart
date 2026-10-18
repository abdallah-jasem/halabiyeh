import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../bill/domain/entities/outing.dart';
import '../../bill/domain/usecases/calculate_balances.dart';
import '../../bill/domain/usecases/settle_up.dart';
import '../domain/format_outing_summary.dart';

/// Renders the balance sheet and settlement as a PDF. Infra detail (pdf
/// package): domain data in, bytes out. Arabic needs the bundled font or it
/// renders as boxes.
Future<Uint8List> buildOutingPdf(Outing outing, ShareLabels l, {bool rtl = false}) async {
  final balances = calculateBalances(outing);
  final transfers = settleUp(balances);
  final nameFor = {for (final m in outing.members) m.id: m.name};
  final arabic = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSansArabic-Regular.ttf'));
  final arabicBold = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSansArabic-Bold.ttf'));
  final doc = pw.Document(
    theme: pw.ThemeData.withFont(base: arabic, bold: arabicBold, fontFallback: [pw.Font.helvetica()]),
  );

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      textDirection: rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(outing.title, style: const pw.TextStyle(fontSize: 22)),
          pw.Text('${l.total}: ${outing.total.round()}'),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: [l.name, l.share, l.paid, l.diff],
            data: [
              for (final b in balances)
                [
                  nameFor[b.memberId] ?? '?',
                  b.share.round().toString(),
                  b.paid.round().toString(),
                  (b.diff >= 0 ? '+' : '') + b.diff.round().toString(),
                ],
            ],
          ),
          if (transfers.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Text(l.settleUp, style: const pw.TextStyle(fontSize: 16)),
            for (final t in transfers)
              pw.Text(l.gives(nameFor[t.fromId] ?? '?', nameFor[t.toId] ?? '?', t.amount.round())),
          ],
        ],
      ),
    ),
  );

  return doc.save();
}
