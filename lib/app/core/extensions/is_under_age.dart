// ignore_for_file: unused_local_variable

extension DateTimeX on DateTime {
  bool isUnderage() =>
      (DateTime(DateTime.now().year, month, day).isAfter(DateTime.now())
          ? DateTime.now().year - year - 1
          : DateTime.now().year - year) <
      18;
}

extension DateTimeOverEighteen on DateTime {
  DateTime get dateOverEighteen {
    DateTime currentDate = DateTime.now();

    int yearsDifference = currentDate.year - year;

    // Check if the birthday has occurred for the current year
    bool birthdayOccurred = currentDate.month > month ||
        (currentDate.month == month && currentDate.day >= day);

    if (!birthdayOccurred) {
      yearsDifference--;
    }

    // Calculate the birth date over 18 years ago
    return DateTime(currentDate.year - 18, month, day);
  }
}
