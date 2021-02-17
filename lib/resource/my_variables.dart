import 'package:flutter_flavor/flutter_flavor.dart';

class MyVariables {
  Map<String, String> myVars(FlavorEnvironment status) {
    if (status == FlavorEnvironment.PROD) {
      Map<String, String> prodFlavor = {
        baseUrl: "vlrs2.savvi.id:3008",
        signUp: "/users/signup",
        signIn: "/users/login",
        device: "/devices/",
        updateLamp: "/devices/update_lamp",
        hardware: "/hardware",
        updateBrightness: "/devices/update_brightness",
        schedule: "/schedule",
        getUserReferal: "/users/getUserReferal",
        getUserQuery: "/users/getGoverment",
        getStreet: "/devices/streets",
        getDeviceV3: "/devices/v3",
        getAllUserAdmin: "/users/getAllUserAdmin",
        addReferalFrom: "/users/addReferalFrom",
      };
      return prodFlavor;
    } else {
      Map<String, String> devFlavor = {
        baseUrl: "192.168.108.20:8000",
        signUp: "/users/signup",
        signIn: "/users/login",
        device: "/devices",
        updateLamp: "/devices/update_lamp",
        hardware: "/hardware",
        updateBrightness: "/devices/update_brightness",
        schedule: "/schedule",
        getUserReferal: "/users/getUserReferal",
        getUserQuery: "/users/getGoverment",
        getStreet: "/devices/streets",
        getDeviceV3: "/devices/v3",
        getAllUserAdmin: "/users/getAllUserAdmin",
        addReferalFrom: "/users/addReferalFrom",
      };
      return devFlavor;
    }
  }

  static const String baseUrl = "base_url";
  static const String signUp = "sign_up";
  static const String signIn = "sign_in";
  static const String device = "device";
  static const String hardware = "hardware";
  static const String schedule = "schedule";
  static const String updateLamp = "updateLamp";
  static const String updateBrightness = "updateBrigtness";
  static const String getUserReferal = "getUserReferal";
  static const String getUserQuery = "getUserQuery";
  static const String getStreet = "getUserStreet";
  static const String getDeviceV3 = "getDeviceV3";
  static const String getAllUserAdmin = "getAllUserAdmin";
  static const String addReferalFrom = "addReferalFrom";
}
