import 'package:flutter/material.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_colors.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_strings.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_text.dart';

class NegativeScenarioView extends StatelessWidget {
  String message;
  bool isDark;
  Function onRetry;

  NegativeScenarioView(this.message, this.isDark, this.onRetry);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? MyColors.brownDark : Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 50,),
            Image(image: AssetImage("assets/negative_image.png"), width: 250,),
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: getErrorData(message),
            ),
            SizedBox(height: 20,),
            FlatButton(onPressed: onRetry, child: MyText.myTextDescription("Retry", Colors.white), color: MyColors.primary,)
          ],
        ),
      ),
    );
  }

  Widget getErrorData(String message){
    if(message.contains("Connection")){
      return MyText.myTextHeader2(MyStrings.cannotReachServer, isDark ? Colors.white : MyColors.brownDark);
    }else{
      return MyText.myTextHeader2(MyStrings.cannotReachServer, isDark ? Colors.white : MyColors.brownDark);
    }
  }

}
