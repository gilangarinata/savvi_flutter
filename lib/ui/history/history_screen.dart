import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mylamp_flutter_v4_stable/network/model/response/history_response.dart';
import 'package:mylamp_flutter_v4_stable/network/repository/hardware_detail_repository.dart';
import 'package:mylamp_flutter_v4_stable/network/repository/history_repository.dart';
import 'package:mylamp_flutter_v4_stable/pref_manager/pref_data.dart';
import 'package:mylamp_flutter_v4_stable/network/model/request/update_lamp_request.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_colors.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_field_style.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_strings.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_text.dart';
import 'package:mylamp_flutter_v4_stable/ui/bluetooth/setup_bluetooth_dialog.dart';
import 'package:mylamp_flutter_v4_stable/ui/dashboard/delete_dialog.dart';
import 'package:mylamp_flutter_v4_stable/ui/history/history_bloc.dart';
import 'package:mylamp_flutter_v4_stable/ui/history/history_contract.dart';
import 'package:mylamp_flutter_v4_stable/ui/introduction/introduction.dart';
import 'package:mylamp_flutter_v4_stable/widget/my_sliders.dart';
import 'package:mylamp_flutter_v4_stable/widget/my_snackbar.dart';
import 'package:mylamp_flutter_v4_stable/widget/progress_loading.dart';
import 'package:mylamp_flutter_v4_stable/widget/scenario_view.dart';
import 'package:mylamp_flutter_v4_stable/widget/slider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryScreen extends StatefulWidget {
  String hardwareId;

  HistoryScreen(this.hardwareId);

  @override
  _ScheduleScreenScreenState createState() => _ScheduleScreenScreenState();
}

class _ScheduleScreenScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HistoryBloc>(
          create: (context) =>
              HistoryBloc(HistoryRepositoryImpl()),
        )
      ],
      child: HistoryContent(widget.hardwareId),
    );
  }
}

class HistoryContent extends StatefulWidget {
  String hardwareId;

  HistoryContent(this.hardwareId);

  @override
  _HistoryContentState createState() => _HistoryContentState();
}

class _HistoryContentState extends State<HistoryContent> {
  HistoryBloc bloc;
  String token;
  List<History> item;
  bool isLoading = true;
  bool isError = false;
  bool firstLoad = true;
  String errorMessage;
  String date;

  bool isSolarCell = false;

  void getPrefData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString(PrefData.TOKEN);
    bloc = BlocProvider.of<HistoryBloc>(context);
    bloc.add(GetHistory(widget.hardwareId));
  }

  Future<void> onRefreshData() async {
    bloc.add(GetHistory(widget.hardwareId));
  }

  @override
  void initState() {
    super.initState();
    if(widget.hardwareId.contains("A")){
      isSolarCell = true;
    }else{
      isSolarCell = false;
    }
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
          title: MyText.myTextHeader1(MyStrings.history, Colors.white),
      ),
      body: BlocListener<HistoryBloc, HistoryState>(
        listener: (context, event) {
          if (event is ErrorState) {
            setState(() {
              errorMessage = event.message;
              isLoading = false;
              isError = true;
              firstLoad = false;
            });
            MySnackbar.showToast(errorMessage);
          } else if (event is HistoryLoaded) {
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
                ? NegativeScenarioView(errorMessage,false,(){
          bloc.add(GetHistory(widget.hardwareId));
        })
                : Container(
                    child: RefreshIndicator(
                      onRefresh: onRefreshData,
                      child: ListView.builder(
                        padding: EdgeInsets.only(top: 2),
                        scrollDirection: Axis.vertical,
                        itemCount: item.length,
                        itemBuilder: (context, pos) {
                          String date = DateFormat("dd MMM").format(item[pos].date);
                          return Container(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: InkWell(
                                onTap: (){

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
                                              Row(
                                                children: [
                                                  Icon(Icons.calendar_today, color: MyColors.grey_60,),
                                                  SizedBox(width: 10,),
                                                  MyText.myTextHeader1(date,
                                                      MyColors.grey_60),
                                                ],
                                              ),
                                              Container(height: 10),
                                              Visibility(
                                                visible: isSolarCell,
                                                child: Row(
                                                  children: [
                                                    SizedBox(width: 30,),
                                                    MyText.myTextDescription(
                                                        "${MyStrings.chargeCapacity}",
                                                        MyColors.grey_40),
                                                    SizedBox(width: 30,),
                                                    MyText.myTextHeader2(
                                                        "${item[pos].chargeCapacity} Watt/day",
                                                        MyColors.grey_60),
                                                  ],
                                                ),
                                              ),
                                              Container(height: 10),
                                              Row(
                                                children: [
                                                  SizedBox(width: 30,),
                                                  MyText.myTextDescription(
                                                      isSolarCell ? MyStrings.dischargeCapacity : MyStrings.powerUsed,
                                                      MyColors.grey_40),
                                                  SizedBox(width: 30,),
                                                  MyText.myTextHeader2(
                                                      isSolarCell ? "${item[pos].dischargeCapacity} Watt/day" : "${item[pos].dischargeCapacity} Watt/day",
                                                      MyColors.grey_60),
                                                ],
                                              ),
                                              Container(height: 10),
                                              Visibility(
                                                visible: isSolarCell,
                                                child: Row(
                                                  children: [
                                                    SizedBox(width: 30,),
                                                    MyText.myTextDescription(
                                                        "${MyStrings.batteryCapacity}",
                                                        MyColors.grey_40),
                                                    SizedBox(width: 30,),
                                                    MyText.myTextHeader2(
                                                        "${item[pos].batteryCapacity}%",
                                                        MyColors.grey_60),
                                                  ],
                                                ),
                                              ),
                                              Container(height: 10),
                                              Visibility(
                                                visible: isSolarCell,
                                                child: Row(
                                                  children: [
                                                    SizedBox(width: 30,),
                                                    MyText.myTextDescription(
                                                        "${MyStrings.batteryLife}",
                                                        MyColors.grey_40),
                                                    SizedBox(width: 30,),
                                                    MyText.myTextHeader2(
                                                        "${item[pos].batteryLife}%",
                                                        MyColors.grey_60),
                                                  ],
                                                ),
                                              ),
                                            ]),
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
