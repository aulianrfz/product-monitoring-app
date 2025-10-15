import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/dialog_service.dart';
import '../../../authentication/data/datasources/auth_remote_datasources.dart';
import '../../../authentication/data/models/user_model.dart';
import '../../../authentication/presentation/views/login_view.dart';
import '../../../store/presentation/views/store_list_view.dart';
import '../../data/models/attendance_model.dart';
import '../viewmodels/attendance_viewmodel.dart';

class AttendanceView extends StatefulWidget {
  final User user;

  const AttendanceView({super.key, required this.user});

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
  @override
  void initState() {
    super.initState();
    final viewModel = context.read<AttendanceViewModel>();

    viewModel.addListener(() {
      if (!mounted) return;
      _handleMessages(context, viewModel);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.loadHistory(widget.user.token);
    });
  }


  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AttendanceViewModel>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A5F9D), Color(0xFF6B7EC8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, widget.user),
              Expanded(
                child: _buildBody(context, viewModel),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMessages(BuildContext context, AttendanceViewModel viewModel) {
    if (viewModel.successMessage != null) {
      DialogService.showSuccess(
        context,
        viewModel.successMessage!,
        title: "Success!",
      );
      viewModel.clearMessages();
    }

    if (viewModel.errorMessage != null) {
      DialogService.showError(
        context,
        viewModel.errorMessage!,
        title: "Failed",
      );
      viewModel.clearMessages();
    }
  }

  Widget _buildHeader(BuildContext context, User user) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          _buildUserInfo(user),
          const Spacer(),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildUserInfo(User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Staff Management',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout, color: Colors.white),
      onPressed: () async {
        final confirm = await DialogService.showConfirm(
          context,
            title: "Logout Confirmation",
            message: "Are you sure you want to logout?"
        );

        if (confirm == true && context.mounted) {
          final authService = AuthService();
          await authService.logout();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
          );
        }
      },
    );
  }

  Widget _buildBody(BuildContext context, AttendanceViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          _buildLiveAttendanceCard(context, viewModel),
          _buildHistoryTitle(),
          _buildHistoryList(viewModel),
        ],
      ),
    );
  }

  Widget _buildLiveAttendanceCard(BuildContext context, AttendanceViewModel viewModel) {
    final bool isCheckedIn = viewModel.hasCheckedInToday;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          const Text('Live Attendance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          _buildLiveClock(),
          const SizedBox(height: 4),
          Text(DateFormat('EEE, dd MMMM yyyy').format(DateTime.now()), style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 24),
          const Text('Office Hours', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          const Text('08:00 AM - 05:00 PM', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildActionButtons(context, viewModel, isCheckedIn),
        ],
      ),
    );
  }

  Widget _buildLiveClock() {
    return StreamBuilder<DateTime>(
      stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
      builder: (context, snapshot) {
        final now = snapshot.data ?? DateTime.now();
        return Text(
          DateFormat('hh:mm:ss a').format(now).toUpperCase(),
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF9800),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, AttendanceViewModel viewModel, bool isCheckedIn) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: viewModel.isLoading
                ? null
                : isCheckedIn
                ? () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StoreListView(user: widget.user)),
              );
            }
                : () async {
              await viewModel.submitAttendance('check_in', widget.user.token);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A5F9D),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              isCheckedIn ? 'List Stores' : 'Present',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: (isCheckedIn || viewModel.isLoading)
                ? null
                : () async {
              await viewModel.submitAttendance('check_out', widget.user.token);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: (isCheckedIn || viewModel.isLoading)
                  ? Colors.grey
                  : const Color(0xFF4A5F9D),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Absent', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(Icons.history, size: 24),
          SizedBox(width: 8),
          Text('Attendance History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildHistoryList(AttendanceViewModel viewModel) {
    final history = viewModel.attendanceHistory;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: viewModel.isLoading && history.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : history.isEmpty
            ? const Center(child: Text('No attendance records yet'))
            : ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: history.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final record = history[index];
            return _buildHistoryItem(record);
          },
        ),
      ),
    );
  }

  Widget _buildHistoryItem(Attendance record) {
    final isPresent = record.status == 'check_in';
    final date = DateFormat('EEE, dd MMMM yyyy').format(DateTime.parse(record.timestamp));
    final time = DateFormat('hh:mm a').format(DateTime.parse(record.timestamp));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(flex: 3, child: Text(date, style: const TextStyle(fontSize: 14))),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                isPresent ? 'Present' : 'Absent',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isPresent ? Colors.black87 : const Color(0xFFE74C3C),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              time,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                color: isPresent ? Colors.black87 : const Color(0xFFE74C3C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
