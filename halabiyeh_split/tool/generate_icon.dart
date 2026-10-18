// Rasterizes the Halabiyeh app icon (plate split into 3, one slice pulled
// out) straight from the design's geometry — no svg/native rasterizer
// available offline, so pixel-sampling with the `image` package (pure
// Dart) stands in for an SVG renderer. Run: dart run tool/generate_icon.dart
import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

const bgColor = [0x1E, 0x5F, 0x48]; // accent default
const sliceColor = [0xE8, 0xA3, 0x3D];
const plateColor = [0xF3, 0xF1, 0xEC];

void drawPlate(img.Image image, double size, {required bool withBackground}) {
  final scale = size / 100;
  final cx = 50 * scale, cy = 50 * scale, radius = 30 * scale;
  final cornerRadius = 22 * scale;
  // Pulled slice is offset by (4.6, -2.7) in the original 100-unit space.
  final offX = 4.6 * scale, offY = -2.7 * scale;

  bool insideRoundedRect(double x, double y) {
    final left = cornerRadius, right = size - cornerRadius;
    final top = cornerRadius, bottom = size - cornerRadius;
    final nx = x < left ? left : (x > right ? right : x);
    final ny = y < top ? top : (y > bottom ? bottom : y);
    return (x - nx) * (x - nx) + (y - ny) * (y - ny) <= cornerRadius * cornerRadius;
  }

  // Sector angles (degrees, atan2 convention): pulled slice spans [-90, 30).
  bool inPulledSector(double dx, double dy) {
    final deg = math.atan2(dy, dx) * 180 / math.pi;
    return deg >= -90 && deg < 30;
  }

  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      final px = x + 0.5, py = y + 0.5;
      if (withBackground && insideRoundedRect(px, py)) {
        image.setPixelRgba(x, y, bgColor[0], bgColor[1], bgColor[2], 255);
      }
      final dx = px - cx, dy = py - cy;
      if (dx * dx + dy * dy <= radius * radius && !inPulledSector(dx, dy)) {
        image.setPixelRgba(x, y, plateColor[0], plateColor[1], plateColor[2], 255);
      }
      final sdx = px - offX - cx, sdy = py - offY - cy;
      if (sdx * sdx + sdy * sdy <= radius * radius && inPulledSector(sdx, sdy)) {
        image.setPixelRgba(x, y, sliceColor[0], sliceColor[1], sliceColor[2], 255);
      }
    }
  }
}

void main() {
  const size = 1024.0;

  final full = img.Image(width: size.toInt(), height: size.toInt(), numChannels: 4);
  drawPlate(full, size, withBackground: true);
  File('assets/icon/icon.png').createSync(recursive: true);
  File('assets/icon/icon.png').writeAsBytesSync(img.encodePng(full));

  final fg = img.Image(width: size.toInt(), height: size.toInt(), numChannels: 4);
  drawPlate(fg, size, withBackground: false);
  File('assets/icon/icon_foreground.png').writeAsBytesSync(img.encodePng(fg));

  stdout.writeln('Wrote assets/icon/icon.png and icon_foreground.png');
}
