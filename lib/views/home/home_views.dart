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

  RxDouble temperature = 26.5.obs;
  RxInt intensity = 1200.obs;
  RxInt conductivity = 2000.obs;
  RxInt moisture = 46.obs;

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
        child: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: () async {
              log('test');
              await _controller.getSingleLatestValue();
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

                          log(
                            _sharedPrefs.getString('plantName'),
                            name: 'home-views-plantname',
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
                      '$temperature˚C',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: temperature > 21 && temperature <= 26
                            ? kPrimaryGreen
                            : temperature > 26 && temperature <= 30
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
                      '$intensity lx',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: intensity > 3000 && intensity <= 5000
                            ? kPrimaryGreen
                            : intensity > 5000 && intensity <= 6500
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
                      '$conductivity µS/cm',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: conductivity > 1500 && conductivity <= 2000
                            ? kPrimaryGreen
                            : conductivity > 2000 && conductivity <= 3000
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
                      '$moisture %',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: moisture > 40 && moisture <= 50
                            ? kPrimaryGreen
                            : moisture > 50 && moisture <= 60
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
                      '-temp, +intensity',
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
                      'EXTREME',
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
