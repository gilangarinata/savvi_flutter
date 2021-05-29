import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mylamp_flutter_v4_stable/network/model/response/schedule_response.dart';
import 'package:mylamp_flutter_v4_stable/network/repository/hardware_detail_repository.dart';
import 'package:mylamp_flutter_v4_stable/network/repository/schedule_repository.dart';
import 'package:mylamp_flutter_v4_stable/pref_manager/pref_data.dart';
import 'package:mylamp_flutter_v4_stable/network/model/request/update_lamp_request.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_colors.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_field_style.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_strings.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_text.dart';
import 'package:mylamp_flutter_v4_stable/ui/bluetooth/setup_bluetooth_dialog.dart';
import 'package:mylamp_flutter_v4_stable/ui/dashboard/delete_dialog.dart';
import 'package:mylamp_flutter_v4_stable/ui/introduction/introduction.dart';
import 'package:mylamp_flutter_v4_stable/ui/schedule/add_schedule_dialog.dart';
import 'package:mylamp_flutter_v4_stable/ui/schedule/schedule_bloc.dart';
import 'package:mylamp_flutter_v4_stable/ui/schedule/schedule_contract.dart';
import 'package:mylamp_flutter_v4_stable/utils/tools.dart';
import 'package:mylamp_flutter_v4_stable/widget/my_sliders.dart';
import 'package:mylamp_flutter_v4_stable/widget/my_snackbar.dart';
import 'package:mylamp_flutter_v4_stable/widget/progress_loading.dart';
import 'package:mylamp_flutter_v4_stable/widget/scenario_view.dart';
import 'package:mylamp_flutter_v4_stable/widget/slider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduleScreen extends StatefulWidget {
  String hardwareId;
  String userId;

  ScheduleScreen(this.hardwareId, this.userId);

  @override
  _ScheduleScreenScreenState createState() => _ScheduleScreenScreenState();
}

class _ScheduleScreenScreenState extends State<ScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ScheduleBloc>(
          create: (context) =>
              ScheduleBloc(ScheduleRepositoryImpl()),
        )
      ],
      child: ScheduleContent(widget.hardwareId, widget.userId),
    );
  }
}

class ScheduleContent extends StatefulWidget {
  String hardwareId;
  String userId;

  ScheduleContent(this.hardwareId, this.userId);

  @override
  _ScheduleContentState createState() => _ScheduleContentState();
}

class _ScheduleContentState extends State<ScheduleContent> {
  ScheduleBloc bloc;
  String token;
  List<Result> item;
  bool isLoading = true;
  bool isError = false;
  bool firstLoad = true;
  String errorMessage;

  bool isControlAllowed = false;
  String KEY_SU_1 = "superuser1";

  void getPrefData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString(PrefData.TOKEN);
    bloc = BlocProvider.of<ScheduleBloc>(context);
    bloc.add(FetchSchedule(widget.hardwareId, widget.userId));

    isControlAllowed = prefs.getString(PrefData.POSITION) == KEY_SU_1 ? true : false;
  }

  @override
  void initState() {
    super.initState();
    getPrefData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: MyColors.brownDark,
          brightness: Brightness.dark,
          iconTheme: IconThemeData(color: Colors.white),
          title: MyText.myTextHeader1(MyStrings.schedule, Colors.white),
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                onPressed: () {
                  if(isControlAllowed){
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (_) => AddScheduleDialog(widget.userId, widget.hardwareId, false, null)).then((value) {
                      if (value) {
                        bloc.add(FetchSchedule(widget.hardwareId, widget.userId));
                      }
                    });
                  }else{
                    Tools.showToast(MyStrings.superuserPrivilege);
                  }

                }), // overflow menu
          ]),
      body: BlocListener<ScheduleBloc, ScheduleState>(
        listener: (context, event) {
          if (event is ErrorState) {
            setState(() {
              errorMessage = event.message;
              isLoading = false;
              isError = true;
              firstLoad = false;
            });
            MySnackbar.showToast(errorMessage);
          } else if (event is ScheduleLoaded) {
            setState(() {
              isLoading = false;
              isError = false;
              firstLoad = false;
              item = event.items;
            });
          }
        },
        child: isLoading
            ? ProgressLoading()
            : isError
                ? NegativeScenarioView(errorMessage, false, (){
          bloc.add(FetchSchedule(widget.hardwareId, widget.userId));
        })
                : Container(
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 2),
                      scrollDirection: Axis.vertical,
                      itemCount: item.length,
                      itemBuilder: (context, pos) {
                        return Container(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: InkWell(
                              onTap: (){
                                if(isControlAllowed){
                                  showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (_) => AddScheduleDialog(widget.userId, widget.hardwareId, true, item[pos])).then((value) {
                                    if (value) {
                                      bloc.add(FetchSchedule(widget.hardwareId, widget.userId));
                                    }
                                  });
                                }else{
                                  Tools.showToast(MyStrings.superuserPrivilege);
                                }

                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(6)),
                                color: Colors.white,
                                elevation: 1,
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  child: Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: <Widget>[
                                            MyText.myTextHeader1(
                                                "${item[pos].hour.padLeft(2,"0")}:${item[pos].minute.padLeft(2,"0")}",
                                                MyColors.grey_80),
                                            Container(height: 5),
                                            Row(
                                              children: [
                                                Icon(Icons.brightness_6, color: MyColors.grey_40,),
                                                SizedBox(width: 10,),
                                                MyText.myTextDescription(
                                                    "${MyStrings.brightness} ${item[pos].brightness}%",
                                                    MyColors.grey_40),
                                              ],
                                            )
                                          ]),
                                      Spacer(),
                                      Icon(Icons.arrow_forward_ios, color: MyColors.grey_40,)
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
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
      ),
      backgroundColor: MyColors.brownDark,
      elevation: 0,
    );
  }
}
