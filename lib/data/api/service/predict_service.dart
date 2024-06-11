import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:skripsyit/data/api/response/predict.dart';
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
    try {
      final response = await dio.post(
        'http://andresaftari.pythonanywhere.com/predict',
        data: {
          'temperature': temperature,
          'light': light,
          'conductivity': ec,
          'moisture': moisture,
        },
        options: Options(
          followRedirects: false,
          // will not throw errors
          validateStatus: (status) => true,
        ),
      );

      log('$response', name: 'coba');
      if (response.statusCode == 200) {
        return Right(Prediction.fromJson(response.data));
      } else {
        return Left(Failed(response.statusCode.toString()));
      }
    } catch (e) {
      log(e.toString(), name: 'predict-service');
      return Left(Failed(e.toString()));
    }
  }
}
