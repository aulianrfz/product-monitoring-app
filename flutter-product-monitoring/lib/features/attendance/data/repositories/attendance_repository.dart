import '../../../../core/repositories/sync_repository.dart';
import '../datasources/attendance_local_datasource.dart';
import '../datasources/attendance_remote_datasource.dart';
import '../models/attendance_model.dart';

class AttendanceRepository implements SyncableRepository {
  final AttendanceRemoteDataSource remoteDataSource;
  final AttendanceLocalDataSource localDataSource;

  AttendanceRepository({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  Future<void> submitAttendance(Attendance attendance, String token) async {
    try {
      await remoteDataSource.sendAttendance(attendance, token);
    } catch (_) {
      await localDataSource.cacheAttendance(attendance);
    }
  }

  Future<List<Attendance>> getAttendanceHistory(String token) async {
    try {
      final history = await remoteDataSource.getAttendanceHistory(token);
      await localDataSource.cacheAttendanceHistory(history);
      return history;
    } catch (e) {
      final cached = await localDataSource.getCachedAttendanceHistory();
      if (cached.isNotEmpty) {
        return cached;
      } else {
        throw Exception('Gagal memuat riwayat absensi: $e');
      }
    }
  }


  @override
  Future<void> syncPending(String token) async {
    final pendingAttendances = await localDataSource.getPendingAttendances();
    for (var attendance in pendingAttendances) {
      try {
        await remoteDataSource.sendAttendance(attendance, token);
        await localDataSource.markAttendanceSynced(pendingAttendances.indexOf(attendance), true);
      } catch (_) {}
    }
  }

}
