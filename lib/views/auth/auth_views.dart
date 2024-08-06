part of '../views.dart';

class AuthPageViews extends StatefulWidget {
  const AuthPageViews({super.key});

  @override
  State<AuthPageViews> createState() => _AuthPageViewsState();
}

class _AuthPageViewsState extends State<AuthPageViews> {
  // final _sharedPrefs = SharedPreferenceService();

  Future signInWithGoogle() async {
    try {
      // GoogleSignInAccount?
      final googleUser = await GoogleSignIn().signIn();
      // GoogleSignInAuthentication?
      final googleAuth = await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // log('$googleAuth: $credential', name: 'Login');
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (ex) {
      Get.snackbar(
        'MoniFlora Mobile',
        'Failed to login! $ex',
        colorText: kAccentWhite,
        backgroundColor: kAccentRed,
      );
      log('${ex.code}: ${ex.stackTrace}', name: 'Login Error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Platform.isAndroid || Platform.isIOS
              ? SvgPicture.asset(
                  'assets/login-bg.svg',
                  fit: BoxFit.cover,
                )
              : SvgPicture.asset(
                  'assets/login-desktop.svg',
                  fit: BoxFit.cover,
                ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Platform.isAndroid || Platform.isIOS
                  ? Center(
                      child: SvgPicture.asset(
                        'assets/logo-image.svg',
                        height: 75.w,
                        width: 75.w,
                      ),
                    )
                  : Center(
                      child: SvgPicture.asset(
                        'assets/logo-image.svg',
                        height: 60.w,
                        width: 60.w,
                      ),
                    ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () async {
                  await signInWithGoogle();

                  if (FirebaseAuth.instance.currentUser != null) {
                    Get.snackbar(
                      'MoniFlora',
                      'Welcome back, ${FirebaseAuth.instance.currentUser?.displayName}!',
                      colorText: kAccentBlack,
                      backgroundColor: kAccentGrey,
                    );

                    Get.off(
                      () => const HomePageViews(),
                      transition: Transition.leftToRight,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  fixedSize: Platform.isAndroid || Platform.isIOS
                      ? Size(1.sw - 140.w, 45.h)
                      : Size(1.sw - 240.w, 60.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    side: BorderSide(
                      color: kAccentBlack,
                      width: 0.3.w,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: Platform.isAndroid || Platform.isIOS
                      ? MainAxisAlignment.spaceEvenly
                      : MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: Brand(
                        Brands.google,
                        size: Platform.isAndroid || Platform.isIOS
                            ? 24.sp
                            : 14.sp,
                      ),
                    ),
                    Text(
                      'Login with Google',
                      style: TextStyle(
                        fontSize:
                            Platform.isAndroid || Platform.isIOS ? 14.sp : 8.sp,
                        color: kAccentBlack,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
