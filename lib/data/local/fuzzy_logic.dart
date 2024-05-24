class FuzzyLogic {
  String classifyTemperature(double temp) {
    if (temp >= 22 && temp <= 27) {
      return 'Optimal';
    }

    if ((temp > 27 && temp <= 30) || (temp >= 20 && temp < 22)) {
      return 'Caution';
    }

    return 'Extreme';
  }

  String classifyIntensity(int light) {
    if (light >= 3000 && light <= 5000) {
      return 'Optimal';
    }

    if ((light > 5000 && light <= 6500) || (light >= 1500 && light < 2000)) {
      return 'Caution';
    }

    return 'Extreme';
  }

  String classifyEC(int ec) {
    if (ec >= 1500 && ec <= 2000) {
      return "Optimal";
    }

    if ((ec > 2000 && ec <= 3000) || (ec >= 950 && ec < 1500)) {
      return "Caution";
    }

    return "Extreme";
  }

  String classifyMoisture(int moisture) {
    if (moisture >= 35 && moisture <= 50) {
      return "Optimal";
    }

    if ((moisture > 50 && moisture <= 60) ||
        (moisture >= 30 && moisture < 35)) {
      return "Caution";
    }

    return "Extreme";
  }
}
