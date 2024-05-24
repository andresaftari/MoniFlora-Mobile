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

  String setWarning() {
    RxString warning = '-'.obs;

    if (_controller.sensorObs.value != null) {
      double temp = _controller.sensorObs.value!.temperature;
      int light = _controller.sensorObs.value!.light;
      int moisture = _controller.sensorObs.value!.moisture;
      int ec = _controller.sensorObs.value!.conductivity;

      if (temp >= 22 && temp <= 27) {
        warning.value = '-';
      } else {
        warning.value = 'Temp should be 22°C to 27°C';
      }

      if (light >= 3500 && light <= 5000) {
        warning.value = '-';
      } else {
        warning.value = 'Light should be 3500lx to 5000lx';
      }

      if (moisture >= 35 && moisture <= 50) {
        warning.value = '-';
      } else {
        warning.value = 'Moisture should be 35% to 50%';
      }

      if (ec >= 1500 && ec <= 1000) {
        warning.value = '-';
      } else {
        warning.value = 'EC should be 1500 to 2000';
      }
    }

    return warning.value;
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(minutes: 5), () {
      _controller.predictLatestData();
    });

    // log('${_controller.outputs}', name: 'outputs');

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
        child: Obx(
          () {
            return _controller.sensorObs.value == null
                ? SafeArea(
                    child: SizedBox(
                      height: 1.sh,
                      width: 1.sw,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: CircularProgressIndicator.adaptive(),
                          ),
                          Text(
                            'Syncing data...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  )
                : SafeArea(
                    bottom: false,
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await _controller.trainAndTestRF();
                        await _controller.predictLatestData();
                      },
                      child: SingleChildScrollView(
                        // physics: const NeverScrollableScrollPhysics(),
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
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                    ),
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

                                    // log(
                                    //   _sharedPrefs.getString('plantName'),
                                    //   name: 'home-views-plantname',
                                    // );
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
                                height: 1.sh - 200.h,
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
                                    if (snapshot.data != null &&
                                        snapshot.hasData) {
                                      return Column(
                                        children: [
                                          SizedBox(
                                            width: 1.sw,
                                            child: buildCardAmbience(
                                              snapshot.data!.temperature
                                                  .toDouble(),
                                              snapshot.data!.light,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 1.sw,
                                            child: buildCardSoil(
                                              snapshot.data!.conductivity,
                                              snapshot.data!.moisture,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 1.sw,
                                            child: buildCardOverview(),
                                          ),
                                        ],
                                      );
                                    } else {
                                      return Column(
                                        children: [
                                          SizedBox(
                                            width: 1.sw,
                                            child: buildCardAmbience(0.0, 0),
                                          ),
                                          SizedBox(
                                            width: 1.sw,
                                            child: buildCardSoil(0, 0),
                                          ),
                                          SizedBox(
                                            width: 1.sw,
                                            child: buildCardOverview(),
                                          ),
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
                  );
          },
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
          top: 16.h,
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
          top: 16.h,
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
                        color: _controller.conductivityObs.value >= 1500 &&
                                _controller.conductivityObs.value <= 2000
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

  Card buildCardOverview() {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'Warning',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '-',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: kAccentRed,
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
                      'Condition',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_controller.conditionObs}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: _controller.conditionObs.value == 'Optimal'
                            ? kPrimaryGreen
                            : _controller.conditionObs.value == 'Caution'
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
}
