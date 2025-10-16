import 'package:flutter/material.dart';

Future<void> showEmailConfirmationDialog(BuildContext context, {required String email}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      final theme = Theme.of(context);
      return AlertDialog(
        title: const Text('Đăng ký thành công'),
        content: Text('Vui lòng kiểm tra hộp thư $email và làm theo hướng dẫn trong email để xác nhận tài khoản.'),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Đóng'))],
      );
    },
  );
}

Future<bool?> showNotificationDialog(BuildContext context, {required String message, String title = 'Notification'}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true, // tap outside to dismiss
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text('Ok'))],
      );
    },
  );
}

Future<bool?> showConfirmationDialog(BuildContext context, {required String message, String title = 'Confirmation'}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true, // tap outside to dismiss
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text('Continue')),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text('Cancel')),
        ],
      );
    },
  );
}

void showErrorDialog(BuildContext context, String errorMessage) {
  showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Lỗi'),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Đóng'),
          ),
        ],
      );
    },
  );
}
