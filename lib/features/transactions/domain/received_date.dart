final earliestReceivedDay = DateTime(1980, 1, 1);

DateTime receivedDateFor(DateTime pickedDay) {
  return DateTime(pickedDay.year, pickedDay.month, pickedDay.day, 12).toUtc();
}

DateTime calendarDay(DateTime moment) {
  final local = moment.toLocal();
  return DateTime(local.year, local.month, local.day);
}

bool isAllowedReceivedDay(DateTime day, {required DateTime today}) {
  final pickedDay = calendarDay(day);
  return !pickedDay.isBefore(earliestReceivedDay) &&
      !pickedDay.isAfter(calendarDay(today));
}
