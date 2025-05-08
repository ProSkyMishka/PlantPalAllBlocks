import 'package:intl/intl.dart';

class WateringSchedule {
  final String id;
  final String plantId;
  final DateTime? lastWatered;
  final int timesPerDay;
  final int daysCount;

  WateringSchedule({
    required this.id,
    required this.plantId,
    this.lastWatered,
    required this.timesPerDay,
    required this.daysCount,
  });

  DateTime? get nextWatering {
    if (lastWatered == null) {
      return null;
    }
    return lastWatered!.add(Duration(days: daysCount));
  }

  List<DateTime> get wateringTimes {
    List<DateTime> times = [];
    if (nextWatering != null) {
      for (int i = 0; i < timesPerDay; i++) {
        times.add(DateTime(
          nextWatering!.year,
          nextWatering!.month,
          nextWatering!.day,
          8 + i,
          0,
        ));
      }
    }
    return times;
  }

  String getFormattedNextWatering() {
    return nextWatering != null
        ? DateFormat('yyyy-MM-dd').format(nextWatering!)
        : '—';
  }

  WateringSchedule copyWith({
    String? id,
    String? plantId,
    DateTime? lastWatered,
    int? timesPerDay,
    int? daysCount,
  }) {
    return WateringSchedule(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      lastWatered: lastWatered ?? this.lastWatered,
      timesPerDay: timesPerDay ?? this.timesPerDay,
      daysCount: daysCount ?? this.daysCount,
    );
  }
}