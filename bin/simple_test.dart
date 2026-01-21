import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

void main() async {
  print('API Test Start');

  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://thermal.infosysvietnam.com.vn:10253',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    },
  );

  try {
    print('Sending login request...');
    final response = await dio.post(
      '/api/Auth/login',
      data: {'username': 'thangdv', 'password': 'Aa@12345'},
    );
    print('Login success: ${response.statusCode}');
    print('Response: ${response.data}');
  } on DioException catch (e) {
    print('Login failed: ${e.response?.statusCode}');
    print('Error data: ${e.response?.data}');
    print('Error message: ${e.message}');
  } catch (e) {
    print('Error: $e');
  }
  
  print('API Test End');
}
