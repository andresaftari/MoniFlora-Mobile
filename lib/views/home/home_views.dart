part of '../views.dart';

class HomePageViews extends StatefulWidget {
  const HomePageViews({super.key});

  @override
  State<HomePageViews> createState() => _HomePageViewsState();
}

class _HomePageViewsState extends State<HomePageViews> {
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
              Color.fromRGBO(40, 180, 70, 1),
              Color.fromRGBO(154, 255, 194, 1),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
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
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      onChanged: (value) {
                        _sharedPrefs.putString(
                          'plantName',
                          value.toString(),
                        );

                        log(_sharedPrefs.getString('plantName'));
                      },
                      decoration: InputDecoration(
                        isDense: true,
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 0.8,
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 0.8,
                          ),
                        ),
                        hintText: 'Nama Tanaman',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                        ),
                        suffixIcon: const Icon(
                          HeroIcons.pencil,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Column(
                    children: [
                      Container(
                        width: 64.w,
                        height: 64.h,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Synced',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32.h),
                  Container(
                    width: 1.sw,
                    height: 1.sh - 280.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(48.r),
                        topRight: Radius.circular(48.r),
                      ),
                      color: Colors.white,
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
}
