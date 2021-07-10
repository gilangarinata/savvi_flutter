import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
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
import 'package:mylamp_flutter_v4_stable/resource/my_variables.dart';
import 'package:mylamp_flutter_v4_stable/ui/bluetooth/setup_bluetooth_dialog.dart';
import 'package:mylamp_flutter_v4_stable/ui/dashboard/delete_dialog.dart';
import 'package:mylamp_flutter_v4_stable/ui/history/MonthlyModel.dart';
import 'package:mylamp_flutter_v4_stable/ui/history/history_bloc.dart';
import 'package:mylamp_flutter_v4_stable/ui/history/history_contract.dart';
import 'package:mylamp_flutter_v4_stable/ui/introduction/introduction.dart';
import 'package:mylamp_flutter_v4_stable/widget/my_sliders.dart';
import 'package:mylamp_flutter_v4_stable/widget/my_snackbar.dart';
import 'package:mylamp_flutter_v4_stable/widget/progress_loading.dart';
import 'package:mylamp_flutter_v4_stable/widget/scenario_view.dart';
import 'package:mylamp_flutter_v4_stable/widget/slider.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class HistoryScreenMonthly extends StatefulWidget {
  String userId;
  String ruasJalan;

  HistoryScreenMonthly(this.userId,this.ruasJalan);

  @override
  _ScheduleScreenScreenState createState() => _ScheduleScreenScreenState();
}

class _ScheduleScreenScreenState extends State<HistoryScreenMonthly> {
  @override
  Widget build(BuildContext context) {
    return HistoryContent(widget.userId,widget.ruasJalan);
  }
}

class HistoryContent extends StatefulWidget {
  String userId;
  String ruasJalan;

  HistoryContent(this.userId,this.ruasJalan);

  @override
  _HistoryContentState createState() => _HistoryContentState();
}

class MonthModel {
  int real;
  String used;
  MonthModel(this.real,this.used);
}

class YearModel {
  int real;
  String used;

  YearModel(this.real,this.used);
}

class _HistoryContentState extends State<HistoryContent> {

  List<Data> datas = [];
  final scaffoldState = GlobalKey<ScaffoldState>();

  MonthModel mMonth;
  YearModel mYear;

  DateTime selectedDate = DateTime.now();

  void handleReadOnlyInputClick() {
    scaffoldState.currentState
        .showBottomSheet((context) => Container(
      width: MediaQuery.of(context).size.width,
      child: YearPicker(
        selectedDate: DateTime(1997),
        firstDate: DateTime(1995),
        lastDate: DateTime.now(),
        onChanged: (val) {
          setState(() {
            mYear = YearModel(val.year, fromYear(val.year));
            yearController.text = val.year.toString();
          });
          print(fromYear(val.year));
          Navigator.pop(context);
        },
      ),
    ));
  }

  void handleMonth() {
    scaffoldState.currentState
        .showBottomSheet((context) => Container(
      width: MediaQuery.of(context).size.width,
      child: MonthPicker(
        selectedDate: DateTime(mMonth.real),
        firstDate: DateTime(1995),
        lastDate: DateTime.now(),
        onChanged: (val) {
          setState(() {
            mMonth = MonthModel(val.month, fromMonth(val.month));
            monthController.text = val.month.toString();
          });
          print(fromYear(val.month));
          Navigator.pop(context);
        },
      ),
    ));
  }

  String fromYear(int year){
    String yr = year.toString();
    return yr.substring(2,4);
  }

  String fromMonth(int months) {
    String month = "";
    if (months == 1) {
      month = "Jan";
    } else if (months == 2) {
      month = "Feb";
    } else if (months == 3) {
      month = "Mar";
    } else if (months == 4) {
      month = "Apr";
    } else if (months == 5) {
      month = "May";
    } else if (months == 6) {
      month = "Jun";
    } else if (months == 7) {
      month = "Jul";
    } else if (months == 8) {
      month = "Aug";
    } else if (months == 9) {
      month = "Sep";
    } else if (months == 10) {
      month = "Oct";
    } else if (months == 11) {
      month = "Nov";
    } else if (months == 12) {
      month = "Dec";
    }
    return month;
  }

  Future<MonthlyModel> getKwhMonthly(String userId, String ruasjalan, String month, String year) async {
    var params = {
      "userId" : userId,
      "ruasJalan" : ruasjalan,
      "month" : month,
      "year" : year
    };
    String url = "http://" +
        FlavorConfig.instance.variables[MyVariables.baseUrl] +
        FlavorConfig.instance.variables[MyVariables.getKwhMonthly];

    Response response = await Dio().post(url,
      data: jsonEncode(params),
    );

    print("ini : " +response.toString());

    MonthlyModel models = MonthlyModel.fromJsonObject(response.data);
    return models;
  }

  @override
  void initState() {
    super.initState();
    getModel();
  }

  void getModel() async {
    DateTime dt = DateTime.now();

    setState(() {
      mMonth = MonthModel(dt.month, fromMonth(dt.month));
      mYear = YearModel(dt.year, fromYear(dt.year));
    });

    yearController.text = fromMonth(mMonth.real) +" "+ mYear.real.toString();
    monthController.text = mMonth.used;

    final ProgressDialog pr = ProgressDialog(context);
    MonthlyModel model = await getKwhMonthly(widget.userId, widget.ruasJalan, mMonth.used, mYear.used);
    print(model.data[0].segment);
    if(model != null){
      setState(() {
        datas = model.data;
      });
    }
  }

  void getModel2() async {

    setState(() {
      mMonth = MonthModel(selectedDate.month, fromMonth(selectedDate.month));
      mYear = YearModel(selectedDate.year, fromYear(selectedDate.year));
    });

    yearController.text = fromMonth(selectedDate.month) + "  " + mYear.real.toString();
    monthController.text = mMonth.used;

    MonthlyModel model = await getKwhMonthly(widget.userId, widget.ruasJalan, mMonth.used, mYear.used);
    print(model.data[0].segment);
    if(model != null){
      setState(() {
        datas = model.data;
      });
    }
  }

  TextEditingController monthController = new TextEditingController();
  TextEditingController yearController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldState,
      appBar: AppBar(
          elevation: 0,
          backgroundColor: MyColors.brownDark,
          brightness: Brightness.dark,
          iconTheme: IconThemeData(color: Colors.white),
          title: MyText.myTextHeader1(MyStrings.historyMonthly, Colors.white),
      ),
      body: Container(
        child: Column(
          children: [
            Text("Pilih bulan :"),
            TextFormField(
              controller: yearController,
              readOnly: true,
              style: TextStyle(fontSize: 13.0),
              decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 13.0),
                hintText: 'Pick Year',
                contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: ()  {
                showMonthPicker(context: context,
                  firstDate: DateTime(DateTime.now().year - 1, 5),
                  lastDate: DateTime(DateTime.now().year + 1, 9),
                  initialDate:  selectedDate ?? DateTime.now(),)
                .then((value)  {
                  if(value != null){
                  setState(() {
                    selectedDate = value;
                  });
                getModel2();
                  }
                });
              },
            ),
            // TextFormField(
            //   controller: monthController,
            //   readOnly: true,
            //   style: TextStyle(fontSize: 13.0),
            //   decoration: InputDecoration(
            //     hintStyle: TextStyle(fontSize: 13.0),
            //     hintText: 'Pick Month',
            //     contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
            //     border: OutlineInputBorder(),
            //     suffixIcon: Icon(Icons.calendar_today),
            //   ),
            //   onTap: () => handleMonth(),
            // ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(top: 2),
                scrollDirection: Axis.vertical,
                itemCount: datas.length,
                itemBuilder: (context, pos) {
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
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text("Segment : "),
                                    Text(datas[pos].segment.isEmpty ? "Segment yang belum didefinisikan" : datas[pos].segment),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text("Total : "),
                                    Text(datas[pos].kwhs.toString() + " kWh/m"),
                                  ],
                                ),
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
          ],
        ),
      )
    );
  }


}
