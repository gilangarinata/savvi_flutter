import 'package:flutter/material.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_colors.dart';

class MyButton {
  static RaisedButton myPrimaryButton(String title, Function onPressed) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(color: MyColors.primary)),
      onPressed: onPressed,
      padding: EdgeInsets.symmetric(vertical: 10),
      color: MyColors.primary,
      textColor: Colors.white,
      child: Text(title.toUpperCase(), style: TextStyle(fontSize: 14)),
    );
  }

  static RaisedButton myNegativeButton(String title, Function onPressed) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(color: MyColors.primary)),
      onPressed: onPressed,
      padding: EdgeInsets.symmetric(vertical: 10),
      color: Colors.white,
      textColor: MyColors.primary,
      child: Text(title.toUpperCase(), style: TextStyle(fontSize: 14)),
    );
  }
}
