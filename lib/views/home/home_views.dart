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
  Widget build(BuildContext context) {
    // log('${FirebaseAuth.instance.currentUser}', name: 'Login');

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
            return _controller.sensorObs.value != null
                ? Center(
                    child: CircularProgressIndicator.adaptive(),
                  )
                : SafeArea(
                    bottom: false,
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await _controller.getSingleLatestValue();

                        // String uuid = _sharedPrefs.getString('sensor_uuid');
                        // Sensor? data = await _controller.fetchLatestData(uuid);

                        // if (data != null) {
                        //   temperature.value = data.temperature;
                        //   intensity.value = data.light;
                        //   conductivity.value = data.conductivity;
                        //   moisture.value = data.moisture;
                        // } else {
                        //   Get.snackbar(
                        //     'MoniFlora',
                        //     'Fetch no dataset monitored!',
                        //     colorText: kAccentBlack,
                        //     backgroundColor: kAccentGrey,
                        //   );
                        // }
                      },
                      child: SingleChildScrollView(
                        // physics: const NeverScrollableScrollPhysics(),
                        child: Container(
                          padding: EdgeInsets.only(top: 16.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
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
                              Text(
                                'Synced',
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  color: kAccentWhite,
                                  fontWeight: FontWeight.bold,
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
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: 1.sw,
                                      child: buildCardAmbience(),
                                    ),
                                    SizedBox(
                                      width: 1.sw,
                                      child: buildCardSoil(),
                                    ),
                                    SizedBox(
                                      width: 1.sw,
                                      child: buildCardOverview(),
                                    ),
                                  ],
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

  Card buildCardAmbience() {
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
                      '${_controller.temperatureObs.value}˚C',
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
                      '${_controller.intensityObs.value} lx',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: _controller.intensityObs.value >= 3000 &&
                                _controller.intensityObs.value <= 5000
                            ? kPrimaryGreen
                            : _controller.intensityObs.value > 5000 &&
                                        _controller.intensityObs.value <=
                                            6500 ||
                                    _controller.intensityObs.value >= 1500 &&
                                        _controller.intensityObs.value < 3000
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

  Card buildCardSoil() {
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
                      '-',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: kAccentRed,
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
