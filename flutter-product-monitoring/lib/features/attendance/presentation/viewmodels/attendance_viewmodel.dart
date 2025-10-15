import 'package:flutter/material.dart';
import '../../data/models/attendance_model.dart';
import '../../data/repositories/attendance_repository.dart';

class AttendanceViewModel extends ChangeNotifier {
  final AttendanceRepository _repository;

  AttendanceViewModel({required AttendanceRepository repository})
      : _repository = repository;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  bool _hasCheckedInToday = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get hasCheckedInToday => _hasCheckedInToday;

  List<Attendance> _attendanceHistory = [];
  List<Attendance> get attendanceHistory => _attendanceHistory;

  Future<void> submitAttendance(String status, String token) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final attendance = Attendance(
        status: status,
        timestamp: DateTime.now().toString().substring(0, 19),
      );

      await _repository.submitAttendance(attendance, token);
      _successMessage = 'Attendance successfully recorded';

      await loadHistory(token);

      if (status == 'check_in') {
        _hasCheckedInToday = true;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadHistory(String token) async {
    try {
      final allHistory = await _repository.getAttendanceHistory(token);

      _attendanceHistory = allHistory.take(7).toList();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

}
