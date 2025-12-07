import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import 'storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  ApiService._internal() {
    initialize();
  }

  late final Dio _dio;
  final StorageService _storageService = StorageService();
  bool _isRefreshing = false;

  void initialize() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Skip auth for public endpoints
          final publicEndpoints = [
            '/token',
            '/register',
            '/forgot-password',
            '/reset-password',
          ];
          if (publicEndpoints.any(
            (endpoint) => options.path.contains(endpoint),
          )) {
            return handler.next(options);
          }

          // Add token for protected endpoints
          final token = await _storageService.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
       onError: (error, handler) async {
      // Handle 401 Unauthorized (token expired)
      if (error.response?.statusCode == 401) {
        // ❌ PROBLEM: Tries to refresh for EVERY 401, including login failures!
        // Try to refresh token
        final refreshed = await _refreshToken();
        if (refreshed) {
          // Retry the request
          final options = error.requestOptions;
          final token = await _storageService.getAccessToken();
          options.headers['Authorization'] = 'Bearer $token';

          try {
            final response = await _dio.fetch(options);
            return handler.resolve(response);
          } catch (e) {
            return handler.reject(error);
          }
        }
      }
      return handler.next(error);
    },

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await Dio().post(
        ApiConstants.refreshToken,
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access'];
        await _storageService.saveTokens(
          accessToken: newAccessToken,
          refreshToken: refreshToken,
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> uploadFile(
    String path,
    String filePath, {
    Map<String, dynamic>? data,
    String fieldName = 'image',
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        ...?data,
      });

      final response = await _dio.post(
        path,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';

      case DioExceptionType.badResponse:
        if (error.response?.data is Map) {
          final data = error.response?.data as Map<String, dynamic>;
          if (data.containsKey('detail')) {
            return data['detail'].toString();
          }
          if (data.containsKey('error')) {
            return data['error'].toString();
          }
          if (data.isNotEmpty) {
            final firstError = data.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              return firstError.first.toString();
            }
            return firstError.toString();
          }
        }
        return 'Server error: ${error.response?.statusCode}';

      case DioExceptionType.cancel:
        return 'Request cancelled';

      case DioExceptionType.connectionError:
        return 'No internet connection';

      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
