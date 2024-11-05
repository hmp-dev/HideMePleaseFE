import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/constants/storage.dart';
import 'package:mobile/app/core/env/app_env.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/storage/secure_storage.dart';
import 'package:mobile/features/app/presentation/cubit/app_cubit.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

@singleton
class Network {
  final SecureStorage _secureStorage;

  Network(this._secureStorage);

  late final TalkerDioLogger talkerDioLogger;

  Dio? dio;

  @PostConstruct(preResolve: true)
  Future<void> initialize() async {
    final talker = getIt<Talker>();

    talkerDioLogger = TalkerDioLogger(
      talker: talker,
      settings: const TalkerDioLoggerSettings(
        printResponseData: true,
        printResponseHeaders: false,
        printResponseMessage: true,
        printErrorData: true,
        printErrorHeaders: true,
        printErrorMessage: true,
        printRequestData: true,
        printRequestHeaders: true,
      ),
    );

    dio = Dio(BaseOptions(
      baseUrl: appEnv.apiUrl,
      connectTimeout: const Duration(seconds: 45),
      receiveTimeout: const Duration(seconds: 45),
      headers: {'user-agent': 'Dio/4.0.6'},
    ))
      ..interceptors.add(InterceptorsWrapper(
        onRequest: onEveryRequest,
        onError: onEveryRequestError,
      ))
      ..interceptors.add(talkerDioLogger);
  }

  Future<Response> post(String url, Object? data) => dio!.post(url, data: data);

  Future<Response> get(String url, Map<String, String> params) =>
      dio!.get(url, queryParameters: params);

  Future<Response> put(String url, Object? data) => dio!.put(url, data: data);

  Future<Response<T>> request<T>(String url, String method, data) async {
    final response = await dio!.request<T>(
      url,
      data: data,
      options: Options(method: method),
    );

    return response;
  }

  Future<void> onEveryRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // const String yanDaneToke =
    //     "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI4MTMyNGQxMC0yNTMwLTQwOGMtYTQ2YS0zMDEyZGM0ODBkZTkiLCJpYXQiOjE3MzAyNjEzNTYsImV4cCI6MTczMjg5MTM1Nn0.-TURDyMMGRzyNsdFgMQAgO4CjSeFgo1NBeiukYGXsk0";

    // const String iXplorerToken =
    //     "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJhNGRjMTljNC05Y2I0LTRjYTUtOGVlNi03NGYwZTJjZTc5N2EiLCJpYXQiOjE3MjgzNzU0NjcsImV4cCI6MTczMTAwNTQ2N30.6z1siIy9JeWMyfHNQLJQvOn1J3WOkcj7EUQOVxKcrsk";

    const String pppizzaToken =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI1MjU3MjYxOC02NzBkLTQ1NzgtYjI5MS04MzcxMTBlY2ZhODEiLCJpYXQiOjE3MzA3MDU1MTAsImV4cCI6MTczMzMzNTUxMH0.85II8RsCy5SoIBZcqJyz5WRP96TH6bAPOsQNuQA-X4c";
    final accessToken = await _secureStorage.read(StorageValues.accessToken);

    options.headers['Authorization'] = 'Bearer $accessToken';

    handler.next(options);
  }

  Future<void> onEveryRequestError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    // Logout the User If Token invalid
    if (error.response?.statusCode == 400 &&
        error.response?.data['message'] is List &&
        error.response?.data['message'].contains("Token invalid")) {
      getIt<AppCubit>().onLogOut();
    }

    if (error.response?.statusCode == 401) {
      try {
        //await _refreshAccessToken();
        getIt<AppCubit>().onLogOut();
      } on DioException catch (_) {
        // TODO Implement logout
        return;
      }

      try {
        var response = await dio!.request(
          error.requestOptions.path,
          data: error.requestOptions.data,
          queryParameters: error.requestOptions.queryParameters,
          options: Options(
            method: error.requestOptions.method,
            headers: error.requestOptions.headers,
          ),
        );
        return handler.resolve(response);
      } on DioException catch (err) {
        return handler.next(err);
      }
    }

    if (error.type == DioExceptionType.badResponse) {
      return handler.next(DioException(
        requestOptions: error.requestOptions,
        response: error.response,
        error: error.response?.data["errorMessage"],
        type: error.type,
      ));
    }

    if (error.message?.contains("SocketException") ?? false) {
      return handler.next(DioException(
        requestOptions: error.requestOptions,
        response: error.response,
        error: "It appears you don't have internet. Please try again later.",
        type: error.type,
      ));
    }

    return handler.next(error);
  }

  Future refreshAccessToken() async {
    final refreshToken = await _secureStorage.read(StorageValues.refreshToken);
    if (refreshToken != null) {
      final response = await request(
        '/access-token',
        'POST',
        {'refreshToken': refreshToken},
      );

      //Save new token
      await _secureStorage.write(
          StorageValues.accessToken, response.data['accessToken']);
    }
  }
}
