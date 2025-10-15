import 'package:hive/hive.dart';
import '../../../../core/models/sync_model.dart';
import '../models/attendance_model.dart';

abstract class AttendanceLocalDataSource {
  Future<void> cacheAttendance(Attendance attendance);
  Future<List<Attendance>> getPendingAttendances();
  Future<void> markAttendanceSynced(int index, bool synced);
  Future<void> cacheAttendanceHistory(List<Attendance> history);
  Future<List<Attendance>> getCachedAttendanceHistory();
}

class AttendanceLocalDataSourceImpl implements AttendanceLocalDataSource {
  static const _attendanceBox = 'attendanceBox';
  static const _syncBox = 'syncAttendanceBox';
  static const _historyBox = 'attendanceHistoryBox';

  @override
  Future<void> cacheAttendance(Attendance attendance) async {
    final box = await Hive.openBox<Attendance>(_attendanceBox);
    final syncBox = await Hive.openBox<SyncStatus>(_syncBox);
    await box.add(attendance);
    await syncBox.put('attendance-${attendance.timestamp}', SyncStatus(type: 'attendance', id: box.length, isSynced: false));
  }

  @override
  Future<List<Attendance>> getPendingAttendances() async {
    final box = await Hive.openBox<Attendance>(_attendanceBox);
    final syncBox = await Hive.openBox<SyncStatus>(_syncBox);
    final unsynced = syncBox.values.where((s) => s.type == 'attendance' && !s.isSynced).toList();
    return unsynced.map((s) => box.getAt(s.id - 1)!).toList();
  }

  @override
  Future<void> markAttendanceSynced(int index, bool synced) async {
    final syncBox = await Hive.openBox<SyncStatus>(_syncBox);
    final key = syncBox.keys.firstWhere((k) => k.toString().startsWith('attendance'), orElse: () => null);
    if (key != null) {
      final data = syncBox.get(key)!;
      await syncBox.put(key, SyncStatus(type: data.type, id: data.id, isSynced: synced));
    }
  }

  @override
  Future<void> cacheAttendanceHistory(List<Attendance> history) async {
    final box = await Hive.openBox<Attendance>(_historyBox);
    await box.clear();
    await box.addAll(history);
  }

  @override
  Future<List<Attendance>> getCachedAttendanceHistory() async {
    final box = await Hive.openBox<Attendance>(_historyBox);
    return box.values.toList();
  }
}
