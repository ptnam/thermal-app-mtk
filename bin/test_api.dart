/// =============================================================================
/// File: test_api.dart
/// Description: Pure Dart API test script - runs without Flutter
///
/// Usage: dart run bin/test_api.dart
/// =============================================================================

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

/// Test configuration
const String baseUrl = 'https://thermal.infosysvietnam.com.vn:10253';
const String username = 'NPQ';
const String password = 'Npq@456';

void main() async {
  print('═══════════════════════════════════════════════════════════');
  print('                    API TEST RUNNER                         ');
  print('═══════════════════════════════════════════════════════════\n');

  // Setup Dio with SSL bypass
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    },
  );

  String? accessToken;

  // ═══════════════════════════════════════════════════════════════════════════
  // TEST 1: Login
  // ═══════════════════════════════════════════════════════════════════════════
  print('📌 TEST 1: Login API');
  print('───────────────────────────────────────────────────────────');

  try {
    final loginResponse = await dio.post(
      '/api/Auth/login',
      data: {'username': username, 'password': password},
    );

    if (loginResponse.statusCode == 200) {
      accessToken = loginResponse.data['accessToken'];
      print('✅ Login SUCCESS');
      print('   Token: ${accessToken?.substring(0, 30)}...');
      print('   User: ${loginResponse.data['userName']}');
    }
  } on DioException catch (e) {
    print('❌ Login FAILED: ${e.response?.statusCode}');
    print('   Response: ${e.response?.data}');
    return;
  } catch (e) {
    print('❌ Login FAILED: $e');
    return;
  }

  if (accessToken == null) {
    print('Cannot continue tests without access token');
    return;
  }

  dio.options.headers['Authorization'] = 'Bearer $accessToken';

  // ═══════════════════════════════════════════════════════════════════════════
  // TEST 2: Notification List
  // ═══════════════════════════════════════════════════════════════════════════
  print('\n📌 TEST 2: Notification List API');
  print('───────────────────────────────────────────────────────────');

  try {
    final fromTime = DateTime.now().subtract(const Duration(days: 7));
    final fromTimeStr =
        '${fromTime.year}-${fromTime.month.toString().padLeft(2, '0')}-${fromTime.day.toString().padLeft(2, '0')} '
        '${fromTime.hour.toString().padLeft(2, '0')}:${fromTime.minute.toString().padLeft(2, '0')}:${fromTime.second.toString().padLeft(2, '0')}';

    final notifResponse = await dio.get(
      '/api/Notifications/list',
      queryParameters: {
        'FromTime': fromTimeStr,
        'Page': 1,
        'PageSize': 10,
      },
    );

    if (notifResponse.statusCode == 200) {
      final data = notifResponse.data;
      print('✅ Notification List SUCCESS');
      print('   Total Records: ${data['totalRow']}');
      print('   Page: ${data['pageIndex']}');
      print('   Items Count: ${(data['items'] as List).length}');

      if ((data['items'] as List).isNotEmpty) {
        final first = data['items'][0];
        print('   First Item:');
        print('     - ID: ${first['id']}');
        print('     - Area: ${first['areaName']}');
        print('     - Machine: ${first['machineName']}');
        print('     - Warning: ${first['warningEventName']}');
        print('     - Value: ${first['componentValue']}°C');
      }
    }
  } catch (e) {
    print('❌ Notification List FAILED: $e');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TEST 3: Notification Brief
  // ═══════════════════════════════════════════════════════════════════════════
  print('\n📌 TEST 3: Notification Brief API');
  print('───────────────────────────────────────────────────────────');

  try {
    final briefResponse = await dio.get(
      '/api/Notifications/lastestBrief',
      queryParameters: {'NumberOfRecord': 5},
    );

    if (briefResponse.statusCode == 200) {
      final data = briefResponse.data;
      print('✅ Notification Brief SUCCESS');
      print('   Total: ${data['total']}');
      print('   Notifications: ${(data['notifications'] as List).length}');
    }
  } catch (e) {
    print('❌ Notification Brief FAILED: $e');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TEST 4: Area Tree
  // ═══════════════════════════════════════════════════════════════════════════
  print('\n📌 TEST 4: Area Tree API');
  print('───────────────────────────────────────────────────────────');

  try {
    final areaResponse = await dio.get(
      '/api/Areas/allTree',
      queryParameters: {'cameras': true},
    );

    if (areaResponse.statusCode == 200) {
      final data = areaResponse.data;
      if (data is List) {
        print('✅ Area Tree SUCCESS');
        print('   Areas Count: ${data.length}');
        if (data.isNotEmpty) {
          final first = data[0];
          print('   First Area:');
          print('     - ID: ${first['id']}');
          print('     - Name: ${first['name']}');
          print('     - Children: ${(first['children'] as List?)?.length ?? 0}');
          print('     - Cameras: ${(first['cameras'] as List?)?.length ?? 0}');
        }
      }
    }
  } catch (e) {
    print('❌ Area Tree FAILED: $e');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TEST 5: Camera List
  // ═══════════════════════════════════════════════════════════════════════════
  print('\n📌 TEST 5: Camera List API');
  print('───────────────────────────────────────────────────────────');

  try {
    final cameraResponse = await dio.get('/api/Cameras/all');

    if (cameraResponse.statusCode == 200) {
      final data = cameraResponse.data;
      if (data is List) {
        print('✅ Camera List SUCCESS');
        print('   Cameras Count: ${data.length}');
        if (data.isNotEmpty) {
          final first = data[0];
          print('   First Camera:');
          print('     - ID: ${first['id']}');
          print('     - Code: ${first['code']}');
          print('     - Name: ${first['name']}');
        }
      }
    }
  } catch (e) {
    print('❌ Camera List FAILED: $e');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TEST 6: Sensor Types
  // ═══════════════════════════════════════════════════════════════════════════
  print('\n📌 TEST 6: Sensor Types API');
  print('───────────────────────────────────────────────────────────');

  try {
    final sensorTypeResponse = await dio.get('/api/SensorTypes');

    if (sensorTypeResponse.statusCode == 200) {
      final data = sensorTypeResponse.data;
      if (data is List) {
        print('✅ Sensor Types SUCCESS');
        print('   Types Count: ${data.length}');
        if (data.isNotEmpty) {
          final first = data[0];
          print('   First Type:');
          print('     - ID: ${first['id']}');
          print('     - Name: ${first['name']}');
        }
      }
    }
  } catch (e) {
    print('❌ Sensor Types FAILED: $e');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TEST 7: Machine Types
  // ═══════════════════════════════════════════════════════════════════════════
  print('\n📌 TEST 7: Machine Types API');
  print('───────────────────────────────────────────────────────────');

  try {
    final machineTypeResponse = await dio.get('/api/MachineTypes');

    if (machineTypeResponse.statusCode == 200) {
      final data = machineTypeResponse.data;
      if (data is List) {
        print('✅ Machine Types SUCCESS');
        print('   Types Count: ${data.length}');
        if (data.isNotEmpty) {
          final first = data[0];
          print('   First Type:');
          print('     - ID: ${first['id']}');
          print('     - Name: ${first['name']}');
        }
      }
    }
  } catch (e) {
    print('❌ Machine Types FAILED: $e');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SUMMARY
  // ═══════════════════════════════════════════════════════════════════════════
  print('\n═══════════════════════════════════════════════════════════');
  print('                    TEST COMPLETE                           ');
  print('═══════════════════════════════════════════════════════════\n');
}
