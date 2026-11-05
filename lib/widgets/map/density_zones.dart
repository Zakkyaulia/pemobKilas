import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;

import 'dummy_map_data.dart';

// ── Konfigurasi klasifikasi kepadatan relatif ────────────────────────────────

/// Batas bawah kategori "Sedang" (kepadatan relatif, bukan jumlah laporan).
const double kDensityMediumThreshold = 0.30;

/// Batas bawah kategori "Tinggi" (kepadatan relatif, bukan jumlah laporan).
const double kDensityHighThreshold = 0.70;

/// Kepadatan relatif minimum agar suatu area masih diwarnai hijau dasar.
const double _kBaseThreshold = 0.06;

/// Lebar transisi lembut (±) di sekitar setiap batas kategori.
const double _kBlendBand = 0.035;

/// Referensi kepadatan minimum, setara dengan N laporan yang bertumpuk di
/// satu titik. Mencegah dataset kecil (mis. 1 laporan) langsung mencapai
/// 100% dan menghasilkan zona "Tinggi" yang besar.
const double _kMinReferenceMass = 4.0;

/// Persentil kepadatan di lokasi laporan yang dipakai sebagai referensi
/// (lebih tahan outlier dibanding nilai maksimum mutlak).
const double _kReferencePercentile = 0.95;

/// Batas bandwidth kernel (meter), proporsional dengan skala kampus.
const double _kMinBandwidthM = 40;
const double _kMaxBandwidthM = 160;

/// Resolusi grid: ukuran sel ≈ bandwidth / faktor ini, dibatasi maks piksel.
const double _kCellsPerBandwidth = 10;
const int _kMaxGridSide = 256;

// ── Palet zona (warna tidak jenuh + alpha rendah agar detail peta terbaca) ──
const _kNormal = (r: 0x86, g: 0xD4, b: 0xB0, a: 0.30); // soft green
const _kMedium = (r: 0xFF, g: 0xCC, b: 0x5C, a: 0.44); // amber
const _kHigh = (r: 0xEF, g: 0x7D, b: 0x72, a: 0.50); // coral / soft red

/// Hasil visualisasi zona kepadatan yang siap ditampilkan pada peta.
class DensityZonesOverlay {
  final ImageProvider image;
  final LatLngBounds bounds;

  /// Batas wilayah pemantauan; kosong = tanpa pemotongan.
  final List<LatLng> boundary;

  const DensityZonesOverlay(this.image, this.bounds, this.boundary);

  /// Layer flutter_map yang terikat ke koordinat geografis.
  Widget toLayer() {
    final layer = OverlayImageLayer(
      overlayImages: [
        OverlayImage(
          bounds: bounds,
          imageProvider: image,
          // Interpolasi bilinear → transisi antarzona tetap halus saat di-zoom.
          filterQuality: FilterQuality.medium,
        ),
      ],
    );
    if (boundary.length < 3) return layer;
    // Tepi luar dipotong secara vektor agar tetap tajam di semua level zoom.
    return Builder(
      builder: (context) => ClipPath(
        clipper: _BoundaryClipper(MapCamera.of(context), boundary),
        child: layer,
      ),
    );
  }
}

/// Memproyeksikan polygon batas ke koordinat layar sesuai kamera aktif.
class _BoundaryClipper extends CustomClipper<Path> {
  final MapCamera camera;
  final List<LatLng> boundary;

  _BoundaryClipper(this.camera, this.boundary);

  @override
  Path getClip(Size size) => Path()
    ..addPolygon([
      for (final p in boundary) camera.latLngToScreenOffset(p),
    ], true);

  @override
  bool shouldReclip(_BoundaryClipper old) =>
      old.camera != camera || !identical(old.boundary, boundary);
}

/// Membangun zona kepadatan organik dari koordinat laporan existing.
///
/// Jika [boundary] diberikan, seluruh area di dalamnya diberi warna hijau
/// dasar dan zona di luarnya tidak ditampilkan.
///
/// Dijalankan sekali (bukan per frame / per pan) — hasilnya di-cache oleh
/// pemanggil. Mengembalikan `null` jika tidak ada yang perlu digambar.
DensityZonesOverlay? buildDensityZones(
  List<ReportGeoData> reports, {
  List<LatLng> boundary = const [],
}) {
  final grid = _computeDensityGrid(reports, boundary);
  if (grid == null) return null;
  return DensityZonesOverlay(
    MemoryImage(_encodePng(grid.pixels, grid.width, grid.height)),
    grid.bounds,
    boundary,
  );
}

// ─────────────────────────────────────────────────────────────────────────────

class _DensityGrid {
  final Uint8List pixels;
  final int width;
  final int height;
  final LatLngBounds bounds;

  _DensityGrid(this.pixels, this.width, this.height, this.bounds);
}

/// Kernel Density Estimation (Gaussian) pada grid lokal dalam meter,
/// lalu normalisasi relatif dan pewarnaan per sel.
_DensityGrid? _computeDensityGrid(
  List<ReportGeoData> reports,
  List<LatLng> boundary,
) {
  final valid = reports
      .where(
        (r) =>
            r.weight > 0 &&
            r.position.latitude.isFinite &&
            r.position.longitude.isFinite,
      )
      .toList(growable: false);
  final hasBoundary = boundary.length >= 3;
  if (valid.isEmpty && !hasBoundary) return null;

  // Proyeksi equirectangular lokal (akurat untuk cakupan ~1–2 km).
  final anchor = valid.isNotEmpty
      ? [for (final r in valid) r.position]
      : boundary;
  double lat0 = 0, lng0 = 0;
  for (final p in anchor) {
    lat0 += p.latitude;
    lng0 += p.longitude;
  }
  lat0 /= anchor.length;
  lng0 /= anchor.length;
  const mPerDegLat = 110574.0;
  final mPerDegLng = 111320.0 * cos(lat0 * pi / 180);

  final n = valid.length;
  final xs = Float64List(n), ys = Float64List(n), ws = Float64List(n);
  for (var i = 0; i < n; i++) {
    xs[i] = (valid[i].position.longitude - lng0) * mPerDegLng;
    ys[i] = (valid[i].position.latitude - lat0) * mPerDegLat;
    ws[i] = valid[i].weight;
  }

  // Bandwidth: Silverman's rule of thumb, dibatasi skala kampus.
  double sx = 0, sy = 0;
  for (var i = 0; i < n; i++) {
    sx += xs[i] * xs[i];
    sy += ys[i] * ys[i];
  }
  final sigma = n == 0 ? 0.0 : sqrt((sx + sy) / (2 * n));
  final h = (n == 0 ? 0.0 : 1.06 * sigma * pow(n, -0.2))
      .clamp(_kMinBandwidthM, _kMaxBandwidthM)
      .toDouble();
  final cutoff = 3 * h;
  final inv2h2 = 1 / (2 * h * h);

  // Batas grid: bbox polygon batas (area di luarnya dipotong), atau
  // bbox titik + padding 3h agar ekor kernel tidak terpotong.
  final bx = Float64List(boundary.length), by = Float64List(boundary.length);
  for (var i = 0; i < boundary.length; i++) {
    bx[i] = (boundary[i].longitude - lng0) * mPerDegLng;
    by[i] = (boundary[i].latitude - lat0) * mPerDegLat;
  }
  var cell = h / _kCellsPerBandwidth;
  double minX, maxX, minY, maxY;
  if (hasBoundary) {
    minX = bx.reduce(min) - cell;
    maxX = bx.reduce(max) + cell;
    minY = by.reduce(min) - cell;
    maxY = by.reduce(max) + cell;
  } else {
    minX = xs.reduce(min) - cutoff;
    maxX = xs.reduce(max) + cutoff;
    minY = ys.reduce(min) - cutoff;
    maxY = ys.reduce(max) + cutoff;
  }
  final longest = max(maxX - minX, maxY - minY);
  if (longest / cell > _kMaxGridSide) cell = longest / _kMaxGridSide;
  final w = ((maxX - minX) / cell).ceil();
  final hgt = ((maxY - minY) / cell).ceil();
  maxX = minX + w * cell;
  maxY = minY + hgt * cell;

  // Akumulasi kernel per titik hanya pada jendela radius 3h (hemat komputasi).
  // Baris 0 = utara (sesuai orientasi gambar).
  final density = Float64List(w * hgt);
  final reach = (cutoff / cell).ceil();
  for (var i = 0; i < n; i++) {
    final cx = ((xs[i] - minX) / cell).floor();
    final cy = ((maxY - ys[i]) / cell).floor();
    for (var row = max(0, cy - reach); row <= min(hgt - 1, cy + reach); row++) {
      final py = maxY - (row + 0.5) * cell;
      final dy = py - ys[i];
      for (var col = max(0, cx - reach); col <= min(w - 1, cx + reach); col++) {
        final dx = minX + (col + 0.5) * cell - xs[i];
        final d2 = dx * dx + dy * dy;
        if (d2 > cutoff * cutoff) continue;
        density[row * w + col] += ws[i] * exp(-d2 * inv2h2);
      }
    }
  }

  // Kepadatan referensi: persentil kepadatan di lokasi laporan (tahan
  // outlier), dengan batas bawah agar dataset kecil tidak dianggap "Tinggi".
  final atPoints = Float64List(n);
  for (var i = 0; i < n; i++) {
    var d = 0.0;
    for (var j = 0; j < n; j++) {
      final dx = xs[i] - xs[j], dy = ys[i] - ys[j];
      final d2 = dx * dx + dy * dy;
      if (d2 <= cutoff * cutoff) d += ws[j] * exp(-d2 * inv2h2);
    }
    atPoints[i] = d;
  }
  atPoints.sort();
  final reference = n == 0
      ? _kMinReferenceMass
      : max(
          atPoints[((n - 1) * _kReferencePercentile).round()],
          _kMinReferenceMass,
        );

  final inside = hasBoundary
      ? _rasterizeInside(bx, by, w, hgt, minX, maxY, cell)
      : null;

  // Pewarnaan: kategori dari kepadatan relatif, dengan transisi lembut.
  final pixels = Uint8List(w * hgt * 4);
  for (var k = 0; k < density.length; k++) {
    final rel = density[k] / reference;
    double tBase;
    if (inside != null) {
      // Dalam batas kampus: minimal hijau dasar; di luar: transparan.
      if (inside[k] == 0) continue;
      tBase = 1;
    } else {
      if (rel < _kBaseThreshold - _kBlendBand) continue;
      tBase = _smooth(_kBaseThreshold, rel);
    }

    final tMed = _smooth(kDensityMediumThreshold, rel);
    final tHigh = _smooth(kDensityHighThreshold, rel);

    var r = _lerp(_kNormal.r, _kMedium.r, tMed);
    var g = _lerp(_kNormal.g, _kMedium.g, tMed);
    var b = _lerp(_kNormal.b, _kMedium.b, tMed);
    var a = _lerp(_kNormal.a, _kMedium.a, tMed);
    r = _lerp(r, _kHigh.r, tHigh);
    g = _lerp(g, _kHigh.g, tHigh);
    b = _lerp(b, _kHigh.b, tHigh);
    a = _lerp(a, _kHigh.a, tHigh) * tBase;

    final o = k * 4;
    pixels[o] = r.round();
    pixels[o + 1] = g.round();
    pixels[o + 2] = b.round();
    pixels[o + 3] = (a * 255).round();
  }

  final bounds = LatLngBounds(
    LatLng(lat0 + minY / mPerDegLat, lng0 + minX / mPerDegLng),
    LatLng(lat0 + maxY / mPerDegLat, lng0 + maxX / mPerDegLng),
  );
  return _DensityGrid(pixels, w, hgt, bounds);
}

/// Mask sel di dalam polygon (scanline even-odd), diperlebar 1 sel agar
/// tidak ada celah transparan di tepi potongan vektor.
Uint8List _rasterizeInside(
  Float64List bx,
  Float64List by,
  int w,
  int hgt,
  double minX,
  double maxY,
  double cell,
) {
  final mask = Uint8List(w * hgt);
  final m = bx.length;
  final crossings = <double>[];
  for (var row = 0; row < hgt; row++) {
    final py = maxY - (row + 0.5) * cell;
    crossings.clear();
    for (var i = 0, j = m - 1; i < m; j = i++) {
      if ((by[i] > py) != (by[j] > py)) {
        crossings.add(bx[i] + (py - by[i]) / (by[j] - by[i]) * (bx[j] - bx[i]));
      }
    }
    crossings.sort();
    for (var c = 0; c + 1 < crossings.length; c += 2) {
      final c0 = max(0, ((crossings[c] - minX) / cell - 0.5).ceil());
      final c1 = min(w - 1, ((crossings[c + 1] - minX) / cell - 0.5).floor());
      for (var col = c0; col <= c1; col++) {
        mask[row * w + col] = 1;
      }
    }
  }
  final out = Uint8List.fromList(mask);
  for (var row = 0; row < hgt; row++) {
    for (var col = 0; col < w; col++) {
      if (mask[row * w + col] == 1) continue;
      var near = false;
      for (var dr = -1; dr <= 1 && !near; dr++) {
        for (var dc = -1; dc <= 1 && !near; dc++) {
          final rr = row + dr, cc = col + dc;
          near =
              rr >= 0 &&
              rr < hgt &&
              cc >= 0 &&
              cc < w &&
              mask[rr * w + cc] == 1;
        }
      }
      if (near) out[row * w + col] = 1;
    }
  }
  return out;
}

/// Smoothstep 0→1 di sekitar [edge] selebar ±[_kBlendBand].
double _smooth(double edge, double x) {
  final t = ((x - (edge - _kBlendBand)) / (2 * _kBlendBand)).clamp(0.0, 1.0);
  return t * t * (3 - 2 * t);
}

double _lerp(num a, num b, double t) => a + (b - a) * t;

/// Encoder PNG RGBA minimal (deflate "stored", tanpa kompresi) dalam Dart
/// murni — sinkron dan tidak bergantung pada backend renderer (Skia/Impeller).
Uint8List _encodePng(Uint8List rgba, int width, int height) {
  // Data mentah: setiap baris diawali byte filter 0 (None).
  final stride = width * 4;
  final raw = Uint8List(height * (stride + 1));
  for (var y = 0; y < height; y++) {
    raw.setRange(
      y * (stride + 1) + 1,
      (y + 1) * (stride + 1),
      rgba,
      y * stride,
    );
  }

  // Zlib stream dengan blok deflate stored (≤ 65535 byte per blok).
  final z = BytesBuilder(copy: false)..add([0x78, 0x01]);
  var off = 0;
  do {
    final len = min(65535, raw.length - off);
    final last = off + len >= raw.length;
    z.add([
      last ? 1 : 0,
      len & 0xFF,
      len >> 8,
      ~len & 0xFF,
      (~len >> 8) & 0xFF,
    ]);
    z.add(Uint8List.sublistView(raw, off, off + len));
    off += len;
  } while (off < raw.length);
  var a = 1, b = 0;
  for (final v in raw) {
    a = (a + v) % 65521;
    b = (b + a) % 65521;
  }
  z.add(_u32((b << 16) | a));

  final ihdr = BytesBuilder()
    ..add(_u32(width))
    ..add(_u32(height))
    ..add([8, 6, 0, 0, 0]); // 8-bit, RGBA

  final out = BytesBuilder(copy: false)
    ..add([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
  _chunk(out, 'IHDR', ihdr.toBytes());
  _chunk(out, 'IDAT', z.toBytes());
  _chunk(out, 'IEND', Uint8List(0));
  return out.toBytes();
}

void _chunk(BytesBuilder out, String type, Uint8List data) {
  final typeBytes = Uint8List.fromList(type.codeUnits);
  out
    ..add(_u32(data.length))
    ..add(typeBytes)
    ..add(data);
  var c = 0xFFFFFFFF;
  for (final list in [typeBytes, data]) {
    for (final v in list) {
      c = _crcTable[(c ^ v) & 0xFF] ^ (c >> 8);
    }
  }
  out.add(_u32(c ^ 0xFFFFFFFF));
}

Uint8List _u32(int v) => Uint8List(4)
  ..[0] = (v >> 24) & 0xFF
  ..[1] = (v >> 16) & 0xFF
  ..[2] = (v >> 8) & 0xFF
  ..[3] = v & 0xFF;

final List<int> _crcTable = List<int>.generate(256, (n) {
  var c = n;
  for (var k = 0; k < 8; k++) {
    c = (c & 1) != 0 ? 0xEDB88320 ^ (c >> 1) : c >> 1;
  }
  return c;
}, growable: false);
