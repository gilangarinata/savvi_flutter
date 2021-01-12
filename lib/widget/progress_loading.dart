import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_colors.dart';

class ProgressLoading extends StatelessWidget {
  double size;
  double stroke;
  Color color;
  bool isDark;

  ProgressLoading(
      {this.size = 30, this.stroke = 3, this.color = MyColors.primary, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size,
        height: size,
        child: Platform.isIOS ? Theme(data: ThemeData(cupertinoOverrideTheme: CupertinoThemeData(brightness: isDark ? Brightness.dark : Brightness.light)),
            child: CupertinoActivityIndicator()) : CircularProgressIndicator(strokeWidth: stroke)
      ),
    );
  }
}
