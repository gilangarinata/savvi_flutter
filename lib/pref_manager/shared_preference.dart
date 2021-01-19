import 'package:mylamp_flutter_v4_stable/pref_manager/pref_data.dart';
import 'package:mylamp_flutter_v4_stable/network/model/response/signin_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreference {
  static void setLoginData(UserInfo userInfo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(PrefData.USERNAME, userInfo.username);
    prefs.setString(PrefData.EMAIL, userInfo.email);
    prefs.setString(PrefData.POSITION, userInfo.position);
    prefs.setString(PrefData.REFERRAL, userInfo.referal);
  }

  static void setLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}
