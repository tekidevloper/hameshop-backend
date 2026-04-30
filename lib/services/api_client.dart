import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio _dio;
  late final CacheStore _cacheStore;
  late final CacheOptions _cacheOptions;

  // ===================================================================
  // SERVER CONFIG
  // Local development server - phone must be on the same WiFi network.
  // Change this IP to your machine's local IP if it changes.
  // ===================================================================
  static const String _baseUrl = 'https://hameshop-backend-8.onrender.com/api';

  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 120),
      receiveTimeout: const Duration(seconds: 120),
    ));

    // ---------------------------------------------------------------
    // FIX: Bypass SSL certificate errors on physical Android devices.
    // This is needed because some older Android versions don't trust
    // newer SSL certificate chains. Render.com uses a valid cert but
    // older devices may still reject it.
    // ---------------------------------------------------------------
    if (!kIsWeb) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? token;
        if (kIsWeb) {
          final prefs = await SharedPreferences.getInstance();
          token = prefs.getString('jwt_token');
        } else {
          token = await _storage.read(key: 'jwt_token');
        }

        if (kDebugMode) {
          debugPrint('ApiClient: ${options.method} ${options.path} - Token: ${token != null ? "Present" : "Missing"}');
        }
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (kDebugMode) {
          debugPrint('ApiClient Error: ${e.requestOptions.method} ${e.requestOptions.path} -> ${e.response?.statusCode} ${e.message}');
        }

        // Auto-retry logic for Render "wake up" phase and Web CORS/Network errors
        bool isNetworkError = e.type == DioExceptionType.connectionTimeout ||
                              e.type == DioExceptionType.receiveTimeout ||
                              e.type == DioExceptionType.connectionError ||
                              e.type == DioExceptionType.unknown;

        if (isNetworkError || e.response?.statusCode == 503 || e.response?.statusCode == 502) {
           int retries = e.requestOptions.extra['retries'] ?? 0;
           if (retries < 5) { // Increased to 5 retries
             debugPrint('Server might be sleeping or connecting. Retrying... (Attempt ${retries + 1})');
             // Exponential backoff: 2s, 4s, 8s, 16s, 32s
             await Future.delayed(Duration(seconds: 2 * (retries + 1)));
             e.requestOptions.extra['retries'] = retries + 1;
             try {
               final response = await _dio.fetch(e.requestOptions);
               return handler.resolve(response);
             } catch (retryError) {
               return handler.next(retryError as DioException);
             }
           }
        }

        return handler.next(e);
      },
    ));

    _initCache();
  }

  Future<void> _initCache() async {
    if (kIsWeb) {
      _cacheOptions = CacheOptions(
        store: MemCacheStore(),
        policy: CachePolicy.noCache,
      );
      _dio.interceptors.add(DioCacheInterceptor(options: _cacheOptions));
      return;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      _cacheStore = HiveCacheStore(dir.path);
      _cacheOptions = CacheOptions(
        store: _cacheStore,
        policy: CachePolicy.refreshForceCache,
        hitCacheOnErrorExcept: [401, 403],
        maxStale: const Duration(days: 7),
        priority: CachePriority.normal,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Cache initialization error: $e');
      _cacheOptions = CacheOptions(
        store: MemCacheStore(),
        policy: CachePolicy.noCache,
      );
    }
    _dio.interceptors.add(DioCacheInterceptor(options: _cacheOptions));
  }

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  Dio get dio => _dio;

  Future<void> saveToken(String token) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
    }
    await _storage.write(key: 'jwt_token', value: token);
  }

  Future<void> deleteToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_token');
    }
    await _storage.delete(key: 'jwt_token');
  }

  Future<String?> getToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('jwt_token');
    }
    return await _storage.read(key: 'jwt_token');
  }
}
