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
          Image.asset(
            'assets/login-bg.png',
            fit: BoxFit.fill,
            scale: 0.5,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(child: Image.asset('assets/thumbnail.png')),
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
                  fixedSize: Size(1.sw - 140.w, 45.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    side: BorderSide(
                      color: kAccentBlack,
                      width: 0.5.w,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Brand(
                      Brands.google,
                      size: 24.sp,
                    ),
                    Text(
                      'Login with Google',
                      style: TextStyle(
                        fontSize: 14.sp,
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
