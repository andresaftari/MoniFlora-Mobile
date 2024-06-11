class Prediction {
  final String prediction;
  final int predictionIndex;
  final List<double> probability;

  Prediction({
    required this.prediction,
    required this.predictionIndex,
    required this.probability,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) => Prediction(
        prediction: json["prediction"],
        predictionIndex: json["prediction_index"],
        probability:
            List<double>.from(json["probability"].map((x) => x?.toDouble())),
      );

  Map<String, dynamic> toJson() => {
        "prediction": prediction,
        "prediction_index": predictionIndex,
        "probability": List<dynamic>.from(probability.map((x) => x)),
      };

  @override
  String toString() {
    return 'Prediction(prediction: $prediction, predictionIndex: $predictionIndex, probability: $probability)';
  }
}
