// Part
import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:skripsyit/data/api/controller/sensor_controller.dart';
import 'package:skripsyit/data/api/response/sensor_response.dart';
import 'package:skripsyit/data/local/model/sensor.dart';
import 'package:skripsyit/utils/color_theme.dart';
import 'package:skripsyit/utils/shared_prefs.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

part 'auth/auth_views.dart';
part 'home/home_views.dart';
