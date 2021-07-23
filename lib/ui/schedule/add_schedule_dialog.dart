import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:mylamp_flutter_v4_stable/network/model/response/schedule_response.dart';
import 'package:mylamp_flutter_v4_stable/network/repository/schedule_repository.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_colors.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_strings.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_text.dart';
import 'package:mylamp_flutter_v4_stable/ui/schedule/schedule_bloc.dart';
import 'package:mylamp_flutter_v4_stable/ui/schedule/schedule_contract.dart';
import 'package:mylamp_flutter_v4_stable/widget/my_snackbar.dart';
import 'package:mylamp_flutter_v4_stable/widget/progress_loading.dart';
import 'package:mylamp_flutter_v4_stable/widget/slider_schedule.dart';

class AddScheduleDialog extends StatefulWidget {
  String userId;
  String hardwareId;
  bool isEdit;
  Result item;

  AddScheduleDialog(this.userId, this.hardwareId, this.isEdit, this.item);

  @override
  _AddScheduleDialogState createState() => _AddScheduleDialogState();
}

class _AddScheduleDialogState extends State<AddScheduleDialog> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ScheduleBloc>(
          create: (context) => ScheduleBloc(ScheduleRepositoryImpl()),
        )
      ],
      child: DialogContent(
          widget.userId, widget.hardwareId, widget.isEdit, widget.item),
    );
  }
}

class DialogContent extends StatefulWidget {
  String userId;
  String hardwareId;
  bool isEdit;
  Result item;

  DialogContent(this.userId, this.hardwareId, this.isEdit, this.item);

  @override
  _DialogContentState createState() => _DialogContentState();
}

class _DialogContentState extends State<DialogContent> {
  bool isLoading = false;
  ScheduleBloc bloc;
  DateTime _time;
  String _brightness;
  DateTime editTime;
  bool isDeleteLoading = false;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<ScheduleBloc>(context);
    if (widget.isEdit) {
      _brightness = widget.item.brightness.toString();
    } else {
      _brightness = "0";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEdit) {
      if (widget.item != null) {
        String savedDateString =
            "2012-02-27 ${widget.item.hour.padLeft(2,"0")}:${widget.item.minute.padLeft(2,"0")}:00";
        editTime = DateTime.parse(savedDateString);
      }
    } else {
      String savedDateString = "2012-02-27 00:00:00";
      editTime = DateTime.parse(savedDateString);
    }

    return BlocListener<ScheduleBloc, ScheduleState>(
      listener: (context, event) {
        if (event is LoadingState) {
          setState(() {
            isLoading = true;
          });
        }else if (event is DeleteLoadingState) {
          setState(() {
            isDeleteLoading = true;
          });
        }
        else if (event is ErrorState) {
          setState(() {
            isDeleteLoading = false;
            isLoading = false;
          });
          MySnackbar.showToast(event.message);
        } else if (event is AddScheduleSuccess) {
          if (event.items) {
            print(event.items);
            setState(() {
              isLoading = false;
            });
            Navigator.pop(context, true);
          } else {
            setState(() {
              isLoading = false;
            });
            MySnackbar.showToast(MyStrings.serverFailed);
          }
        } else if (event is EditScheduleSuccess) {
          if (event.items) {
            setState(() {
              isLoading = false;
            });
            Navigator.pop(context, true);
          } else {
            setState(() {
              isLoading = false;
            });
            MySnackbar.showToast(MyStrings.serverFailed);
          }
        }else if (event is DeleteScheduleSuccess) {
          if (event.items) {
            setState(() {
              isDeleteLoading = false;
            });
            Navigator.pop(context, true);
          } else {
            setState(() {
              isDeleteLoading = false;
            });
            MySnackbar.showToast(MyStrings.serverFailed);
          }
        }
      },
      child: Dialog(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              TimePickerSpinner(
                time: editTime,
                is24HourMode: true,
                normalTextStyle:
                    TextStyle(fontSize: 24, color: MyColors.grey_20),
                highlightedTextStyle: TextStyle(
                    fontSize: 24,
                    color: MyColors.grey_60,
                    fontWeight: FontWeight.bold),
                spacing: 50,
                itemHeight: 80,
                isForce2Digits: true,
                onTimeChange: (time) {
                  _time = time;
                },
              ),
              SizedBox(
                height: 20,
              ),
              SliderScheduleWidget(
                value: widget.isEdit ? widget.item.brightness ?? 0 : 0,
                getValue: (val) {
                  setState(() {
                    print(val);
                    _brightness = val;
                  });
                },
              ),
              SizedBox(
                height: 20,
              ),
              Visibility(
                  visible: widget.isEdit,
                  child: InkWell(
                    onTap: (){
                      bloc.add(DeleteScheduleEvent(widget.item.id));
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Spacer(),
                          Visibility(
                              visible: isDeleteLoading,
                              child: ProgressLoading(
                            size: 10,
                            stroke: 1,
                          )),
                          Visibility(
                            visible: !isDeleteLoading,
                            child: Row(
                            children: [
                              Icon(
                                Icons.delete,
                                color: MyColors.grey_60,
                              ),
                              MyText.myTextDescription(
                                  MyStrings.delete, MyColors.grey_60),
                            ],
                          ),),
                          Spacer(),
                        ],
                      ),
                    ),
                  )),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context, false);
                    },
                    child: Container(
                      padding: EdgeInsets.all(20),
                      child: MyText.myTextHeader2(
                          MyStrings.cancel, MyColors.grey_60),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (_time != null) {
                        if (_brightness != null) {
                          int minute = _time.minute;
                          int hour = _time.hour;
                          int day = 0;

                          if (widget.isEdit) {
                            Map<String, String> req = {
                              "minute": minute.toString(),
                              "hour": hour.toString(),
                              "day": day.toString(),
                              "brightness": _brightness == "100" ? "99" :_brightness,
                              "userId": widget.userId
                            };
                            bloc.add(EditScheduledEvent(req, widget.item.id));
                          } else {
                            Map<String, String> req = {
                              "minute": minute.toString(),
                              "hour": hour.toString(),
                              "day": day.toString(),
                              "brightness": _brightness == "100" ? "99" :_brightness,
                              "userId": widget.userId,
                              "hardwareId": widget.hardwareId
                            };
                            bloc.add(AddScheduleEvent(req));
                          }
                        }
                      }
                    },
                    child: isLoading
                        ? ProgressLoading(
                            size: 10,
                            stroke: 1,
                          )
                        : Container(
                            padding: EdgeInsets.all(20),
                            child: MyText.myTextHeader2(
                                MyStrings.save2, MyColors.primary),
                          ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
