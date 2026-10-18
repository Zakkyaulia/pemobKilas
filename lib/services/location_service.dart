import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Status proses penguncian GPS.
enum GpsLockStatus {
  initial,
  locating,
  locked,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  error,
}

/// Model data koordinat GPS yang berhasil terkunci.
class GpsLocationData {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final String locationName;
  final String formattedCoordinates;
  final DateTime lockedAt;

  const GpsLocationData({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    required this.locationName,
    required this.formattedCoordinates,
    required this.lockedAt,
  });
}

/// Service untuk menangani izin lokasi, pengecekan GPS aktif, dan penguncian koordinat real.
class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  /// Periksa apakah layanan GPS pada perangkat aktif.
  Future<bool> isGpsEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Periksa status izin lokasi saat ini.
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Minta izin lokasi kepada pengguna.
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Buka pengaturan GPS perangkat agar pengguna dapat mengaktifkannya.
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Buka pengaturan aplikasi untuk memberikan izin lokasi secara manual.
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Mengunci posisi koordinat GPS pengguna secara presisi.
  ///
  /// Menjamin bahwa GPS aktif dan izin telah diberikan.
  Future<Position> lockCurrentPosition() async {
    // 1. Validasi Layanan GPS
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const GpsServiceDisabledException(
        'Layanan lokasi (GPS) perangkat belum aktif. Silakan aktifkan GPS perangkat Anda terlebih dahulu.',
      );
    }

    // 2. Validasi Izin Akses Lokasi
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const GpsPermissionDeniedException(
          'Izin akses lokasi ditolak. Aplikasi membutuhkan izin GPS untuk mencatat koordinat asli laporan.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const GpsPermissionPermanentlyDeniedException(
        'Izin akses lokasi ditolak permanen. Silakan buka Pengaturan Aplikasi untuk mengizinkan akses lokasi.',
      );
    }

    // 3. Ambil posisi GPS akurat
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } catch (_) {
      // Fallback ke posisi terakhir jika di dalam ruangan / sinyal GPS lambat
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        return lastKnown;
      }
      rethrow;
    }
  }

  /// Mengubah koordinat (lat, lng) menjadi nama tempat/gedung yang mudah dipahami.
  /// Menggunakan reverse-geocoding dengan fallback graceful jika offline.
  Future<String?> reverseGeocode(double lat, double lng) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 4);
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1',
      );
      final request = await client.getUrl(uri);
      request.headers.set(
        'User-Agent',
        'pemob_kilas/1.0 (contact: zakky@unand.ac.id)',
      );
      final response = await request.close().timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final data = jsonDecode(body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>?;

        if (address != null) {
          final place = address['amenity'] ??
              address['building'] ??
              address['university'] ??
              address['office'] ??
              address['shop'];
          final road =
              address['road'] ?? address['pedestrian'] ?? address['path'];
          final area = address['suburb'] ??
              address['neighbourhood'] ??
              address['village'] ??
              address['city_district'];

          if (place != null && road != null) {
            return '$place, $road';
          } else if (place != null && area != null) {
            return '$place, $area';
          } else if (road != null && area != null) {
            return '$road, $area';
          } else if (place != null) {
            return '$place';
          } else if (road != null) {
            return '$road';
          }
        }

        final displayName = data['display_name'] as String?;
        if (displayName != null && displayName.isNotEmpty) {
          final parts = displayName.split(',');
          if (parts.length >= 2) {
            return '${parts[0].trim()}, ${parts[1].trim()}';
          }
          return parts[0].trim();
        }
      }
    } catch (e) {
      debugPrint('Reverse geocoding tidak dapat diakses (offline/timeout): $e');
    }
    return null;
  }
}

class GpsServiceDisabledException implements Exception {
  final String message;
  const GpsServiceDisabledException(this.message);
  @override
  String toString() => message;
}

class GpsPermissionDeniedException implements Exception {
  final String message;
  const GpsPermissionDeniedException(this.message);
  @override
  String toString() => message;
}

class GpsPermissionPermanentlyDeniedException implements Exception {
  final String message;
  const GpsPermissionPermanentlyDeniedException(this.message);
  @override
  String toString() => message;
}
