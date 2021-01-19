import 'dart:async';
import 'dart:io';

import 'package:fluid_bottom_nav_bar/fluid_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mylamp_flutter_v4_stable/network/model/response/hardware_response.dart';
import 'package:mylamp_flutter_v4_stable/network/repository/hardware_detail_repository.dart';
import 'package:mylamp_flutter_v4_stable/pref_manager/pref_data.dart';
import 'package:mylamp_flutter_v4_stable/network/model/request/update_lamp_request.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_colors.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_field_style.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_strings.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_text.dart';
import 'package:mylamp_flutter_v4_stable/ui/bluetooth/setup_bluetooth_dialog.dart';
import 'package:mylamp_flutter_v4_stable/ui/detail/hardware_detail_bloc.dart';
import 'package:mylamp_flutter_v4_stable/ui/detail/hardware_detail_contract.dart';
import 'package:mylamp_flutter_v4_stable/ui/history/history_screen.dart';
import 'package:mylamp_flutter_v4_stable/ui/introduction/introduction.dart';
import 'package:mylamp_flutter_v4_stable/ui/maps/map_screen.dart';
import 'package:mylamp_flutter_v4_stable/ui/photo/photo_screen.dart';
import 'package:mylamp_flutter_v4_stable/ui/schedule/schedule_screen.dart';
import 'package:mylamp_flutter_v4_stable/utils/tools.dart';
import 'package:mylamp_flutter_v4_stable/widget/my_sliders.dart';
import 'package:mylamp_flutter_v4_stable/widget/my_snackbar.dart';
import 'package:mylamp_flutter_v4_stable/widget/progress_loading.dart';
import 'package:mylamp_flutter_v4_stable/widget/scenario_view.dart';
import 'package:mylamp_flutter_v4_stable/widget/slider.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';

class HardwareDetailScreen extends StatefulWidget {
  String hardwareId;
  String title;

  HardwareDetailScreen(this.hardwareId, this.title);

  @override
  _HardwareDetailScreenState createState() => _HardwareDetailScreenState();
}

class _HardwareDetailScreenState extends State<HardwareDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HardwareDetailBloc>(
          create: (context) =>
              HardwareDetailBloc(HardwareDetailRepositoryImpl()),
        )
      ],
      child: DashboardContent(widget.hardwareId, widget.title),
    );
  }
}

class DashboardContent extends StatefulWidget {
  String hardwareId;
  String title;

  DashboardContent(this.hardwareId, this.title);

  @override
  _DashboardContentState createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  HardwareDetailBloc bloc;
  String token;
  Result item;
  bool isLoading = true;
  bool isError = false;
  bool firstLoad = true;
  String errorMessage;
  bool isLampLoading = true;
  String userId;
  String hardwareId;
  File _image;
  bool isUploadLoading = false;
  String position;
  final picker = ImagePicker();
  ProgressDialog pr;

  String KEY_SU_1 = "superuser1";
  bool isControlAllowed = false;
  bool isSolarCell = false;

  void getPrefData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString(PrefData.TOKEN);
    userId = prefs.getString(PrefData.USER_ID);
    position = prefs.getString(PrefData.POSITION);
    bloc = BlocProvider.of<HardwareDetailBloc>(context);
    bloc.add(FetchHardware(widget.hardwareId, token));

    isControlAllowed = position == KEY_SU_1 ? true : false;

    const oneSec = const Duration(seconds: 5);
    new Timer.periodic(
        oneSec, (Timer t) => bloc.add(FetchHardware(widget.hardwareId, token)));
  }

  Future getImage(ImageSource source, String hardwareId) async {
    final pickedFile = await picker.getImage(source: source, imageQuality: 10, preferredCameraDevice: CameraDevice.rear);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        bloc.add(UploadImage(hardwareId, _image));
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getPrefData();
    pr = ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    pr.style(
        message: MyStrings.pleaseWait,
        borderRadius: 3.0,
        backgroundColor: Colors.white,
        progressWidget: ProgressLoading(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: MyColors.brownDark,
          brightness: Brightness.dark,
          iconTheme: IconThemeData(color: Colors.white),
          title: MyText.myTextHeader1(widget.title, Colors.white),
          actions: <Widget>[
            Container(
              width: 15,
              height: 15,
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: item != null? item.isActive ? Colors.green : Colors.red : Colors.red ),
            ),
            SizedBox(
              width: 10,
            ),
            IconButton(
                icon: Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                ),
                onPressed: () {
                  if(hardwareId != null){
                    Tools.addScreen(context, HistoryScreen(hardwareId));
                  }
                }), // overflow men
            IconButton(
                icon: Icon(
                  item != null ? item.photoPath != null ? Icons.image : Icons.camera_enhance : Icons.camera_enhance,
                  color: Colors.white,
                ),
                onPressed: () {
                  if(item != null){
                    if(item.photoPath != null){
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhotoScreen(item.hardwareId, item.photoPath, widget.title, item.id),
                        ),
                      ).then((value) {
                        if(value == 200){
                          bloc.add(FetchHardware(widget.hardwareId, token));
                        }
                      });
                    }else{
                      if(isControlAllowed) {
                        showSheet(context, item.hardwareId);
                      }else{
                        Tools.showToast(MyStrings.superuserPrivilege);
                      }
                    }
                  }
                }), // overflow menu// u
          ]),
      body: BlocListener<HardwareDetailBloc, HardwareDetailState>(
        listener: (context, event) {
          if (event is ErrorState) {
            setState(() {
              errorMessage = event.message;
              isLoading = false;
              isError = true;
              firstLoad = false;
              isLampLoading = false;
              pr.hide();
            });
            MySnackbar.showToast(errorMessage);
          } else if (event is HardwareLoaded) {
            setState(() {
              isLoading = false;
              isError = false;
              firstLoad = false;
              isLampLoading = false;
              item = event.items;
              hardwareId = event.items.hardwareId;
              
              if(hardwareId.contains("A")){
                isSolarCell = true;
              }else{
                isSolarCell = false;
              }

            });
          } else if (event is UpdateLampSuccess) {
            bloc.add(FetchHardware(widget.hardwareId, token));
          }else if (event is UploadLoadingState) {
            print("uploadloading");
            setState(() {
              isUploadLoading = true;
              pr.show();
            });
          }
          else if (event is UploadImageSuccess) {
            bloc.add(FetchHardware(widget.hardwareId, token));
            setState(() {
              isUploadLoading = false;
            });
            pr.hide();
          }
        },
        child: isLoading
            ? Container(
                width: double.infinity,
                height: double.infinity,
                color: MyColors.brownDark,
                child: ProgressLoading(isDark: true,))
            : isError
                ? NegativeScenarioView(errorMessage,true, () {
          bloc.add(FetchHardware(widget.hardwareId, token));
        })
                : Container(
                    color: MyColors.brownDark,
                    child: ListView(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6)),
                                  color: Colors.white,
                                  elevation: 3,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  child: Container(
                                    height: 100,
                                    padding: EdgeInsets.all(10),
                                    color: Colors.grey,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        MyText.myTextHeader2(
                                            MyStrings.hid, Colors.white),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        MyText.myTextHeader1(
                                            item.hardwareId, Colors.white)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6)),
                                  color: Colors.white,
                                  elevation: 3,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  child: Container(
                                    height: 100,
                                    padding: EdgeInsets.all(10),
                                    color: Colors.grey,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        MyText.myTextHeader2(
                                            MyStrings.notification,
                                            Colors.white),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        MyText.myTextHeader1(
                                            item.alarm, Colors.white)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: isSolarCell,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6)),
                                    color: Colors.white,
                                    elevation: 3,
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    child: Container(
                                      height: 100,
                                      padding: EdgeInsets.all(10),
                                      color: Colors.grey,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          MyText.myTextHeader2(
                                              MyStrings.capacity, Colors.white),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          MyText.myTextHeader1(
                                              item.capacity.toString() + "%",
                                              Colors.white)
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6)),
                                    color: Colors.white,
                                    elevation: 3,
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    child: Container(
                                      height: 100,
                                      padding: EdgeInsets.all(10),
                                      color: Colors.grey,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          MyText.myTextHeader2(
                                              MyStrings.batteryHealth,
                                              Colors.white),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          MyText.myTextHeader1(
                                              item.betteryHealth.toString() + "%",
                                              Colors.white)
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6)),
                                  color: Colors.white,
                                  elevation: 3,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  child: Container(
                                    height: 100,
                                    padding: EdgeInsets.all(10),
                                    color: Colors.grey,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        MyText.myTextHeader2(
                                            MyStrings.longitude, Colors.white),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        MyText.myTextHeader1(
                                            item.longitude, Colors.white)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6)),
                                  color: Colors.white,
                                  elevation: 3,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  child: Container(
                                    height: 100,
                                    padding: EdgeInsets.all(10),
                                    color: Colors.grey,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        MyText.myTextHeader2(
                                            MyStrings.latitude, Colors.white),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        MyText.myTextHeader1(
                                            item.latitude, Colors.white)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6)),
                                  color: Colors.white,
                                  elevation: 3,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  child: Container(
                                    height: 100,
                                    padding: EdgeInsets.all(10),
                                    color: Colors.grey,
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        MyText.myTextHeader2(
                                            MyStrings.temperature, Colors.white),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        MyText.myTextHeader1(
                                            "${item.temperature} \u2103", Colors.white)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6)),
                                  color: Colors.white,
                                  elevation: 3,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  child: Container(
                                    height: 100,
                                    padding: EdgeInsets.all(10),
                                    color: Colors.grey,
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        MyText.myTextHeader2(
                                            MyStrings.humidity, Colors.white),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        MyText.myTextHeader1(
                                            "${item.humidity}%", Colors.white)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6)),
                                  color: Colors.white,
                                  elevation: 3,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  child: Container(
                                    height: 100,
                                    padding: EdgeInsets.all(10),
                                    color: Colors.grey,
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        MyText.myTextHeader2(
                                            isSolarCell ? MyStrings.dischargingTime : MyStrings.powerUsed ,
                                            Colors.white),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        MyText.myTextHeader1(
                                            isSolarCell ? "${item.dischargingTime} W/m" : "${item.dischargingTime} W/m",
                                            Colors.white)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Visibility(
                                  visible: isSolarCell,
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6)),
                                    color: Colors.white,
                                    elevation: 3,
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    child: Container(
                                      height: 100,
                                      padding: EdgeInsets.all(10),
                                      color: Colors.grey,
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          MyText.myTextHeader2(
                                              MyStrings.chargingTime,
                                              Colors.white),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          MyText.myTextHeader1(
                                              item.chargingTime.toString() + " W/m",
                                              Colors.white)
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: isControlAllowed,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 30),
                            child: SliderWidget(
                              value: item.brightness ?? 0,
                              hardwareId: item.hardwareId,
                            ),
                          ),
                        ),
                        SizedBox(height: 50,)
                      ],
                    ),
                  ),
      ),
      floatingActionButton: isControlAllowed ?
      isLampLoading
          ? floatingLoading()
          : ToggleSwitch(
        minWidth: 55.0,
        initialLabelIndex: item.lamp ? 0 : 1,
        activeBgColor: Colors.cyan,
        activeFgColor: Colors.white,
        inactiveBgColor: Colors.white54,
        inactiveFgColor: Colors.white,
        labels: ['S', 'M'],
        icons: [Icons.schedule, Icons.emoji_people],
              onToggle: (index) {
                setState(() {
                  isLampLoading = true;
                });
                if (item != null) {
                  UpdateLampRequest req;
                  if (item.lamp ?? false) {
                    req = UpdateLampRequest(item.hardwareId, false);
                  } else {
                    req = UpdateLampRequest(item.hardwareId, true);
                  }
                  bloc.add(UpdateLampEvent(req.reqBody(), token));
                }
              },
            ) : Container(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        color: MyColors.brownDark,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(child: MyText.myTextDescription("Maps", Colors.white), onTap: (){
              if(item != null){
                Tools.addScreen(context, MapScreen(item));
              }

            },),
            InkWell(child: MyText.myTextDescription("Schedule", Colors.white,), onTap: (){
              if(item != null){
                if(userId != null){
                  Tools.addScreen(context, ScheduleScreen(item.hardwareId, userId));
                }
              }
            },),
          ],
        ),
      ),
    );
  }

  FloatingActionButton floatingLoading() {
    return FloatingActionButton(
      onPressed: null,
      child: ProgressLoading(
        size: 10,
        stroke: 1,
        isDark: true,
      ),
      backgroundColor: MyColors.brownDark,
      elevation: 0,
    );
  }

  void showSheet(context, hardwareId) {
    showModalBottomSheet(context: context, builder: (BuildContext bc) {
      return Container(
        color: MyColors.brownDark,
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.photo, color: Colors.white,),
              title: Text(MyStrings.gallery, style: TextStyle(color: Colors.white),),
              onTap: (){
                print("object");
                getImage(ImageSource.gallery, hardwareId).then((value) => Navigator.of(context).pop());
              },
            ),
            ListTile(
              leading: Icon(Icons.person_add, color: Colors.white,),
              title: Text(MyStrings.camera, style: TextStyle(color: Colors.white),),
              onTap: (){
                getImage(ImageSource.camera,hardwareId).then((value) => Navigator.of(context).pop());
              },
            ),
          ],
        ),
      );
    });
  }



}
