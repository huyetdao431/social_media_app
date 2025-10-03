import 'dart:async';
import 'package:flutter/material.dart';

class LoadingOverlay {
  static OverlayEntry? _current;
  static Timer? _timer;
  static bool _isTimeoutDialogShown = false;

  /// Hiển thị overlay với spinner ở giữa.
  /// - [context]: BuildContext (nên truyền context của State hoặc root context)
  /// - [timeout]: khoảng thời gian chờ trước khi tự hide (mặc định 15s)
  /// - [onTimeout]: callback gọi khi timeout (nếu null thì show dialog mặc định)
  /// - [barrierColor]: nếu muốn nền mờ, truyền color; mặc định transparent (chỉ chặn input)
  static void show(
      BuildContext context, {
        Duration timeout = const Duration(seconds: 30),
        VoidCallback? onTimeout,
        Color? barrierColor,
      }) {
    // Nếu đã có overlay đang hiện -> bỏ qua
    if (_current != null) return;

    final overlayState = Overlay.of(context, rootOverlay: true);

    _isTimeoutDialogShown = false;

    _current = OverlayEntry(
      builder: (ctx) {
        return Stack(
          children: [
            // barrier trong suốt (chặn input)
            Positioned.fill(
              child: ModalBarrier(
                color: barrierColor ?? Colors.black.withAlpha(56),
                dismissible: false,
              ),
            ),
            // Spinner ở giữa
            const Center(
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ],
        );
      },
    );

    overlayState.insert(_current!);

    // Timer timeout
    _timer = Timer(timeout, () {
      // hide overlay
      hide();

      // gọi callback hoặc show dialog mặc định
      try {
        if (onTimeout != null) {
          onTimeout();
        } else {
          _showDefaultTimeoutDialog(context);
        }
      } catch (e) {
        // ignore errors from UI show if context not valid
        debugPrint('LoadingOverlay: timeout callback error: $e');
      }
    });
  }

  /// Ẩn overlay (nếu đang hiện)
  static void hide() {
    try {
      _timer?.cancel();
      _timer = null;
      _current?.remove();
      _current = null;
    } catch (e) {
      debugPrint('LoadingOverlay.hide error: $e');
      _timer = null;
      _current = null;
    }
  }

  /// Dialog mặc định khi timeout (chỉ show 1 dialog tránh spam)
  static Future<void> _showDefaultTimeoutDialog(BuildContext context) async {
    // tránh hiện nhiều dialog do nhiều timeout
    if (_isTimeoutDialogShown) return;
    _isTimeoutDialogShown = true;

    // cố gắng show dialog bằng root navigator; catch error nếu context không hợp lệ
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Lỗi'),
            content: const Text('Thao tác mất quá nhiều thời gian. Vui lòng thử lại.'),
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
    } catch (e) {
      debugPrint('LoadingOverlay: cannot show timeout dialog: $e');
    } finally {
      _isTimeoutDialogShown = false;
    }
  }
}
