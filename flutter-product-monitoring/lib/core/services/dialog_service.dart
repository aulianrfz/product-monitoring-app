import 'package:flutter/material.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/error_dialog.dart';
import '../widgets/success_dialog.dart';

class DialogService {
  static void showError(BuildContext context, String message, {String title = "Error"}) {
    ErrorDialog.show(context, title: title, message: message);
  }

  static void showSuccess(
      BuildContext context,
      String message, {
        String title = "Berhasil",
      }) {
    SuccessDialog.show(context, title: title, message: message);
  }

  static Future<bool?> showConfirm(
      BuildContext context, {
        required String title,
        required String message,
      }) {
    return ConfirmationDialog.show(context, title: title, message: message);
  }
}
