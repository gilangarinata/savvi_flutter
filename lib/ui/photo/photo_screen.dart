import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import 'package:mylamp_flutter_v4_stable/network/repository/hardware_detail_repository.dart';
import 'package:mylamp_flutter_v4_stable/pref_manager/pref_data.dart';
import 'package:mylamp_flutter_v4_stable/network/model/request/update_lamp_request.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_colors.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_field_style.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_strings.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_text.dart';
import 'package:mylamp_flutter_v4_stable/ui/bluetooth/setup_bluetooth_dialog.dart';
import 'package:mylamp_flutter_v4_stable/ui/dashboard/delete_dialog.dart';
import 'package:mylamp_flutter_v4_stable/ui/detail/hardware_detail_bloc.dart';
import 'package:mylamp_flutter_v4_stable/ui/detail/hardware_detail_contract.dart';
import 'package:mylamp_flutter_v4_stable/ui/detail/hardware_detail_screen.dart';

import 'package:mylamp_flutter_v4_stable/ui/introduction/introduction.dart';
import 'package:mylamp_flutter_v4_stable/utils/tools.dart';
import 'package:mylamp_flutter_v4_stable/widget/my_sliders.dart';
import 'package:mylamp_flutter_v4_stable/widget/my_snackbar.dart';
import 'package:mylamp_flutter_v4_stable/widget/progress_loading.dart';
import 'package:mylamp_flutter_v4_stable/widget/scenario_view.dart';
import 'package:mylamp_flutter_v4_stable/widget/slider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhotoScreen extends StatefulWidget {
  String hardwareId;
  String photoPath;
  String hardwareName;
  String id;

  PhotoScreen(this.hardwareId, this.photoPath, this.hardwareName,this.id);

  @override
  _PhotoScreenState createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HardwareDetailBloc>(
          create: (context) =>
              HardwareDetailBloc(HardwareDetailRepositoryImpl()),
        )
      ],
      child: PhotoContent(widget.hardwareId,widget.photoPath, context,widget.hardwareName,widget.id),
    );
  }
}

class PhotoContent extends StatefulWidget {
  String hardwareId;
  String photoPath;
  BuildContext parentContext;
  String hardwareName;
  String id;

  PhotoContent(this.hardwareId, this.photoPath, this.parentContext, this.hardwareName, this.id);

  @override
  _PhotoContentState createState() => _PhotoContentState();
}

class _PhotoContentState extends State<PhotoContent> {
  HardwareDetailBloc bloc;
  bool isDeleteLoading = false;
  bool isError = false;
  String errorMessage;
  ProgressDialog pr;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<HardwareDetailBloc>(context);

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
          title: MyText.myTextHeader1(MyStrings.deviceImage, Colors.white),
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(MyStrings.deleteImage),
                        actions: <Widget>[
                          FlatButton(
                            child: const Text(MyStrings.cancel),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                           FlatButton(
                            child: Text(MyStrings.delete),
                            onPressed: () {
                              Navigator.pop(context);
                              bloc.add(DeleteDeviceImage(widget.hardwareId));
                            },
                          )
                        ],
                      );
                    },
                  );
                }), // overflow menu
          ]
      ),
      body: BlocListener<HardwareDetailBloc, HardwareDetailState>(
        listener: (context, event) {
          if (event is ErrorState) {
            setState(() {
              errorMessage = event.message;
              isDeleteLoading = false;
              isError = true;
              pr.hide();
            });
            MySnackbar.showToast(errorMessage);
          }else if (event is DeleteImageLoading) {
            setState(() {
              isDeleteLoading = true;
              isError = false;
              pr.show();
            });
          } else if (event is DeleteImageSuccess) {
            setState(() {
              isDeleteLoading = false;
              isError = false;
              pr.hide();
            });
            Tools.changeScreen(context, HardwareDetailScreen(widget.id, widget.hardwareName));
          }
        },
        child: PhotoView(
          imageProvider: NetworkImage(widget.photoPath),
        ),
      ),
    );
  }

}
