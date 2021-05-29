
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mylamp_flutter_v4_stable/pref_manager/pref_data.dart';
import 'package:mylamp_flutter_v4_stable/network/model/request/update_lamp_request.dart';
import 'package:mylamp_flutter_v4_stable/network/model/response/device_response.dart';
import 'package:mylamp_flutter_v4_stable/network/repository/dashboard_repository.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_colors.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_field_style.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_strings.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_text.dart';
import 'package:mylamp_flutter_v4_stable/ui/bluetooth/DiscoveryPage.dart';
import 'package:mylamp_flutter_v4_stable/ui/bluetooth/setup_bluetooth_dialog.dart';
import 'package:mylamp_flutter_v4_stable/ui/dashboard/add_device_dialog.dart';
import 'package:mylamp_flutter_v4_stable/ui/dashboard/dashboard_bloc.dart';
import 'package:mylamp_flutter_v4_stable/ui/dashboard/dashboard_contract.dart';
import 'package:mylamp_flutter_v4_stable/ui/dashboard/delete_dialog.dart';
import 'package:mylamp_flutter_v4_stable/ui/detail/hardware_detail_screen.dart';
import 'package:mylamp_flutter_v4_stable/ui/introduction/introduction.dart';
import 'package:mylamp_flutter_v4_stable/ui/userdetail/user_detail_screen.dart';
import 'package:mylamp_flutter_v4_stable/utils/tools.dart';
import 'package:mylamp_flutter_v4_stable/widget/my_snackbar.dart';
import 'package:mylamp_flutter_v4_stable/widget/progress_loading.dart';
import 'package:mylamp_flutter_v4_stable/widget/scenario_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DashboardBloc>(
          create: (context) => DashboardBloc(DashboardRepositoryImpl()),
        )
      ],
      child: DashboardContent(),
    );
  }
}

class DashboardContent extends StatefulWidget {
  @override
  _DashboardContentState createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  DashboardBloc bloc;
  String username;
  String position;
  String referral;
  String userId;
  String token;
  int countDevice;
  List<Result> item = new List<Result>();
  bool isLoading = false;
  bool isError = false;
  bool firstLoad = true;
  String errorMessage;
  List<bool> isLampLoading;

  bool isControlAllowed = false;
  String KEY_SU_1 = "superuser1";

  void getPrefData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString(PrefData.USERNAME);
      position = prefs.getString(PrefData.POSITION);
      referral = prefs.getString(PrefData.REFERRAL);
    });

    isControlAllowed = position == KEY_SU_1 ? true : false;



    userId = prefs.getString(PrefData.USER_ID);
    token = prefs.getString(PrefData.TOKEN);
    bloc = BlocProvider.of<DashboardBloc>(context);
    bloc.add(FetchDevice(userId, "", token));
  }

  @override
  void initState() {
    super.initState();
    getPrefData();
  }

  Future<void> onRefreshData() async {
    bloc.add(FetchDevice(userId, "", token));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          brightness: Brightness.dark,
          iconTheme: IconThemeData(color: MyColors.grey_60),
          title: MyText.myTextHeader1("Home", MyColors.grey_80),
          actions: <Widget>[
            Visibility(
              visible: isControlAllowed && !kIsWeb,
              child: IconButton(
                  icon: Icon(
                    Icons.bluetooth,
                    color: MyColors.grey_80,
                  ),
                  onPressed: () {
                    // showDialog(context: context,builder: (_) => SetupBluetoothDialog());
                    Tools.addScreen(context, DiscoveryPage(start: true,));
                  }),
            ), // overflow menu
          ]),
      body: BlocListener<DashboardBloc, DashboardState>(
        listener: (context, event) {
          if (event is InitialState) {
            setState(() {
              if (firstLoad) {
                isLoading = true;
              }
            });
          } else if (event is LoadingState) {
            setState(() {
              if (firstLoad) {
                isLoading = true;
              }
            });
          } else if (event is ErrorState) {
            setState(() {
              errorMessage = event.message;
              isLoading = false;
              isError = true;
              firstLoad = false;
            });
          } else if (event is LoadedState) {
            setState(() {
              isLoading = false;
              isError = false;
              firstLoad = false;
              item = event.items;
              countDevice = item.length;
              isLampLoading = new List(countDevice);
            });
          } else if (event is UpdateLampSuccess) {
            bloc.add(FetchDevice(userId, "", token));
          }
        },
        child: isLoading
            ? ProgressLoading()
            : isError
                ? NegativeScenarioView(errorMessage,false, (){
                  bloc.add(FetchDevice(userId, "", token));
                })
                : Container(
                    color: Colors.white,
                    child: RefreshIndicator(
                      onRefresh: onRefreshData,
                      child: ListView(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            child: Row(
                              children: [
                                InkWell(
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: MyColors.primary,
                                    child: CircleAvatar(
                                      backgroundImage:
                                          AssetImage('assets/img_person.jpg'),
                                      radius: 28,
                                    ),
                                  ),
                                  onTap: () async {
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    prefs.clear();
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext ctx) =>
                                                IntroductionScreen()));
                                  },
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyText.myTextHeader2(
                                        username, MyColors.grey_80),
                                    MyText.myTextDescription(
                                        position, MyColors.primary),
                                    MyText.myTextDescription(
                                        referral, MyColors.primary)
                                  ],
                                ),
                                Expanded(
                                  child: SizedBox(),
                                ),
                                MyText.myTextHeader2(
                                    "$countDevice Lamps", MyColors.grey_80),
                              ],
                            ),
                          ),
                          ListView.builder(
                            padding: EdgeInsets.only(top: 2),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: item.length,
                            itemBuilder: (context, pos) {
                              return getLampLayout(item, pos, context);
                              // if(item[pos].position == position){
                              //
                              // }else{
                              //   return getUserLayout(item, pos, context);
                              // }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "btn1",
        backgroundColor: MyColors.primary,
        onPressed: () {
          // if(isControlAllowed) {
            showDialog(
                context: context,
                builder: (_) => AddDeviceDialog(userId, token,username,position,referral,"")).then((value) {
              if (value) {
                bloc.add(FetchDevice(userId, "", token));
              }
            });
          // }else{
          //   Tools.showToast(MyStrings.superuserPrivilege);
          // }
        },
        // tooltip: 'Increment',
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomAppBar(
          color: MyColors.brownDark,
          shape: CircularNotchedRectangle(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.home),
                color: Colors.white,
                onPressed: () {
                  //
                },
              ),
            ],
          )),
    );
  }

  Widget getLampLayout(List<Result> item, int pos, BuildContext context){
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 5),
        child: InkWell(
          onTap: (){
            Tools.addScreen(context, HardwareDetailScreen(item[pos].hardware.id, item[pos].name));
          },
          onLongPress: (){
            showDialog(context: context,builder: (_) => CustomEventDialog(item[pos].id, token, item[pos].hardware.hardwareId)).then((value) {
              if (value) {
                bloc.add(FetchDevice(userId, "", token));
              }
            });
          },
          child: Ink(
            color: Colors.red,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(6)),
              color: Colors.white,
              elevation: 3,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Container(
                padding: EdgeInsets.all(15),
                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 60,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.lightbulb, color: item[pos].hardware.active ? !item[pos].hardware.lamp ? item[pos].hardware.brightnessSchedule == 0 ? Colors.red : Colors.green :  item[pos].hardware.brightness == 0 ? Colors.red : Colors.green : Colors.grey , ),
                          SizedBox(height: 5,),
                          Text(item[pos].hardware.active ? !item[pos].hardware.lamp ?  item[pos].hardware.brightnessSchedule.toString() +"%" :  item[pos].hardware.brightness.toString() + "%" : "Offline", style: TextStyle(fontSize: 10) )
                        ],
                      ),
                    ),
                    Container(width: 15),
                    Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: <Widget>[
                          MyText.myTextDescription(
                              item[pos].name,
                              MyColors.grey_80),
                          Container(height: 5),
                          MyText.myTextDescription(
                              item[pos].description,
                              MyColors.grey_40),
                          Container(height: 5),
                          MyText.myTextDescription('ID : ${item[pos].hardware.hardwareId}',
                              MyColors.grey_40),
                        ]),
                    Spacer(),
                    Visibility(
                      visible: isLampLoading[pos] ?? false,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: ProgressLoading(
                          size: 13,
                          stroke: 2,
                        ),
                      ),
                    ),
                    SizedBox(
                      child: Visibility(
                        visible: isControlAllowed,
                        child: ToggleSwitch(
                          minWidth: 55.0,
                          initialLabelIndex: item[pos].hardware.lamp != null ? item[pos].hardware.lamp ? 1 : 0 : 1,
                          activeBgColor: Colors.cyan,
                          activeFgColor: Colors.white,
                          inactiveBgColor: Colors.black26,
                          inactiveFgColor: Colors.white,
                          labels: ['S', 'M'],
                          icons: [Icons.schedule, Icons.emoji_people],
                          onToggle: (index) {
                            setState(() {
                              isLampLoading[pos] =
                              true;
                              if (item[pos]
                                  .hardware
                                  .lamp ??
                                  false) {
                                UpdateLampRequest
                                request =
                                UpdateLampRequest(
                                    item[pos]
                                        .hardware
                                        .hardwareId,
                                    false);
                                bloc.add(
                                    UpdateLampEvent(
                                        request
                                            .reqBody(),
                                        token));
                              } else {
                                UpdateLampRequest
                                request =
                                UpdateLampRequest(
                                    item[pos]
                                        .hardware
                                        .hardwareId,
                                    true);
                                bloc.add(
                                    UpdateLampEvent(
                                        request
                                            .reqBody(),
                                        token));
                              }
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  // Widget getUserLayout(List<Result> item, int pos, BuildContext context){
  //   return Container(
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(
  //           horizontal: 10, vertical: 5),
  //       child: InkWell(
  //         onTap: (){
  //           Tools.addScreen(context, UserDetailScreen(item[pos].user, item[pos].position, item[pos].username));
  //         },
  //         onLongPress: (){
  //           // showDialog(context: context,builder: (_) => CustomEventDialog(item[pos].id, token, item[pos].hardware.hardwareId)).then((value) {
  //           //   if (value) {
  //           //     bloc.add(FetchDevice(userId, token));
  //           //   }
  //           // });
  //         },
  //         child: Ink(
  //           color: Colors.red,
  //           child: Card(
  //             shape: RoundedRectangleBorder(
  //                 borderRadius:
  //                 BorderRadius.circular(6)),
  //             color: Colors.white,
  //             elevation: 3,
  //             clipBehavior: Clip.antiAliasWithSaveLayer,
  //             child: Container(
  //               padding: EdgeInsets.all(15),
  //               child: Row(
  //                 crossAxisAlignment:
  //                 CrossAxisAlignment.center,
  //                 children: <Widget>[
  //                   Container(
  //                     width: 60,
  //                       child: Icon(Icons.person, color: Colors.black38,)),
  //                   Container(width: 15),
  //                   Column(
  //                       crossAxisAlignment:
  //                       CrossAxisAlignment.start,
  //                       children: <Widget>[
  //                         MyText.myTextDescription(
  //                             item[pos].username,
  //                             MyColors.grey_80),
  //                         Container(height: 5),
  //                         MyText.myTextDescription(
  //                             item[pos].position,
  //                             MyColors.grey_40),
  //                       ]),
  //                   Spacer(),
  //                   SizedBox(
  //                     width: 40,
  //                     height: 40,
  //                     child: Icon(Icons.arrow_forward_ios_sharp, color: Colors.black38,)
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}


