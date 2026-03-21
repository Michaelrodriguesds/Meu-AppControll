import 'package:intl/intl.dart';

final _brl = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

/// Format double as "R$ 1.234,56"
String formatBRL(double value) => _brl.format(value);

/// Format double as "R$ 1.234,56" or "•••••" when hidden
String formatBRLOrHidden(double value, {required bool hidden}) =>
    hidden ? '•••••' : formatBRL(value);