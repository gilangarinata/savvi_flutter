import 'package:flutter/material.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_button.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_colors.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_strings.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_text.dart';
import 'package:mylamp_flutter_v4_stable/ui/signin/signin_screen.dart';
import 'package:mylamp_flutter_v4_stable/ui/signup/signup_screen.dart';
import 'package:mylamp_flutter_v4_stable/utils/tools.dart';

class IntroductionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Image.asset('assets/new_wallpaper_3.jpeg',fit: BoxFit.cover,),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 150),
              child: Image.asset('assets/logo.png',width: 130,),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height / 2,
              decoration: new BoxDecoration(
                  borderRadius: new BorderRadius.only(
                    topLeft: const Radius.circular(40.0),
                    topRight: const Radius.circular(40.0),
                  ),
                  color: Colors.white),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Image.asset('assets/logo2.png',width: 180,),
                    SizedBox(height: 10,),
                    MyText.myTextHeader1(
                        MyStrings.introHeader, MyColors.grey_80),
                    SizedBox(
                      height: 10,
                    ),
                    MyText.myTextDescription(
                        MyStrings.introDescription, MyColors.grey_60),
                    SizedBox(
                      height: 20,
                    ),
                    // Container(
                    //   width: double.infinity,
                    //   child: MyButton.myPrimaryButton(
                    //     MyStrings.createAccount,
                    //     () {
                    //       Tools.addScreen(context, SignUpScreen());
                    //     },
                    //   ),
                    // ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: double.infinity,
                      child:
                          MyButton.myNegativeButton(MyStrings.loginWithId, () {
                        Tools.addScreen(context, SignInScreen());
                      }),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
