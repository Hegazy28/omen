DateTime toCairoTime(DateTime dateTime) {
  final utc = dateTime.toUtc();
  final base = utc.add(const Duration(hours: 2)); // Egypt standard time (UTC+2)

  if (_isEgyptDst(base)) {
    return base.add(const Duration(hours: 1)); // UTC+3 during DST
  }

  return base;
}

DateTime cairoNow() => toCairoTime(DateTime.now().toUtc());

String formatCairoTime12h(DateTime dateTime) {
  final cairo = toCairoTime(dateTime);
  final hour24 = cairo.hour;
  final minute = cairo.minute.toString().padLeft(2, '0');
  final period = hour24 >= 12 ? 'PM' : 'AM';
  final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
  return '$hour12:$minute $period';
}

String formatCairoDateTimeShort(DateTime dateTime) {
  final cairo = toCairoTime(dateTime);
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  final day = cairo.day.toString().padLeft(2, '0');
  final month = months[cairo.month - 1];
  final time = formatCairoTime12h(cairo);
  return '$month $day · $time';
}

String cairoDayKey(DateTime dateTime) {
  final cairo = toCairoTime(dateTime);
  return '${cairo.year}-${cairo.month.toString().padLeft(2, '0')}-${cairo.day.toString().padLeft(2, '0')}';
}

bool _isEgyptDst(DateTime cairoBaseUtcPlus2) {
  final year = cairoBaseUtcPlus2.year;
  final dstStart = _lastWeekdayOfMonth(year, 4, DateTime.friday); // Last Friday in April
  final dstEndExclusive =
      _lastWeekdayOfMonth(year, 10, DateTime.thursday).add(const Duration(days: 1));

  return !cairoBaseUtcPlus2.isBefore(dstStart) && cairoBaseUtcPlus2.isBefore(dstEndExclusive);
}

DateTime _lastWeekdayOfMonth(int year, int month, int weekday) {
  var date = DateTime(year, month + 1, 0);
  while (date.weekday != weekday) {
    date = date.subtract(const Duration(days: 1));
  }
  return DateTime(date.year, date.month, date.day);
}
