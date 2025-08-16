import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/materials/app_text_styles.dart';

class ExpandableCaption extends StatefulWidget {
  final String username;
  final String caption;
  final int maxLines;

  const ExpandableCaption({
    super.key,
    required this.username,
    required this.caption,
    this.maxLines = 2,
  });

  @override
  State<ExpandableCaption> createState() => _ExpandableCaptionState();
}

class _ExpandableCaptionState extends State<ExpandableCaption> {
  bool isExpanded = false;
  bool isOverflow = false;

  late TapGestureRecognizer usernameTapRecognizer;
  late TapGestureRecognizer toggleTapRecognizer;

  @override
  void initState() {
    super.initState();
    usernameTapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        print('Tapped username: ${widget.username}');
      };
    toggleTapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        setState(() {
          isExpanded = !isExpanded;
        });
      };
  }

  @override
  void dispose() {
    usernameTapRecognizer.dispose();
    toggleTapRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = AppTextStyles.comment(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Dùng TextPainter để kiểm tra tràn dòng
        final fullText = '${widget.username} ${widget.caption}';
        final textPainter = TextPainter(
          text: TextSpan(
            text: fullText,
            style: textStyle,
          ),
          maxLines: widget.maxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        isOverflow = textPainter.didExceedMaxLines;

        // Caption cần cắt khi rút gọn
        final displayCaption = () {
          if (isExpanded || !isOverflow) return widget.caption;

          // Cắt thủ công theo độ dài giới hạn (tạm thời), có thể cải tiến bằng thuật toán binary search
          const cutoff = 80;
          return widget.caption.length > cutoff
              ? '${widget.caption.substring(0, cutoff).trimRight()}...'
              : widget.caption;
        }();

        return RichText(
          text: TextSpan(
            style: textStyle,
            children: [
              TextSpan(
                text: '${widget.username} ',
                style: AppTextStyles.username(context),
                recognizer: usernameTapRecognizer,
              ),
              TextSpan(
                text: displayCaption + (isOverflow && !isExpanded ? ' ' : ''),
                style: textStyle,
              ),
              if (isOverflow)
                TextSpan(
                  text: isExpanded ? 'Thu gọn' : 'Xem thêm',
                  style: textStyle.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  recognizer: toggleTapRecognizer,
                ),
            ],
          ),
        );
      },
    );
  }
}
