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
  Widget? content, // <— новый параметр
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

  // final bubbleDx = -(maxBubbleW - anchorSize); // выравниваем правые края
  final screenW = MediaQuery.of(context).size.width;
  final maxBubbleW = (screenW - 24).clamp(0, 320).toDouble();

  // базовый оффсет — под кнопкой
  var bubbleOffset = Offset(-(maxBubbleW - anchorSize), anchorSize + 8);

  // если вдруг выходим за левый край — подвигать вправо
  final anchorGlobal = link.leader?.offset ?? Offset.zero;
  final bubbleLeft = anchorGlobal.dx + bubbleOffset.dx;
  final bubbleRight = bubbleLeft + maxBubbleW;
  if (bubbleLeft < 12) {
    bubbleOffset = bubbleOffset.translate(12 - bubbleLeft, 0);
  }
  if (bubbleRight > screenW - 12) {
    bubbleOffset = bubbleOffset.translate((screenW - 12) - bubbleRight, 0);
  }

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
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),

        // --- 2) Размыть САМУ кнопку "?" кругом (но не мешать тачам) ---
        IgnorePointer(
          ignoring: true, // тапы проходят сквозь
          child: // «Клон» кнопки поверх размытия, тапы проходят к настоящей кнопке
          CompositedTransformFollower(
            link: link,
            showWhenUnlinked: false,
            child: IgnorePointer(
              ignoring: true,
              child: Container(
                width: anchorSize,
                height: anchorSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.backgroundLevel2,
                  borderRadius: BorderRadius.circular(34.r),
                ),
                child: Image.asset(
                  'assets/icons/question_mark.png',
                  color: AppColors.textlevel1,
                  width: 16.sp,
                  height: 16.sp,
                ),
              ),
            ),
          ),
        ),

        // --- 3) Пузырь (выровнен по правому краю кнопки, не «улетает») ---
        CompositedTransformFollower(
          link: link,
          showWhenUnlinked: false,

          offset: bubbleOffset,
          child: _SpeechBubble(
            color: AppColors.backgroundLevel2,
            radius: 12,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            maxWidth: maxBubbleW,
            tailSide: BubbleSide.top,
            tailWidth: 20,
            tailHeight: 20,
            tailX:
                (anchorSize / 2) +
                (-(bubbleOffset.dx)).clamp(
                  0,
                  maxBubbleW,
                ), // хвост остаётся «на кнопке»
            child: content ?? const HelpContentLevel(),
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

class HelpContentLevel extends StatelessWidget {
  const HelpContentLevel({
    super.key,
    this.goodPoint = 1,
    this.badPenalty = 3,
    this.target = 50,
    this.current = 0,
    this.total = 50,
  });

  final int goodPoint;
  final int badPenalty;
  final int target;
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(
      color: AppColors.textlevel1,
      fontSize: 15.sp,
      fontFamily: 'SF Pro',
      height: 1.47,
      letterSpacing: .30,
      fontWeight: FontWeight.w400,
    );
    final strong = base.copyWith(fontWeight: FontWeight.w700);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Only good habits increase your level.\n',
            style: base,
          ),
          TextSpan(text: 'Each good habit = ', style: base),
          TextSpan(
            text: '+$goodPoint',
            style: strong.copyWith(color: AppColors.successAccent),
          ),
          TextSpan(text: ' point.\n', style: base),

          TextSpan(text: 'Bad habits reduce progress by ', style: base),
          TextSpan(
            text: '$badPenalty',
            style: strong.copyWith(color: AppColors.errorAccent),
          ),
          TextSpan(text: ' point.\n', style: base),

          TextSpan(text: 'To reach next level earn ', style: base),
          TextSpan(text: '$target', style: strong),
          TextSpan(text: ' points\n', style: base),

          TextSpan(text: 'Current: ', style: base),
          TextSpan(text: '$current / $total', style: strong),
        ],
      ),
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
    required this.tailX,
    this.tailWidth = 14,
    this.tailHeight = 10,
    this.maxWidth,
    this.elevation = 12,
  });

  final Widget child;
  final Color color;
  final double radius;
  final EdgeInsets padding;
  final BubbleSide tailSide;
  final double tailX; // позиция хвоста вдоль стороны (px)
  final double tailWidth;
  final double tailHeight;
  final double? maxWidth;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final extraPad = EdgeInsets.only(
      top: tailSide == BubbleSide.top ? tailHeight : 0,
      bottom: tailSide == BubbleSide.bottom ? tailHeight : 0,
      left: tailSide == BubbleSide.left ? tailHeight : 0,
      right: tailSide == BubbleSide.right ? tailHeight : 0,
    );

    return CustomPaint(
      painter: _BubblePainter(
        color: color,
        radius: radius,
        tailSide: tailSide,
        tailX: tailX,
        tailWidth: tailWidth,
        tailHeight: tailHeight,
        elevation: elevation,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? 340),
        child: Padding(padding: padding + extraPad, child: child),
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
    required this.elevation,
  });

  final Color color;
  final double radius;
  final BubbleSide tailSide;
  final double tailX;
  final double tailWidth;
  final double tailHeight;
  final double elevation;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Radius.circular(radius);
    final rect = RRect.fromRectAndCorners(
      Rect.fromLTWH(0, 0, size.width, size.height),
      topLeft: r,
      topRight: r,
      bottomLeft: r,
      bottomRight: r,
    );

    final path = Path()..addRRect(rect);

    // Добавляем «хвостик» в тот же path (без шва)
    switch (tailSide) {
      case BubbleSide.top:
        {
          final x = tailX.clamp(8, size.width - 8).toDouble();
          final y = 0.0;
          path.moveTo(x - tailWidth / 2, y);
          path.relativeLineTo(tailWidth / 2, -tailHeight);
          path.relativeLineTo(tailWidth / 2, tailHeight);
          break;
        }
      case BubbleSide.bottom:
        {
          final x = tailX.clamp(8, size.width - 8).toDouble();
          final y = size.height;
          path.moveTo(x - tailWidth / 2, y);
          path.relativeLineTo(tailWidth / 2, tailHeight);
          path.relativeLineTo(tailWidth / 2, -tailHeight);
          break;
        }
      case BubbleSide.left:
        {
          final y = tailX.clamp(8, size.height - 8).toDouble();
          final x = 0.0;
          path.moveTo(x, y - tailWidth / 2);
          path.relativeLineTo(-tailHeight, tailWidth / 2);
          path.relativeLineTo(tailHeight, tailWidth / 2);
          break;
        }
      case BubbleSide.right:
        {
          final y = tailX.clamp(8, size.height - 8).toDouble();
          final x = size.width;
          path.moveTo(x, y - tailWidth / 2);
          path.relativeLineTo(tailHeight, tailWidth / 2);
          path.relativeLineTo(-tailHeight, tailWidth / 2);
          break;
        }
    }

    // мягкая тень
    canvas.drawShadow(path, Colors.black.withOpacity(.6), elevation, true);
    // сам пузырь
    final paint = Paint()..color = color;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BubblePainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.tailSide != tailSide ||
      old.tailX != tailX ||
      old.tailWidth != tailWidth ||
      old.tailHeight != tailHeight ||
      old.elevation != elevation;
}
