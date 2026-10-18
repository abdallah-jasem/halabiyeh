import 'package:flutter/material.dart';

import '../../../share/domain/format_outing_summary.dart';

class MoneyText extends StatelessWidget {
  final double value;
  final bool signed;
  final TextStyle? style;
  final TextAlign? textAlign;

  const MoneyText(this.value, {super.key, this.signed = false, this.style, this.textAlign});

  @override
  Widget build(BuildContext context) {
    final rounded = value.round();
    final text = signed && rounded > 0 ? '+$rounded' : '$rounded';
    // LTR isolate keeps the sign on the left in Arabic ("-35", not "35-").
    return Text(ltr(text), style: style, textAlign: textAlign);
  }
}
