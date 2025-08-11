import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:personal_rise_daily_growth_336t/theme/app_colors.dart';

OverlayEntry? _levelHelpEntry;

void showLevelHelp(
  BuildContext context,
  LayerLink link, {
  required GlobalKey bgKey, // где размывать фото
  double anchorSize = 44,
}) {
  _levelHelpEntry?.remove();
  _levelHelpEntry = null;

  final bgBox = bgKey.currentContext?.findRenderObject() as RenderBox?;
  final bgOffset = bgBox?.localToGlobal(Offset.zero) ?? Offset.zero;
  final bgSize = bgBox?.size ?? Size.zero;

  void hide() {
    _levelHelpEntry?.remove();
    _levelHelpEntry = null;
  }

  final screenW = MediaQuery.of(context).size.width;
  final maxBubbleW = (screenW - 24).clamp(0, 320).toDouble();
  final bubbleDx = -(maxBubbleW - anchorSize); // выравниваем правые края

  _levelHelpEntry = OverlayEntry(
    builder: (ctx) => Stack(
      children: [
        // --- 1) Размыть ТОЛЬКО фото ---
        Positioned(
          left: bgOffset.dx,
          top: bgOffset.dy,
          width: bgSize.width,
          height: bgSize.height,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: hide,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // --- 2) Размыть САМУ кнопку "?" кругом (но не мешать тачам) ---
        IgnorePointer(
          ignoring: true, // тапы проходят сквозь
          child: CompositedTransformFollower(
            link: link,
            showWhenUnlinked: true,
          ),
        ),

        // --- 3) Пузырь (выровнен по правому краю кнопки, не «улетает») ---
        CompositedTransformFollower(
          link: link,
          showWhenUnlinked: false,
          offset: Offset(bubbleDx, anchorSize + 8),
          child: _SpeechBubble(
            color: AppColors.backgroundLevel2,
            radius: 12,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            maxWidth: maxBubbleW,
            tailSide: BubbleSide.top,
            tailWidth: 20,
            tailHeight: 20,
            tailX: anchorSize / 2, // хвост в центр кнопки
            child: const _HelpContent(),
          ),
        ),
      ],
    ),
  );

  Overlay.of(context, rootOverlay: true).insert(_levelHelpEntry!);
  Future.delayed(const Duration(seconds: 6), () {
    if (_levelHelpEntry != null) hide();
  });
}

void hideLevelHelp() {
  _levelHelpEntry?.remove();
  _levelHelpEntry = null;
}

// Текст внутри
class _HelpContent extends StatelessWidget {
  const _HelpContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text:
                    'Only good habits increase your level.\nEach good habit = ',
                style: TextStyle(
                  color: AppColors.textlevel1,
                  fontSize: 15.sp,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w400,
                  height: 1.47,
                  letterSpacing: 0.30,
                ),
              ),
              TextSpan(
                text: '+1',
                style: TextStyle(
                  color: AppColors.successAccent,
                  fontSize: 15.sp,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w700,
                  height: 1.47,
                  letterSpacing: 0.30,
                ),
              ),
              TextSpan(
                text: ' point.\nBad habits reduce progress by ',
                style: TextStyle(
                  color: AppColors.textlevel1,
                  fontSize: 15.sp,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w400,
                  height: 1.47,
                  letterSpacing: 0.30,
                ),
              ),
              TextSpan(
                text: '3',
                style: TextStyle(
                  color: AppColors.errorAccent,
                  fontSize: 15.sp,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w700,
                  height: 1.47,
                  letterSpacing: 0.30,
                ),
              ),
              TextSpan(
                text:
                    ' point.\nTo reach next level earn 50 points       Current: 0 / 50',
                style: TextStyle(
                  color: AppColors.textlevel1,
                  fontSize: 15.sp,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w400,
                  height: 1.47,
                  letterSpacing: 0.30,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum BubbleSide { top, bottom, left, right }

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({
    required this.child,
    required this.color,
    required this.radius,
    required this.padding,
    required this.tailSide,
    required this.tailX, // позиция хвоста вдоль стороны (в пикселях от левого/верхнего края)
    this.tailWidth = 12,
    this.tailHeight = 8,
    this.maxWidth,
  });

  final Widget child;
  final Color color;
  final double radius;
  final EdgeInsets padding;
  final BubbleSide tailSide;
  final double tailX;
  final double tailWidth;
  final double tailHeight;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 6,
      child: CustomPaint(
        painter: _BubblePainter(
          color: color,
          radius: radius,
          tailSide: tailSide,
          tailX: tailX,
          tailWidth: tailWidth,
          tailHeight: tailHeight,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth ?? 360),
          child: Padding(
            // отступ, чтобы контент не залезал на треугольник
            padding:
                padding +
                EdgeInsets.only(
                  top: tailSide == BubbleSide.top ? tailHeight : 0,
                  bottom: tailSide == BubbleSide.bottom ? tailHeight : 0,
                  left: tailSide == BubbleSide.left ? tailHeight : 0,
                  right: tailSide == BubbleSide.right ? tailHeight : 0,
                ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  _BubblePainter({
    required this.color,
    required this.radius,
    required this.tailSide,
    required this.tailX,
    required this.tailWidth,
    required this.tailHeight,
  });

  final Color color;
  final double radius;
  final BubbleSide tailSide;
  final double tailX;
  final double tailWidth;
  final double tailHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    // основное тело
    final bodyRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(bodyRect, Radius.circular(radius));
    canvas.drawRRect(rrect, paint);

    // хвост — треугольник, точка привязки tailX
    final path = Path();
    switch (tailSide) {
      case BubbleSide.top:
        final x = tailX.clamp(8, size.width - 8).toDouble();
        path.moveTo(x, 0);
        path.lineTo(x - tailWidth / 2, 0);
        path.lineTo(x, -tailHeight);
        path.lineTo(x + tailWidth / 2, 0);
        path.close();
        break;
      case BubbleSide.bottom:
        final x2 = tailX.clamp(8, size.width - 8).toDouble();
        path.moveTo(x2, size.height);
        path.lineTo(x2 - tailWidth / 2, size.height);
        path.lineTo(x2, size.height + tailHeight);
        path.lineTo(x2 + tailWidth / 2, size.height);
        path.close();
        break;
      case BubbleSide.left:
        final y = tailX.clamp(8, size.height - 8).toDouble();
        path.moveTo(0, y);
        path.lineTo(0, y - tailWidth / 2);
        path.lineTo(-tailHeight, y);
        path.lineTo(0, y + tailWidth / 2);
        path.close();
        break;
      case BubbleSide.right:
        final y2 = tailX.clamp(8, size.height - 8).toDouble();
        path.moveTo(size.width, y2);
        path.lineTo(size.width, y2 - tailWidth / 2);
        path.lineTo(size.width + tailHeight, y2);
        path.lineTo(size.width, y2 + tailWidth / 2);
        path.close();
        break;
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BubblePainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.tailSide != tailSide ||
      old.tailX != tailX ||
      old.tailWidth != tailWidth ||
      old.tailHeight != tailHeight;
}
