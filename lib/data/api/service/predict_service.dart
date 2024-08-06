import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:retry/retry.dart';
import 'package:skripsyit/data/api/response/predict_response.dart';
import 'package:skripsyit/data/failed.dart';

class PredictService {
  final Dio dio;

  PredictService(this.dio);

  Future<Either<Failed, Prediction>> postPredictionParam({
    required double temperature,
    required double light,
    required double ec,
    required double moisture,
  }) async {
    const r = RetryOptions(
      maxAttempts: 3, // Number of retry attempts
      delayFactor: Duration(seconds: 1), // Delay between retries
    );

    try {
      final response = await r.retry(
        () => dio
            .post(
              'http://andresaftari.pythonanywhere.com/predict',
              data: {
                'temperature': temperature,
                'light': light,
                'conductivity': ec,
                'moisture': moisture,
              },
              options: Options(
                followRedirects: true,
                validateStatus: (status) => true,
              ),
            )
            .timeout(const Duration(minutes: 5)),
        retryIf: (e) => e is DioException && _shouldRetry(e),
      );

      // log('$response', name: 'coba');
      if (response.statusCode == 200) {
        return Right(Prediction.fromJson(response.data));
      } else {
        return Left(Failed(response.statusCode.toString()));
      }
    } catch (e) {
      // log(e.toString(), name: 'predict-service');
      return Left(Failed(e.toString()));
    }
  }

  bool _shouldRetry(DioException e) {
    // Retry for network errors, timeouts, or server errors (5xx status codes)
    return e.type == DioExceptionType.unknown ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        (e.response?.statusCode != null && e.response!.statusCode! >= 500) ||
        e.response?.statusCode == 502;
  }
}
