import 'package:intl/intl.dart';

/// Date utility functions
class AppDateUtils {
  // Date formatters
  static final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');
  static final DateFormat _timeFormatter = DateFormat('HH:mm');
  static final DateFormat _dateTimeFormatter = DateFormat('yyyy-MM-dd HH:mm');
  static final DateFormat _displayDateFormatter = DateFormat('MMM dd, yyyy');
  static final DateFormat _displayTimeFormatter = DateFormat('h:mm a');
  static final DateFormat _displayDateTimeFormatter = DateFormat('MMM dd, yyyy h:mm a');

  /// Format date to string (yyyy-MM-dd)
  static String formatDate(DateTime date) {
    return _dateFormatter.format(date);
  }

  /// Format time to string (HH:mm)
  static String formatTime(DateTime date) {
    return _timeFormatter.format(date);
  }

  /// Format date time to string (yyyy-MM-dd HH:mm)
  static String formatDateTime(DateTime date) {
    return _dateTimeFormatter.format(date);
  }

  /// Format date for display (MMM dd, yyyy)
  static String formatDisplayDate(DateTime date) {
    return _displayDateFormatter.format(date);
  }

  /// Format time for display (h:mm a)
  static String formatDisplayTime(DateTime date) {
    return _displayTimeFormatter.format(date);
  }

  /// Format date time for display (MMM dd, yyyy h:mm a)
  static String formatDisplayDateTime(DateTime date) {
    return _displayDateTimeFormatter.format(date);
  }

  /// Parse date string (yyyy-MM-dd)
  static DateTime? parseDate(String dateString) {
    try {
      return _dateFormatter.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Parse date time string (yyyy-MM-dd HH:mm)
  static DateTime? parseDateTime(String dateTimeString) {
    try {
      return _dateTimeFormatter.parse(dateTimeString);
    } catch (e) {
      return null;
    }
  }

  /// Get age from date of birth
  static int getAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    
    return age;
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
           date.month == yesterday.month &&
           date.day == yesterday.day;
  }

  /// Check if date is this week
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
           date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Get relative time string (e.g., "2 hours ago", "Yesterday", "Last week")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        } else {
          return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
        }
      } else {
        return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
      }
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years == 1 ? '' : 's'} ago';
    }
  }

  /// Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Get start of week (Monday)
  static DateTime startOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return startOfDay(date.subtract(Duration(days: daysFromMonday)));
  }

  /// Get end of week (Sunday)
  static DateTime endOfWeek(DateTime date) {
    final daysToSunday = 7 - date.weekday;
    return endOfDay(date.add(Duration(days: daysToSunday)));
  }

  /// Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get end of month
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  /// Check if date is in range
  static bool isInRange(DateTime date, DateTime start, DateTime end) {
    return date.isAfter(start.subtract(const Duration(milliseconds: 1))) &&
           date.isBefore(end.add(const Duration(milliseconds: 1)));
  }

  /// Get days between two dates
  static int daysBetween(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }

  /// Add business days (excluding weekends)
  static DateTime addBusinessDays(DateTime date, int days) {
    DateTime result = date;
    int addedDays = 0;
    
    while (addedDays < days) {
      result = result.add(const Duration(days: 1));
      if (result.weekday != DateTime.saturday && result.weekday != DateTime.sunday) {
        addedDays++;
      }
    }
    
    return result;
  }

  /// Check if date is weekend
  static bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  /// Get next business day
  static DateTime nextBusinessDay(DateTime date) {
    DateTime next = date.add(const Duration(days: 1));
    while (isWeekend(next)) {
      next = next.add(const Duration(days: 1));
    }
    return next;
  }

  /// Get previous business day
  static DateTime previousBusinessDay(DateTime date) {
    DateTime previous = date.subtract(const Duration(days: 1));
    while (isWeekend(previous)) {
      previous = previous.subtract(const Duration(days: 1));
    }
    return previous;
  }
}
