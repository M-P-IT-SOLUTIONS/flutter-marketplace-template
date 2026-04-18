import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Utility class for creating custom map pin icons with optional labels and glow effects.
class MapPinIconBuilder {
  static Future<BitmapDescriptor> buildPinIconFromImage({
    required ui.Image image,
    required double size,
    required Color borderColor,
    Color? glowColor,
    String? label,
    TextStyle? labelStyle,
  }) async {
    final double circleRadius = size / 2;
    final double tailHeight = size / 8;
    const double labelGap = 6;
    const double maxLabelWidthFactor = 2.2;

    double labelWidth = 0;
    double labelHeight = 6;
    TextPainter? textPainter;

    if (label != null && label.isNotEmpty) {
      final style = (labelStyle ??
              const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w500,
              ))
          .copyWith(overflow: TextOverflow.ellipsis);

      textPainter = TextPainter(
        text: TextSpan(text: label, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size * maxLabelWidthFactor);

      labelWidth = textPainter.width + 24;
      labelHeight = textPainter.height + 12;
    }

    final double baseWidth = size;
    final double width =
        labelWidth > 0
            ? labelWidth.clamp(baseWidth, size * maxLabelWidthFactor)
            : baseWidth;

    final double circleCenterY = circleRadius;
    final double circleBottomY = circleCenterY + circleRadius;

    double currentBottom = circleBottomY;

    if (labelWidth > 0) {
      currentBottom += labelGap + labelHeight;
    }

    final double height = currentBottom + tailHeight;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final Offset center = Offset(width / 2, circleCenterY);

    if (glowColor != null) {
      final Paint glowPaint =
          Paint()
            ..color = glowColor
            ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 10);
      canvas.drawCircle(center, circleRadius, glowPaint);
    }

    final double innerRadius = circleRadius - 4;
    final Path clipPath =
        Path()..addOval(Rect.fromCircle(center: center, radius: innerRadius));
    canvas.save();
    canvas.clipPath(clipPath);

    final Rect srcRect = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    final Rect dstRect = Rect.fromCircle(center: center, radius: innerRadius);
    canvas.drawImageRect(image, srcRect, dstRect, Paint());
    canvas.restore();

    final Paint borderPaint =
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6;
    canvas.drawCircle(center, innerRadius, borderPaint);

    double labelTop = circleBottomY + labelGap;

    if (textPainter != null && labelWidth > 0) {
      final double rectWidth = width.clamp(size, size * maxLabelWidthFactor);
      final double rectLeft = (width - rectWidth) / 2;

      final Rect labelRect = Rect.fromLTWH(
        rectLeft,
        labelTop,
        rectWidth,
        labelHeight,
      );

      final RRect rrect = RRect.fromRectAndRadius(
        labelRect,
        const Radius.circular(22),
      );

      final Paint labelPaint = Paint()..color = borderColor;
      canvas.drawRRect(rrect, labelPaint);

      final double textX =
          labelRect.left + (labelRect.width - textPainter.width) / 2;
      final double textY =
          labelRect.top + (labelRect.height - textPainter.height) / 2;
      textPainter.paint(canvas, Offset(textX, textY));

      currentBottom = labelRect.bottom;
    } else {
      currentBottom = circleBottomY;
    }

    final double tipY = currentBottom + tailHeight;

    final Path tailPath =
        Path()
          ..moveTo(width / 2, tipY)
          ..lineTo(width / 2 - innerRadius / 3, currentBottom)
          ..lineTo(width / 2 + innerRadius / 3, currentBottom)
          ..close();

    final Paint tailPaint = Paint()..color = borderColor;
    canvas.drawPath(tailPath, tailPaint);

    final ui.Image result = await recorder.endRecording().toImage(
      width.toInt(),
      height.toInt(),
    );
    final ByteData? byteData = await result.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  static Future<BitmapDescriptor> buildPinIconFromNetwork({
    required String imageUrl,
    required double size,
    required Color borderColor,
    Color? glowColor,
    String? label,
    TextStyle? labelStyle,
  }) async {
    final completer = Completer<ImageInfo>();
    final ImageStream stream = NetworkImage(
      imageUrl,
    ).resolve(const ImageConfiguration());
    late final ImageStreamListener listener;

    listener = ImageStreamListener(
      (ImageInfo info, bool _) => completer.complete(info),
      onError:
          (Object error, StackTrace? stackTrace) =>
              completer.completeError(error, stackTrace),
    );

    stream.addListener(listener);
    final ImageInfo imageInfo = await completer.future;
    stream.removeListener(listener);

    return buildPinIconFromImage(
      image: imageInfo.image,
      size: size,
      borderColor: borderColor,
      glowColor: glowColor,
      label: label,
      labelStyle: labelStyle,
    );
  }
}
