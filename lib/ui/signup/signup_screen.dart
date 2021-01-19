import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mylamp_flutter_v4_stable/network/model/request/signup_request.dart';
import 'package:mylamp_flutter_v4_stable/network/repository/auth_repository.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_button.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_colors.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_field_style.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_strings.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_text.dart';
import 'package:mylamp_flutter_v4_stable/ui/signup/signup_bloc.dart';
import 'package:mylamp_flutter_v4_stable/ui/signup/signup_contract.dart';
import 'package:mylamp_flutter_v4_stable/utils/validator.dart';
import 'package:mylamp_flutter_v4_stable/widget/my_snackbar.dart';
import 'package:mylamp_flutter_v4_stable/widget/progress_loading.dart';

class SignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SignUpBloc>(
          create: (context) => SignUpBloc(AuthRepositoryImpl()),
        )
      ],
      child: SignUpContent(),
    );
  }
}

class SignUpContent extends StatefulWidget {
  @override
  _SignUpContentState createState() => _SignUpContentState();
}

class _SignUpContentState extends State<SignUpContent> {
  SignUpBloc _bloc;
  TextEditingController _usernameController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _referralController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _bloc = BlocProvider.of<SignUpBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: BlocListener<SignUpBloc, SignUpState>(
          listener: (context, state) {
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
              MySnackbar.successSnackbar(context, MyStrings.signUpSuccess);
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
                    "assets/img_register.jpg",
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
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
                              MyStrings.signUpPage, MyColors.grey_80),
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
                            controller: _emailController,
                            validator: (value) {
                              if (value.isEmpty) {
                                return MyStrings.mustNotBeEmpty;
                              } else {
                                if (!Validator.emailValidation(value)) {
                                  return MyStrings.validEmail;
                                }
                              }
                              return null;
                            },
                            style: MyFieldStyle.myFieldStylePrimary(),
                            keyboardType: TextInputType.text,
                            cursorColor: MyColors.primary,
                            decoration: InputDecoration(
                              icon: Container(
                                  child:
                                      Icon(Icons.mail, color: MyColors.grey_60),
                                  margin: EdgeInsets.fromLTRB(0, 15, 0, 0)),
                              labelText: MyStrings.email,
                              labelStyle: MyFieldStyle.myFieldLabelStylePrimary(),
                              enabledBorder: MyFieldStyle.myUnderlineFieldStyle(),
                              focusedBorder:
                                  MyFieldStyle.myUnderlineFocusFieldStyle(),
                            ),
                          ),
                          TextFormField(
                            controller: _referralController,
                            validator: (value) {
                              if (value.isEmpty) {
                                return MyStrings.mustNotBeEmpty;
                              }
                              return null;
                            },
                            style: MyFieldStyle.myFieldStylePrimary(),
                            keyboardType: TextInputType.text,
                            cursorColor: MyColors.primary,
                            decoration: InputDecoration(
                              icon: Container(
                                  child: Icon(Icons.person_add,
                                      color: MyColors.grey_60),
                                  margin: EdgeInsets.fromLTRB(0, 15, 0, 0)),
                              labelText: MyStrings.referral,
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
                                      MyStrings.createAccount,
                                      () {
                                        if (_formKey.currentState.validate()) {
                                          SignUpRequest request =
                                              new SignUpRequest(
                                                  _usernameController.text.trim(),
                                                  _passwordController.text.trim(),
                                                  _referralController.text.trim(),
                                                  _emailController.text.trim());
                                          _bloc.add(
                                              FetchSignUp(request.reqBody()));
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
