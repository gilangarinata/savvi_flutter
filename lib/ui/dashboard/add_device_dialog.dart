import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mylamp_flutter_v4_stable/network/model/request/add_device_request.dart';
import 'package:mylamp_flutter_v4_stable/network/repository/dashboard_repository.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_colors.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_strings.dart';
import 'package:mylamp_flutter_v4_stable/ui/dashboard/dashboard_bloc.dart';
import 'package:mylamp_flutter_v4_stable/ui/dashboard/dashboard_contract.dart';
import 'package:mylamp_flutter_v4_stable/widget/my_snackbar.dart';
import 'package:mylamp_flutter_v4_stable/widget/progress_loading.dart';

class AddDeviceDialog extends StatefulWidget {
  String userId;
  String token;

  AddDeviceDialog(this.userId, this.token);

  @override
  _AddDeviceDialogState createState() => _AddDeviceDialogState();
}

class _AddDeviceDialogState extends State<AddDeviceDialog> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DashboardBloc>(
          create: (context) => DashboardBloc(DashboardRepositoryImpl()),
        )
      ],
      child: DialogContent(widget.userId, widget.token),
    );
  }
}

class DialogContent extends StatefulWidget {
  String userId;
  String token;

  DialogContent(this.userId, this.token);

  @override
  _DialogContentState createState() => _DialogContentState();
}

class _DialogContentState extends State<DialogContent> {
  bool isLoading = false;
  DashboardBloc bloc;
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _descriptionController = new TextEditingController();
  TextEditingController _hardwareIdController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();

  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  void fcmSubscribe(String topic) {
    firebaseMessaging.subscribeToTopic(topic).then((value) {
      print("subscribed topic : $topic");
    });
  }

  void fcmUnSubscribe(String topic) {
    firebaseMessaging.unsubscribeFromTopic(topic);
  }
  
  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<DashboardBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DashboardBloc, DashboardState>(
      listener: (context, event) {
        if (event is InitialState) {
          setState(() {
            isLoading = true;
          });
        } else if (event is LoadingState) {
          setState(() {
            isLoading = true;
          });
        } else if (event is ErrorState) {
          setState(() {
            isLoading = false;
          });
          MySnackbar.showToast(event.message);
        } else if (event is AddDeviceSuccess) {
          fcmSubscribe("seti-app-${event.items.hardwareId}");
          print(event.items);
          setState(() {
            isLoading = false;
          });
          Navigator.pop(context, true);
        }
      },
      child: Dialog(
          child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Material(
                color: MyColors.brownDark,
                child: Container(
                  height: 50,
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      Text(MyStrings.addDevice,
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                      Spacer(),
                      Stack(
                        children: [
                          Visibility(
                            child: InkWell(
                              splashColor: Colors.white,
                              child: Container(
                                padding: EdgeInsets.all(15),
                                alignment: Alignment.center,
                                child: Text(MyStrings.save,
                                    style: TextStyle(color: Colors.white)),
                              ),
                              onTap: () {
                                if (_formKey.currentState.validate()) {
                                  var name = _nameController.text.trim();
                                  var description =
                                      _descriptionController.text.trim();
                                  var hardwareId =
                                      _hardwareIdController.text.trim();
                                  AddDeviceRequest request =
                                      new AddDeviceRequest(name, description,
                                          hardwareId, widget.userId);
                                  bloc.add(AddDevice(
                                      request.reqBody(), widget.token));
                                }
                              },
                            ),
                            visible: true,
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Visibility(
                              child: ProgressLoading(color: Colors.white,size: 10,stroke: 1,),
                              visible: isLoading,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(height: 25),
                    TextFormField(
                      controller: _nameController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return MyStrings.mustNotBeEmpty;
                        }
                        return null;
                      },
                      style: TextStyle(fontSize: 18),
                      decoration: InputDecoration(
                        hintText: MyStrings.deviceName,
                        hintStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: MyColors.grey_40, width: 1)),
                        focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: MyColors.grey_60, width: 1)),
                      ),
                    ),
                    Container(height: 25),
                    TextFormField(
                      controller: _descriptionController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return MyStrings.mustNotBeEmpty;
                        }
                        return null;
                      },
                      style: TextStyle(fontSize: 18),
                      decoration: InputDecoration(
                        hintText: MyStrings.desc,
                        hintStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: MyColors.grey_40, width: 1)),
                        focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: MyColors.grey_60, width: 1)),
                      ),
                    ),
                    Container(height: 25),
                    TextFormField(
                      controller: _hardwareIdController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return MyStrings.mustNotBeEmpty;
                        }
                        return null;
                      },
                      style: TextStyle(fontSize: 18),
                      decoration: InputDecoration(
                        hintText: MyStrings.hid,
                        hintStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: MyColors.grey_40, width: 1)),
                        focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: MyColors.grey_60, width: 1)),
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: 20)
            ],
          ),
        ),
      )),
    );
  }
}
