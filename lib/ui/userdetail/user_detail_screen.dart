import 'package:fluid_bottom_nav_bar/fluid_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
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
import 'package:mylamp_flutter_v4_stable/utils/tools.dart';
import 'package:mylamp_flutter_v4_stable/widget/my_snackbar.dart';
import 'package:mylamp_flutter_v4_stable/widget/progress_loading.dart';
import 'package:mylamp_flutter_v4_stable/widget/scenario_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';

class UserDetailScreen extends StatefulWidget {
  String userId;
  String position;
  String username;

  UserDetailScreen(this.userId,this.position, this.username);

  @override
  _UserDetailScreenState createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DashboardBloc>(
          create: (context) => DashboardBloc(DashboardRepositoryImpl()),
        )
      ],
      child: DashboardContent(widget.userId, widget.position, widget.username),
    );
  }
}

class DashboardContent extends StatefulWidget {
  String userId;
  String position;
  String username;


  DashboardContent(this.userId, this.position, this.username);

  @override
  _DashboardContentState createState() => _DashboardContentState(username,position,userId);
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

  _DashboardContentState(this.username, this.position, this.userId);

  void getPrefData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isControlAllowed = true;
    token = prefs.getString(PrefData.TOKEN);
    bloc = BlocProvider.of<DashboardBloc>(context);
    bloc.add(FetchDevice(userId, token));
  }

  @override
  void initState() {
    super.initState();
    getPrefData();
  }

  Future<void> onRefreshData() async {
    bloc.add(FetchDevice(userId, token));
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
          title: Row(
            children: [
              Icon(Icons.person, color: MyColors.grey_40,),
              SizedBox(width: 10,),
              MyText.myTextHeader1(username, MyColors.grey_40),
              Spacer(),
              MyText.myTextDescription(position, MyColors.grey_40)
            ],
          ),
          ),
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
            bloc.add(FetchDevice(userId, token));
          }
        },
        child: isLoading
            ? ProgressLoading()
            : isError
                ? NegativeScenarioView(errorMessage,false, (){
                  bloc.add(FetchDevice(userId, token));
                })
                : Container(
                    color: Colors.white,
                    child: RefreshIndicator(
                      onRefresh: onRefreshData,
                      child: ListView(
                        children: [
                          ListView.builder(
                            padding: EdgeInsets.only(top: 2),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: item.length,
                            itemBuilder: (context, pos) {
                              if(item[pos].position == position){
                                return getLampLayout(item, pos, context);
                              }else{
                                return getUserLayout(item, pos, context);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
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
                bloc.add(FetchDevice(userId, token));
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
                          Icon(Icons.lightbulb, color:  item[pos].hardware.active ? !item[pos].hardware.lamp ? item[pos].hardware.brightnessSchedule == 0 ? Colors.red : Colors.green :  item[pos].hardware.brightness == 0 ? Colors.red : Colors.green : Colors.grey , ),
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

  Widget getUserLayout(List<Result> item, int pos, BuildContext context){
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 5),
        child: InkWell(
          onTap: (){
            Tools.addScreen(context, UserDetailScreen(item[pos].user, item[pos].position, item[pos].username));
          },
          onLongPress: (){
            // showDialog(context: context,builder: (_) => CustomEventDialog(item[pos].id, token, item[pos].hardware.hardwareId)).then((value) {
            //   if (value) {
            //     bloc.add(FetchDevice(userId, token));
            //   }
            // });
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
                        child: Icon(Icons.person, color: Colors.black38,)),
                    Container(width: 15),
                    Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: <Widget>[
                          MyText.myTextDescription(
                              item[pos].username,
                              MyColors.grey_80),
                          Container(height: 5),
                          MyText.myTextDescription(
                              item[pos].position,
                              MyColors.grey_40),
                        ]),
                    Spacer(),
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(Icons.arrow_forward_ios_sharp, color: Colors.black38,)
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
}


