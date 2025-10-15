import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/attendance_model.dart';

abstract class AttendanceRemoteDataSource {
  Future<void> sendAttendance(Attendance attendance, String token);
  Future<List<Attendance>> getAttendanceHistory(String token);
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final String baseUrl;

  AttendanceRemoteDataSourceImpl({required this.baseUrl});

  @override
  Future<void> sendAttendance(Attendance attendance, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/report/attendance'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(attendance.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal kirim absensi: ${response.body}');
    }
  }

  @override
  Future<List<Attendance>> getAttendanceHistory(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/attendance/history'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal memuat riwayat absensi: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final List<dynamic> list = data['data'];
    return list.map((e) => Attendance.fromJson(e)).toList();
  }

}
