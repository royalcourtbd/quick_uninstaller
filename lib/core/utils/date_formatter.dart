import 'package:intl/intl.dart';

String getFormattedCurrentDateWithDay() {
  return DateFormat('MMM dd, yyyy - EEEE').format(DateTime.now());
}

String getFormattedCurrentDate() {
  return DateFormat('MMM dd, yyyy').format(DateTime.now());
}

String getFormattedTime(DateTime? time) {
  return time != null ? DateFormat('hh:mm').format(time) : '--:--';
}

String getFormattedTimeForWaqtView(DateTime? time) {
  return time != null ? DateFormat('hh:mm').format(time) : '--:--';
}

String getFormattedTimeForFasting(DateTime? time) {
  return time != null ? DateFormat('hh:mm a').format(time) : '--:--';
}

String getFormattedDate(DateTime? date, {String format = 'MMM dd, yyyy'}) {
  if (date == null) return '';
  return DateFormat(format).format(date);
}

String getFormattedDuration(Duration? duration) {
  if (duration == null) return '--:--';
  return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
}
