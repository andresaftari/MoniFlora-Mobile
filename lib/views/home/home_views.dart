part of '../views.dart';

class HomePageViews extends StatefulWidget {
  const HomePageViews({super.key});

  @override
  State<HomePageViews> createState() => _HomePageViewsState();
}

class _HomePageViewsState extends State<HomePageViews> {
  final SensorController _controller = Get.find();

  final _sharedPrefs = SharedPreferenceService();
  final _nameController = TextEditingController();

  @override
  void initState() {
    _controller.onInit();
    super.initState();
  }

  String setWarning() {
    if (_controller.sensorObs.value != null) {
      double temp = _controller.sensorObs.value!.temperature;
      int light = _controller.sensorObs.value!.light;
      int moisture = _controller.sensorObs.value!.moisture;
      int ec = _controller.sensorObs.value!.conductivity;

      List<String> warnings = [];

      if (temp < 22) {
        warnings.add('Temp LOW');
      } else if (temp > 27) {
        warnings.add('Temp HIGH');
      }

      if (light < 3500) {
        warnings.add('Light LOW');
      } else if (light > 5000) {
        warnings.add('Light HIGH');
      }

      if (moisture < 35) {
        warnings.add('Moisture LOW');
      } else if (moisture > 50) {
        warnings.add('Moisture HIGH');
      }

      if (ec < 1800) {
        warnings.add('EC LOW');
      } else if (ec > 2400) {
        warnings.add('EC HIGH');
      }

      String warning;
      if (warnings.isEmpty) {
        warning = '-';
      } else if (warnings.length == 4 &&
          warnings.every((w) => w.contains('LOW'))) {
        warning = 'All Params LOW';
      } else if (warnings.length == 4 &&
          warnings.every((w) => w.contains('HIGH'))) {
        warning = 'All Params HIGH';
      } else {
        warning = warnings.join('\n');
      }

      log('warning: $warning - ${warnings.length}', name: 'home-views');

      return warning;
    }

    return '-';
  }

  @override
  Widget build(BuildContext context) {
    if (!_sharedPrefs.checkKey('plantName') ||
        _sharedPrefs.getString('plantName') != '') {
      _nameController.text = _sharedPrefs.getString('plantName');
    }

    return Scaffold(
      body: Container(
        width: 1.sw,
        height: 1.sh,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              kPrimaryGreen,
              kSecondaryGreen,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const ScrollPhysics(),
            child: Container(
              padding: EdgeInsets.only(top: 4.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      margin: EdgeInsets.only(right: 16.w),
                      child: ElevatedButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();

                          Get.off(() => const AuthPageViews());
                        },
                        style: ElevatedButton.styleFrom(elevation: 0),
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Image.asset(
                    'assets/app-icon.png',
                    scale: 0.75,
                  ),
                  SizedBox(height: 8.h),
                  SizedBox(
                    width: 165.w,
                    child: TextFormField(
                      maxLines: 1,
                      maxLength: 16,
                      textAlign: TextAlign.center,
                      controller: _nameController,
                      style: const TextStyle(
                        overflow: TextOverflow.ellipsis,
                        color: kAccentWhite,
                        fontWeight: FontWeight.bold,
                      ),
                      onChanged: (value) {
                        _sharedPrefs.putString(
                          'plantName',
                          value.toString(),
                        );
                      },
                      decoration: InputDecoration(
                        isDense: true,
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: kAccentWhite,
                            width: 0.8,
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: kAccentWhite,
                            width: 0.8,
                          ),
                        ),
                        hintText: 'Nama Tanaman',
                        hintStyle: TextStyle(
                          color: kAccentWhite.withOpacity(0.4),
                        ),
                        suffixIcon: const Icon(
                          HeroIcons.pencil,
                          color: kAccentWhite,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Obx(
                    () => _controller.sensorObs.value != null
                        ? Text(
                            'Synced',
                            style: TextStyle(
                              fontSize: 20.sp,
                              color: kAccentWhite,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Text(
                            'Not Synced',
                            style: TextStyle(
                              fontSize: 20.sp,
                              color: kAccentWhite,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    width: 1.sw,
                    height: 1.sh,
                    padding: EdgeInsets.only(
                      top: 24.h,
                      right: 16.w,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(48.r),
                        topRight: Radius.circular(48.r),
                      ),
                      color: kAccentWhite,
                    ),
                    child: StreamBuilder<Sensor?>(
                      stream: _controller.getSingleLatestValue(),
                      builder: (context, snapshot) {
                        if (snapshot.data != null && snapshot.hasData) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 1.sw - 24.w,
                                child: buildCardAmbience(
                                  snapshot.data!.temperature.toDouble(),
                                  snapshot.data!.light,
                                ),
                              ),
                              SizedBox(
                                width: 1.sw - 24.w,
                                child: buildCardSoil(
                                  snapshot.data!.conductivity,
                                  snapshot.data!.moisture,
                                ),
                              ),
                              SizedBox(
                                width: 1.sw - 24.w,
                                child: buildCardOverview(
                                  moisture: snapshot.data!.moisture.toDouble(),
                                  ec: snapshot.data!.conductivity.toDouble(),
                                  temperature: snapshot.data!.temperature,
                                  light: snapshot.data!.light.toDouble(),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              // StreamBuilder<List<SensorResponse>>(
                              //   stream: _controller.getAllSensor(),
                              //   builder: (context, snapshot) {
                              //     if (snapshot.hasData) {
                              //       final sensorData = snapshot.data!;

                              //       return SizedBox(
                              //         height: Platform.isIOS
                              //             ? 200.h
                              //             : Platform.isAndroid
                              //                 ? 220.h
                              //                 : 240.h,
                              //         width: 1.sw,
                              //         child: SfCartesianChart(
                              //           primaryXAxis: DateTimeAxis(
                              //             dateFormat: DateFormat('MMM yyyy'),
                              //             intervalType:
                              //                 DateTimeIntervalType.auto,
                              //             enableAutoIntervalOnZooming: true,
                              //           ),
                              //           zoomPanBehavior: ZoomPanBehavior(
                              //             enablePanning: true,
                              //             enablePinching: true,
                              //             maximumZoomLevel: 0.5,
                              //             enableDoubleTapZooming: true,
                              //             zoomMode: ZoomMode.xy,
                              //           ),
                              //           enableAxisAnimation: true,
                              //           series: [
                              //             LineSeries<SensorResponse, DateTime>(
                              //               dataSource: sensorData,
                              //               xValueMapper: (data, _) => DateTime
                              //                   .fromMillisecondsSinceEpoch(
                              //                       data.dateTime),
                              //               yValueMapper: (data, _) =>
                              //                   data.conductivity,
                              //               name: 'EC',
                              //               color: kPrimaryGreen,
                              //               width: 1.5,
                              //             ),
                              //           ],
                              //           legend: const Legend(
                              //             isVisible: true,
                              //             position: LegendPosition.bottom,
                              //           ),
                              //           tooltipBehavior: TooltipBehavior(
                              //             enable: true,
                              //             shouldAlwaysShow: true,
                              //           ),
                              //         ),
                              //       );
                              //     }

                              //     return const Text('No data');
                              //   },
                              // ),
                              StreamBuilder<List<SensorResponse>>(
                                stream: _controller.getAllSensor(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    final sensorData = snapshot.data!;

                                    // Get the latest 100 data points
                                    final latestSensorData =
                                        sensorData.length > 50
                                            ? sensorData
                                                .sublist(sensorData.length - 50)
                                            : sensorData;

                                    final filteredData = latestSensorData
                                        .where((data) => data.light > 600)
                                        .toList();

                                    return SizedBox(
                                      height: Platform.isIOS
                                          ? 200.h
                                          : Platform.isAndroid
                                              ? 220.h
                                              : 240.h,
                                      width: 1.sw,
                                      child: SfCartesianChart(
                                        title: ChartTitle(
                                          text:
                                              'Latest 50 EC Fluctuation (μS/cm)',
                                          textStyle: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        primaryXAxis: DateTimeAxis(
                                          dateFormat: DateFormat('MMM yyyy'),
                                          intervalType:
                                              DateTimeIntervalType.hours,
                                          enableAutoIntervalOnZooming: true,
                                        ),
                                        zoomPanBehavior: ZoomPanBehavior(
                                          enablePanning: true,
                                          enablePinching: true,
                                          enableDoubleTapZooming: true,
                                          zoomMode: ZoomMode.xy,
                                        ),
                                        enableAxisAnimation: true,
                                        series: [
                                          LineSeries<SensorResponse, DateTime>(
                                            dataSource: filteredData,
                                            xValueMapper: (data, _) => DateTime
                                                .fromMillisecondsSinceEpoch(
                                              data.dateTime,
                                            ),
                                            yValueMapper: (data, _) =>
                                                data.conductivity,
                                            name: 'EC',
                                            color: kPrimaryGreen,
                                            width: 1.5,
                                          ),
                                        ],
                                        legend: const Legend(
                                          isVisible: true,
                                          position: LegendPosition.bottom,
                                        ),
                                        tooltipBehavior: TooltipBehavior(
                                          enable: true,
                                          shouldAlwaysShow: true,
                                        ),
                                      ),
                                    );
                                  }

                                  return const Text('No data');
                                },
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 1.sw - 24.w,
                                child: buildCardAmbience(0.0, 0),
                              ),
                              SizedBox(
                                width: 1.sw - 24.w,
                                child: buildCardSoil(0, 0),
                              ),
                              SizedBox(
                                width: 1.sw - 24.w,
                                child: buildCardOverview(
                                  temperature: 0.0,
                                  moisture: 0.0,
                                  light: 0.0,
                                  ec: 0.0,
                                ),
                              ),
                              SizedBox(height: 16.h),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Card buildCardAmbience(double temp, int light) {
    return Card(
      elevation: 1,
      child: Container(
        color: kAccentWhite,
        padding: EdgeInsets.only(
          top: 4.h,
          right: 24.w,
          left: 24.w,
          bottom: 8.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ambience',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Lingkungan',
              style: TextStyle(
                fontSize: 14.sp,
                color: kAccentBlack.withOpacity(0.5),
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              height: 0.2.h,
              width: 1.sw,
              color: kAccentBlack,
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'Temperature',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$temp ˚C',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: _controller.temperatureObs.value >= 22 &&
                                _controller.temperatureObs.value <= 27
                            ? kPrimaryGreen
                            : _controller.temperatureObs.value > 27 &&
                                        _controller.temperatureObs.value <=
                                            30 ||
                                    _controller.temperatureObs.value >= 20 &&
                                        _controller.temperatureObs.value < 22
                                ? kAccentYellow
                                : kAccentRed,
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 50.h,
                  width: 0.2.w,
                  color: kAccentBlack,
                ),
                Column(
                  children: [
                    Text(
                      'Light Intensity',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$light lx',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: _controller.intensityObs.value >= 3500 &&
                                _controller.intensityObs.value <= 5000
                            ? kPrimaryGreen
                            : _controller.intensityObs.value > 5000 &&
                                        _controller.intensityObs.value <=
                                            6500 ||
                                    _controller.intensityObs.value >= 1500 &&
                                        _controller.intensityObs.value < 3500
                                ? kAccentYellow
                                : kAccentRed,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Card buildCardSoil(int ec, int moisture) {
    return Card(
      elevation: 1,
      child: Container(
        color: kAccentWhite,
        padding: EdgeInsets.only(
          top: 4.h,
          right: 24.w,
          left: 24.w,
          bottom: 8.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Soil',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Tanah',
              style: TextStyle(
                fontSize: 14.sp,
                color: kAccentBlack.withOpacity(0.5),
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              height: 0.2.h,
              width: 1.sw,
              color: kAccentBlack,
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'Conductivity',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_controller.conductivityObs.value} µS/cm',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: _controller.conductivityObs.value >= 1800 &&
                                _controller.conductivityObs.value <= 2400
                            ? kPrimaryGreen
                            : _controller.conductivityObs.value > 2000 &&
                                        _controller.conductivityObs.value <=
                                            3000 ||
                                    _controller.conductivityObs.value >= 950 &&
                                        _controller.conductivityObs.value < 1500
                                ? kAccentYellow
                                : kAccentRed,
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 50.h,
                  width: 0.2.w,
                  color: kAccentBlack,
                ),
                Column(
                  children: [
                    Text(
                      'Soil Moisture',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_controller.moistureObs.value} %',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: _controller.moistureObs.value >= 35 &&
                                _controller.moistureObs.value <= 50
                            ? kPrimaryGreen
                            : _controller.moistureObs.value > 50 &&
                                        _controller.moistureObs.value <= 60 ||
                                    _controller.moistureObs.value >= 30 &&
                                        _controller.moistureObs.value < 35
                                ? kAccentYellow
                                : kAccentRed,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Card buildCardOverview({
    required double temperature,
    required double moisture,
    required double light,
    required double ec,
  }) {
    return Card(
      elevation: 1,
      child: Container(
        color: kAccentWhite,
        padding: EdgeInsets.only(
          top: 16.h,
          right: 24.w,
          left: 24.w,
          bottom: 8.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overview',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Ringkasan',
              style: TextStyle(
                fontSize: 14.sp,
                color: kAccentBlack.withOpacity(0.5),
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              height: 0.2.h,
              width: 1.sw,
              color: kAccentBlack,
            ),
            SizedBox(height: 4.h),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'Condition',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                StreamBuilder(
                  stream: _controller.postPrediction(
                    temperature: temperature,
                    light: light,
                    ec: ec,
                    moisture: moisture,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Text(
                          snapshot.data!.prediction,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: _controller.conditionObs.value == 'Optimal'
                                ? kPrimaryGreen
                                : _controller.conditionObs.value == 'Caution'
                                    ? kAccentYellow
                                    : kAccentRed,
                          ),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                    }

                    return const Center(child: CircularProgressIndicator());
                  },
                ),
                SizedBox(height: 8.h),
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Warning',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Use Wrap widget for displaying warnings
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8, // space between items
                        runSpacing: 4, // space between lines
                        children: setWarningsWidgets(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// Convert warnings to a list of widgets
  List<Widget> setWarningsWidgets() {
    final warnings = setWarning().split('\n');

    return warnings.map((warning) {
      return Container(
        padding: EdgeInsets.all(4.r),
        child: Text(
          warning,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
            color: warnings.length <= 2 || warnings.length == 1
                ? kAccentYellow
                : warnings.length >= 3
                    ? kAccentRed
                    : kAccentBlack,
          ),
        ),
      );
    }).toList();
  }
}
