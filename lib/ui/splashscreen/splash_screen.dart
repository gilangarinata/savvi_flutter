import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mylamp_flutter_v4_stable/pref_manager/pref_data.dart';
import 'package:mylamp_flutter_v4_stable/ui/dashboard/dashboard_screen.dart';
import 'package:mylamp_flutter_v4_stable/ui/filter/filter_screen.dart';
import 'package:mylamp_flutter_v4_stable/ui/introduction/introduction.dart';
import 'package:mylamp_flutter_v4_stable/utils/tools.dart';
import 'package:mylamp_flutter_v4_stable/widget/progress_loading.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    Future<void> _getPrefData() async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isLoggedIn = await prefs.containsKey(PrefData.USER_ID);
      print(isLoggedIn.toString());
      if (isLoggedIn) {
          Tools.changeScreen(context, FilterScreen());
          // Tools.finish(context);
        } else {
          Tools.changeScreen(context, IntroductionScreen());
          // Tools.finish(context);
        }
    }

    Timer(Duration(seconds: 3), (){
      _getPrefData();
    });
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              "assets/logo.png",
              width: 250,
            ),
            SizedBox(
              height: 50,
            ),
            ProgressLoading(
              size: 13,
              stroke: 2,
            )
          ],
        ),
      ),
    );
  }
}

