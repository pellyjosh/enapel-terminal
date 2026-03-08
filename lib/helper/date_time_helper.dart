import 'package:intl/intl.dart';

class DateHelper {
  static String formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('MMM dd, yyyy');
    return formatter.format(date);
  }

  // Formats a DateTime object to a human-readable string with time (e.g., 'Nov 24, 2024, 02:30 PM')
  static String formatDateTime(DateTime date) {
    final DateFormat formatter = DateFormat('MMM dd, yyyy, hh:mm a');
    return formatter.format(date);
  }

  // Formats a DateTime object to just the time part (e.g., '02:30 PM')
  static String formatTime(DateTime date) {
    final DateFormat formatter = DateFormat('hh:mm a');
    return formatter.format(date);
  }

  // Formats a DateTime object to a custom string format (e.g., '2024-11-24 14:30:00')
  static String formatCustom(DateTime date, String pattern) {
    final DateFormat formatter = DateFormat(pattern);
    return formatter.format(date);
  }

  // Parse a string to DateTime (optional utility function for parsing a st
}
