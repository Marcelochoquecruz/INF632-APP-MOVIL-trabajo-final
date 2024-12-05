class ScheduleModel {
  final String id;
  final String doctorId;
  final DateTime date;
  final List<TimeSlot> timeSlots;

  ScheduleModel({
    required this.id,
    required this.doctorId,
    required this.date,
    required this.timeSlots,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctorId': doctorId,
      'date': date.toIso8601String(),
      'timeSlots': timeSlots.map((slot) => slot.toMap()).toList(),
    };
  }

  factory ScheduleModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ScheduleModel(
      id: documentId,
      doctorId: map['doctorId'] ?? '',
      date: DateTime.parse(map['date']),
      timeSlots: (map['timeSlots'] as List)
          .map((slot) => TimeSlot.fromMap(slot))
          .toList(),
    );
  }
}

class TimeSlot {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;
  final String? appointmentId;

  TimeSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
    this.appointmentId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isAvailable': isAvailable,
      'appointmentId': appointmentId,
    };
  }

  factory TimeSlot.fromMap(Map<String, dynamic> map) {
    return TimeSlot(
      id: map['id'],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      isAvailable: map['isAvailable'] ?? true,
      appointmentId: map['appointmentId'],
    );
  }
}
