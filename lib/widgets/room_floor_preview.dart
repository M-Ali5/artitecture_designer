import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Top-down “room floor” preview; shape follows [widthFt] × [lengthFt] aspect ratio.
class RoomFloorPreview extends StatelessWidget {
  final double widthFt;
  final double lengthFt;
  final String? templateId;

  /// Longer side of the preview box is capped to this (dp).
  final double maxSide;

  final bool showDimensionLabels;
  final bool compact;

  const RoomFloorPreview({
    super.key,
    required this.widthFt,
    required this.lengthFt,
    this.templateId,
    this.maxSide = 200,
    this.showDimensionLabels = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final double safeW = widthFt > 0 ? widthFt : 14.0;
    final double safeL = lengthFt > 0 ? lengthFt : 12.0;
    final aspect = safeW / safeL;

    double boxW;
    double boxH;
    if (aspect >= 1) {
      boxW = maxSide;
      boxH = maxSide / aspect;
    } else {
      boxH = maxSide;
      boxW = maxSide * aspect;
    }

    final radius = compact ? 8.0 : 14.0;

    final preview = CustomPaint(
      painter: _RoomPreviewPainter(
        templateId: templateId,
        cornerRadius: radius,
        layoutSize: Size(boxW, boxH),
      ),
      size: Size(boxW, boxH),
    );

    if (compact) {
      return SizedBox(width: boxW, height: boxH, child: preview);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius + 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius + 2),
            child: SizedBox(width: boxW, height: boxH, child: preview),
          ),
        ),
        if (showDimensionLabels) ...[
          const SizedBox(height: 10),
          Text(
            '${_fmtFt(safeW)} ft  ×  ${_fmtFt(safeL)} ft',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          Text(
            'Preview matches your room shape',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ],
    );
  }

  static String _fmtFt(double v) {
    if (v % 1 == 0) return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }
}

class _RoomPreviewPainter extends CustomPainter {
  _RoomPreviewPainter({
    required this.templateId,
    required this.cornerRadius,
    required this.layoutSize,
  });

  final String? templateId;
  final double cornerRadius;
  final Size layoutSize;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(cornerRadius));

    final floor = _floorGradient(rect);
    final floorPaint = Paint()..shader = floor.createShader(rect);
    canvas.drawRRect(rrect, floorPaint);

    // Light tile grid (scaled to room)
    final grid = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 0.8;
    const cells = 6.0;
    final stepX = size.width / cells;
    final stepY = size.height / cells;
    for (double x = stepX; x < size.width; x += stepX) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = stepY; y < size.height; y += stepY) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final wall = Paint()
      ..color = const Color(0xFF5D4E37)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(2.0, size.shortestSide * 0.04);
    canvas.drawRRect(rrect, wall);

    _drawTemplateHint(canvas, rect);
  }

  LinearGradient _floorGradient(Rect rect) {
    switch (templateId) {
      case 'bedroom':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE8E0F0),
            const Color(0xFFC9B8D9),
            const Color(0xFF9B7FB8),
          ],
        );
      case 'kitchen':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFF8F0),
            const Color(0xFFF5E6D3),
            const Color(0xFFE8C4A0),
          ],
        );
      case 'living':
      default:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF5EDE4),
            const Color(0xFFD4C4B0),
            const Color(0xFFB89B7A),
          ],
        );
    }
  }

  void _drawTemplateHint(Canvas canvas, Rect rect) {
    final cx = rect.center.dx;
    final cy = rect.center.dy;
    final w = rect.width;
    final h = rect.height;

    final accent = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    switch (templateId) {
      case 'living':
        // Sofa band along bottom wall
        final sofa = RRect.fromRectAndRadius(
          Rect.fromLTWH(rect.left + w * 0.15, rect.bottom - h * 0.22, w * 0.7, h * 0.14),
          const Radius.circular(6),
        );
        canvas.drawRRect(sofa, accent);
        break;
      case 'bedroom':
        // Bed rectangle
        final bed = RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - w * 0.22, cy - h * 0.12, w * 0.44, h * 0.28),
          const Radius.circular(8),
        );
        canvas.drawRRect(bed, accent);
        break;
      case 'kitchen':
        // Island block
        final island = RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - w * 0.18, cy - h * 0.1, w * 0.36, h * 0.22),
          const Radius.circular(4),
        );
        canvas.drawRRect(island, accent);
        break;
      default:
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _RoomPreviewPainter oldDelegate) {
    return oldDelegate.templateId != templateId ||
        oldDelegate.cornerRadius != cornerRadius ||
        oldDelegate.layoutSize != layoutSize;
  }
}
