import 'package:intl/intl.dart';

class DateHelpers {
  static final DateFormat _standard = DateFormat('dd MMM yyyy');
  static final DateFormat _short = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy · hh:mm a');

  static String format(DateTime date) {
    return _standard.format(date);
  }

  static String formatShort(DateTime date) {
    return _short.format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  static String daysRemainingText(DateTime expiryDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final exp = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    final diff = exp.difference(today).inDays;

    if (diff < 0) {
      final pastDays = diff.abs();
      return pastDays == 1 ? 'Expired 1 day ago' : 'Expired $pastDays days ago';
    } else if (diff == 0) {
      return 'Expires today!';
    } else if (diff == 1) {
      return 'Expires tomorrow';
    } else if (diff <= 30) {
      return 'Expires in $diff days';
    } else if (diff <= 365) {
      final months = (diff / 30).round();
      return 'Expires in ~$months mo${months > 1 ? "s" : ""}';
    } else {
      final years = (diff / 365).toStringAsFixed(1);
      return 'Expires in $years yrs';
    }
  }
}
