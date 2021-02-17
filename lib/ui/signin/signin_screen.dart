import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mylamp_flutter_v4_stable/network/model/request/signin_request.dart';
import 'package:mylamp_flutter_v4_stable/network/repository/auth_repository.dart';
import 'package:mylamp_flutter_v4_stable/pref_manager/pref_data.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_button.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_colors.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_field_style.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_strings.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_text.dart';
import 'package:mylamp_flutter_v4_stable/ui/filter/filter_screen.dart';
import 'package:mylamp_flutter_v4_stable/ui/signin/signin_bloc.dart';
import 'package:mylamp_flutter_v4_stable/ui/signin/signin_contract.dart';
import 'package:mylamp_flutter_v4_stable/utils/validator.dart';
import 'package:mylamp_flutter_v4_stable/widget/my_snackbar.dart';
import 'package:mylamp_flutter_v4_stable/widget/progress_loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SignInBloc>(
          create: (context) => SignInBloc(AuthRepositoryImpl()),
        )
      ],
      child: SignInContent(),
    );
  }
}

class SignInContent extends StatefulWidget {
  @override
  _SignInContentState createState() => _SignInContentState();
}

class _SignInContentState extends State<SignInContent> {
  SignInBloc _bloc;
  TextEditingController _usernameController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _bloc = BlocProvider.of<SignInBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: BlocListener<SignInBloc, SignInState>(
          listener: (context, state) async {
            if (state is InitialState) {
              setState(() {
                _isLoading = true;
              });
            } else if (state is LoadingState) {
              setState(() {
                _isLoading = true;
              });
            } else if (state is ErrorState) {
              setState(() {
                _isLoading = false;
                MySnackbar.errorSnackbar(context, state.message);
              });
            } else if (state is LoadedState) {
              setState(() {
                _isLoading = false;
              });
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString(PrefData.USER_ID, state.items.userInfo.id);
              prefs.setString(PrefData.EMAIL, state.items.userInfo.email);
              prefs.setString(PrefData.REFERRAL, state.items.userInfo.referal);
              prefs.setString(PrefData.POSITION, state.items.userInfo.position);
              prefs.setString(PrefData.USERNAME, state.items.userInfo.username);
              prefs.setString(
                  PrefData.REFERAL_FROM, state.items.userInfo.referalFrom);
              List<String> newReferalFrom = [];
              for (String fr in state.items.userInfo.referalFrom2) {
                if (fr != null) {
                  newReferalFrom.add(fr);
                }
              }
              prefs.setStringList(PrefData.REFERAL_FROM_2, newReferalFrom);
              prefs.setString(PrefData.TOKEN, state.items.token);

              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => FilterScreen()),
                  ModalRoute.withName("/Home"));
            }
          },
          child: Container(
            color: Colors.white,
            child: Stack(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Image.asset(
                    "assets/img_login.jpg",
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Image.asset('assets/logo.png',width: 170,),
                          SizedBox(height: 10,),
                          MyText.myTextHeader1(
                              MyStrings.signInPage, MyColors.grey_80),
                          TextFormField(
                            controller: _usernameController,
                            style: MyFieldStyle.myFieldStylePrimary(),
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value.isEmpty) {
                                return MyStrings.mustNotBeEmpty;
                              }
                              return null;
                            },
                            cursorColor: MyColors.primary,
                            decoration: InputDecoration(
                              icon: Container(
                                  child:
                                      Icon(Icons.person, color: MyColors.grey_60),
                                  margin: EdgeInsets.fromLTRB(0, 15, 0, 0)),
                              labelText: MyStrings.username,
                              labelStyle: MyFieldStyle.myFieldLabelStylePrimary(),
                              enabledBorder: MyFieldStyle.myUnderlineFieldStyle(),
                              focusedBorder:
                                  MyFieldStyle.myUnderlineFocusFieldStyle(),
                            ),
                          ),
                          TextFormField(
                            controller: _passwordController,
                            style: MyFieldStyle.myFieldStylePrimary(),
                            validator: (value) {
                              if (value.isEmpty) {
                                return MyStrings.mustNotBeEmpty;
                              } else {
                                if (!Validator.passwordValidation(value)) {
                                  return MyStrings.passwordValidation;
                                }
                              }
                              return null;
                            },
                            keyboardType: TextInputType.text,
                            obscureText: true,
                            cursorColor: MyColors.primary,
                            decoration: InputDecoration(
                              icon: Container(
                                  child: Icon(Icons.vpn_key,
                                      color: MyColors.grey_60),
                                  margin: EdgeInsets.fromLTRB(0, 15, 0, 0)),
                              labelText: MyStrings.password,
                              labelStyle: MyFieldStyle.myFieldLabelStylePrimary(),
                              enabledBorder: MyFieldStyle.myUnderlineFieldStyle(),
                              focusedBorder:
                                  MyFieldStyle.myUnderlineFocusFieldStyle(),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: double.infinity,
                            height: 50,
                            child: Stack(
                              children: <Widget>[
                                Visibility(
                                  visible: !_isLoading,
                                  child: Container(
                                    width: double.infinity,
                                    child: MyButton.myPrimaryButton(
                                      MyStrings.signIn,
                                      () {
                                        if (_formKey.currentState.validate()) {
                                          SignInRequest request =
                                              new SignInRequest(
                                                  _usernameController.text.trim(),
                                                  _passwordController.text
                                                      .trim());
                                          _bloc.add(
                                              FetchSignIn(request.reqBody()));
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Visibility(
                                    visible: _isLoading,
                                    child: ProgressLoading(
                                      size: 13,
                                      stroke: 2,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
