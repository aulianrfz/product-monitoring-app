import 'package:hive/hive.dart';

part 'attendance_model.g.dart';

@HiveType(typeId: 4)
class Attendance {
  @HiveField(0)
  final String status;

  @HiveField(1)
  final String timestamp;

  Attendance({
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'status': status,
    'timestamp': timestamp,
  };

  factory Attendance.fromJson(Map<String, dynamic> json) => Attendance(
    status: json['status'],
    timestamp: json['timestamp'],
  );
}
