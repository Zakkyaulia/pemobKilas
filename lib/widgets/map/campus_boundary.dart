import 'package:latlong2/latlong.dart';

/// Batas wilayah pemantauan kampus Universitas Andalas (hardcode).
///
/// Didigitasi dari garis batas yang digambar pengguna di atas screenshot
/// peta aplikasi (termasuk dua area tambahan: jalan lingkar timur laut
/// dekat FMIPA dan area antara Jalan Lingkar dan RS Unand), lalu dikonversi
/// ke koordinat via proyeksi Web Mercator. Akurasi perkiraan ±10–20 m.
/// Ring tertutup implisit
/// (titik terakhir tersambung kembali ke titik pertama).
class CampusBoundary {
  CampusBoundary._();

  static const List<LatLng> unand = [
    LatLng(-0.907670, 100.461158),
    LatLng(-0.907663, 100.461463),
    LatLng(-0.907745, 100.461640),
    LatLng(-0.908470, 100.462175),
    LatLng(-0.908959, 100.462284),
    LatLng(-0.909976, 100.462745),
    LatLng(-0.910512, 100.462752),
    LatLng(-0.910431, 100.462860),
    LatLng(-0.910417, 100.462942),
    LatLng(-0.910336, 100.463078),
    LatLng(-0.910309, 100.463349),
    LatLng(-0.910281, 100.463362),
    LatLng(-0.910254, 100.463634),
    LatLng(-0.910227, 100.463647),
    LatLng(-0.910214, 100.463729),
    LatLng(-0.910227, 100.463919),
    LatLng(-0.910254, 100.463932),
    LatLng(-0.910281, 100.464081),
    LatLng(-0.910309, 100.464095),
    LatLng(-0.910390, 100.464298),
    LatLng(-0.910458, 100.464366),
    LatLng(-0.910485, 100.464448),
    LatLng(-0.910675, 100.464624),
    LatLng(-0.910675, 100.464651),
    LatLng(-0.910770, 100.464733),
    LatLng(-0.910783, 100.464787),
    LatLng(-0.911041, 100.465031),
    LatLng(-0.911150, 100.465207),
    LatLng(-0.911319, 100.465363),
    LatLng(-0.911536, 100.465363),
    LatLng(-0.911652, 100.465275),
    LatLng(-0.911713, 100.465160),
    LatLng(-0.911964, 100.465858),
    LatLng(-0.912201, 100.466028),
    LatLng(-0.913490, 100.465933),
    LatLng(-0.914100, 100.465770),
    LatLng(-0.914588, 100.465268),
    LatLng(-0.915029, 100.465099),
    LatLng(-0.915368, 100.464353),
    LatLng(-0.915701, 100.464020),
    LatLng(-0.916976, 100.464047),
    LatLng(-0.917125, 100.463993),
    LatLng(-0.917322, 100.463647),
    LatLng(-0.917335, 100.463118),
    LatLng(-0.917417, 100.462833),
    LatLng(-0.917668, 100.462487),
    LatLng(-0.918326, 100.461992),
    LatLng(-0.919153, 100.461016),
    LatLng(-0.919370, 100.460595),
    LatLng(-0.919370, 100.460500),
    LatLng(-0.919499, 100.460588),
    LatLng(-0.919635, 100.460602),
    LatLng(-0.919648, 100.460629),
    LatLng(-0.919906, 100.460629),
    LatLng(-0.919920, 100.460602),
    LatLng(-0.920028, 100.460588),
    LatLng(-0.920232, 100.460480),
    LatLng(-0.920605, 100.460107),
    LatLng(-0.920632, 100.460025),
    LatLng(-0.920754, 100.459876),
    LatLng(-0.920781, 100.459781),
    LatLng(-0.920822, 100.459754),
    LatLng(-0.920890, 100.459564),
    LatLng(-0.920971, 100.459483),
    LatLng(-0.920985, 100.459415),
    LatLng(-0.921066, 100.459293),
    LatLng(-0.921202, 100.458845),
    LatLng(-0.921229, 100.458831),
    LatLng(-0.921297, 100.458601),
    LatLng(-0.921324, 100.458587),
    LatLng(-0.921337, 100.458397),
    LatLng(-0.921202, 100.458262),
    LatLng(-0.921609, 100.457923),
    LatLng(-0.922138, 100.457312),
    LatLng(-0.922260, 100.457082),
    LatLng(-0.922450, 100.456525),
    LatLng(-0.922735, 100.455074),
    LatLng(-0.922707, 100.454151),
    LatLng(-0.922612, 100.453907),
    LatLng(-0.922416, 100.453751),
    LatLng(-0.922050, 100.453751),
    LatLng(-0.920856, 100.453995),
    LatLng(-0.920286, 100.454022),
    LatLng(-0.920028, 100.453955),
    LatLng(-0.919730, 100.453765),
    LatLng(-0.919709, 100.453717),
    LatLng(-0.919899, 100.453365),
    LatLng(-0.921012, 100.452306),
    LatLng(-0.922192, 100.450353),
    LatLng(-0.923264, 100.449173),
    LatLng(-0.923562, 100.448617),
    LatLng(-0.923630, 100.448250),
    LatLng(-0.923576, 100.447762),
    LatLng(-0.923298, 100.447660),
    LatLng(-0.922606, 100.447755),
    LatLng(-0.922192, 100.448115),
    LatLng(-0.921459, 100.449702),
    LatLng(-0.920306, 100.451398),
    LatLng(-0.919343, 100.452510),
    LatLng(-0.918190, 100.454138),
    LatLng(-0.917491, 100.454796),
    LatLng(-0.916800, 100.455257),
    LatLng(-0.915511, 100.455827),
    LatLng(-0.914656, 100.456329),
    LatLng(-0.913327, 100.456573),
    LatLng(-0.910614, 100.457997),
    LatLng(-0.909881, 100.458594),
    LatLng(-0.908986, 100.459557),
    LatLng(-0.908029, 100.460202),
    LatLng(-0.907758, 100.460690),
  ];

  /// True jika [point] berada di dalam batas kampus (ray casting even-odd).
  static bool contains(LatLng point) {
    final x = point.longitude, y = point.latitude;
    var inside = false;
    for (var i = 0, j = unand.length - 1; i < unand.length; j = i++) {
      final a = unand[i], b = unand[j];
      if ((a.latitude > y) != (b.latitude > y) &&
          x <
              a.longitude +
                  (y - a.latitude) /
                      (b.latitude - a.latitude) *
                      (b.longitude - a.longitude)) {
        inside = !inside;
      }
    }
    return inside;
  }
}
