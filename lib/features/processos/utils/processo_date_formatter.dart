import 'package:intl/intl.dart';

class ProcessoDateFormatter {
  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  static String date(String? value, {String fallback = 'N/D'}) {
    final parsed = _parse(value);
    if (parsed == null) return fallback;
    return _dateFormat.format(parsed);
  }

  static String dateTime(String? value, {String fallback = 'N/D'}) {
    final parsed = _parse(value);
    if (parsed == null) return fallback;
    return _dateTimeFormat.format(parsed);
  }

  static DateTime? _parse(String? value) {
    final raw = value?.trim();
    if (raw == null || raw.isEmpty) return null;

    return DateTime.tryParse(raw.replaceFirst(' ', 'T'));
  }
}
