import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Tools {
  static Navigator changeScreen(BuildContext context, Widget destination) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => destination,
      ),
    );
  }

  static Navigator addScreen(BuildContext context, Widget destination) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => destination,
      ),
    );
  }

  static void finish(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      SystemNavigator.pop();
    }
  }

  static void showToast(String message){
    Fluttertoast.showToast(msg: message);
  }

  static void stackTracer(StackTrace stackTrace, String message, int code) {
    print("   ");
    print("   ");
    print("   ");
    print(
        "============================= MESSAGE : $message ======================================");
    print(
        "============================== CODE : $code =============================================");
    print(StackTrace.current);
    print("   ");
    print("   ");
    print("   ");
  }
}
