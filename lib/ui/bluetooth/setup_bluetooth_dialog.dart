import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mylamp_flutter_v4_stable/network/model/request/add_device_request.dart';
import 'package:mylamp_flutter_v4_stable/network/repository/dashboard_repository.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_colors.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_field_style.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_strings.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_text.dart';
import 'package:mylamp_flutter_v4_stable/ui/bluetooth/BluetoothDeviceListEntry.dart';
import 'package:mylamp_flutter_v4_stable/ui/dashboard/dashboard_bloc.dart';
import 'package:mylamp_flutter_v4_stable/ui/dashboard/dashboard_contract.dart';
import 'package:mylamp_flutter_v4_stable/utils/tools.dart';
import 'package:mylamp_flutter_v4_stable/widget/my_snackbar.dart';
import 'package:mylamp_flutter_v4_stable/widget/progress_loading.dart';

class SetupBluetoothDialog extends StatefulWidget {

  BluetoothConnection connection;


  SetupBluetoothDialog(this.connection);

  @override
  _SetupBluetoothDialogState createState() => _SetupBluetoothDialogState();
}

class _SetupBluetoothDialogState extends State<SetupBluetoothDialog> {
  StreamSubscription<BluetoothDiscoveryResult> _streamSubscription;
  List<BluetoothDiscoveryResult> results = List<BluetoothDiscoveryResult>();
  bool isDiscovering;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _ssidController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _hardwareIdController = new TextEditingController();
  TextEditingController _longitudeController = new TextEditingController();
  TextEditingController _latitudeController = new TextEditingController();

  String long="";
  String lat="";

  List _cities = ["WIB", "WITA", "WIT"];

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _time;


  @override
  void initState() {
    super.initState();

    _dropDownMenuItems = getDropDownMenuItems();
    _time = _dropDownMenuItems[0].value;

    isDiscovering = true;
    if (isDiscovering) {
      _startDiscovery();
    }
  }


  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for (String city in _cities) {
      items.add(new DropdownMenuItem(
          value: city,
          child: new Text(city)
      ));
    }
    return items;
  }


  void changedDropDownItem(String selectedCity) {
    setState(() {
      _time = selectedCity;
    });
  }

  void _restartDiscovery() {
    setState(() {
      results.clear();
      isDiscovering = true;
    });

    _startDiscovery();
  }



  void _startDiscovery() {
    _streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
          setState(() {
            results.add(r);
          });
          print("gla"+results.length.toString());
        });

    _streamSubscription.onDone(() {
      setState(() {
        isDiscovering = false;
      });
      print("done"+results.length.toString());
    });
  }

  void _sendMessageToBluetooth(String message) async {
    widget.connection.output.add(utf8.encode(message + "\r\n"));
    await widget.connection.output.allSent;
  }


  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          color: Colors.white,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Wrap(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10),
                width: double.infinity,
                color: MyColors.primary,
                child: Column(
                  children: <Widget>[
                    Container(height: 10),
                    Icon(Icons.bluetooth, color: Colors.white, size: 30),
                    Container(height: 20),
                    Text(MyStrings.selectDevice,
                        style: MyText.title(context)
                            .copyWith(color: Colors.white)),
                    Container(height: 10),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(20),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Visibility(
                      visible: false,
                      child: Row(
                        children: [
                          MyText.myTextDescription2(
                              MyStrings.scanning, MyColors.grey_40),
                          SizedBox(
                            width: 10,
                          ),
                          ProgressLoading(
                            size: 10,
                            stroke: 1,
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            TextFormField(
                              controller: _ssidController,
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
                                labelText: "SSID",
                                labelStyle: MyFieldStyle.myFieldLabelStylePrimary(),
                                enabledBorder: MyFieldStyle.myUnderlineFieldStyle(),
                                focusedBorder:
                                MyFieldStyle.myUnderlineFocusFieldStyle(),
                              ),
                            ),
                            TextFormField(
                              controller: _passwordController,
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
                                labelText: "Password",
                                labelStyle: MyFieldStyle.myFieldLabelStylePrimary(),
                                enabledBorder: MyFieldStyle.myUnderlineFieldStyle(),
                                focusedBorder:
                                MyFieldStyle.myUnderlineFocusFieldStyle(),
                              ),
                            ),
                            TextFormField(
                              controller: _hardwareIdController,
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
                                labelText: "Hardware ID",
                                labelStyle: MyFieldStyle.myFieldLabelStylePrimary(),
                                enabledBorder: MyFieldStyle.myUnderlineFieldStyle(),
                                focusedBorder:
                                MyFieldStyle.myUnderlineFocusFieldStyle(),
                              ),
                            ),

                            TextFormField(
                              controller: _longitudeController,
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
                                labelText: "Longitude",
                                labelStyle: MyFieldStyle.myFieldLabelStylePrimary(),
                                enabledBorder: MyFieldStyle.myUnderlineFieldStyle(),
                                focusedBorder:
                                MyFieldStyle.myUnderlineFocusFieldStyle(),
                              ),
                            ),


                            TextFormField(
                              controller: _latitudeController,
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
                                labelText: "Latitude",
                                labelStyle: MyFieldStyle.myFieldLabelStylePrimary(),
                                enabledBorder: MyFieldStyle.myUnderlineFieldStyle(),
                                focusedBorder:
                                MyFieldStyle.myUnderlineFocusFieldStyle(),
                              ),
                            ),
                            new DropdownButton(
                              value: _time,
                              items: _dropDownMenuItems,
                              onChanged: changedDropDownItem,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment.center,
                      child: FlatButton(
                        minWidth: double.infinity,
                        padding:
                        EdgeInsets.symmetric(vertical: 0, horizontal: 80),
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(18.0)),
                        child: Text(
                          "Factory Reset",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Colors.grey,
                        onPressed: () {
                          String value = "FRESET";
                          _sendMessageToBluetooth(value);
                        },
                      ),
                    ),

                    Align(
                      alignment: Alignment.center,
                      child: FlatButton(
                        minWidth: double.infinity,
                        padding:
                        EdgeInsets.symmetric(vertical: 0, horizontal: 80),
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(18.0)),
                        child: Text(
                          "Auto Locate",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Colors.grey,
                        onPressed: () async {
                          await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((Position position) {
                            setState(() {
                              _longitudeController.text = position.longitude.toString();
                              _latitudeController.text = position.latitude.toString();
                            });
                          }).catchError((e) {
                            print(e);
                          });

                        },
                      ),
                    ),

                    Align(
                      alignment: Alignment.center,
                      child: FlatButton(
                        minWidth: double.infinity,
                        padding:
                        EdgeInsets.symmetric(vertical: 0, horizontal: 80),
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(18.0)),
                        child: Text(
                          "Send",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: MyColors.primary,
                        onPressed: () {
                          String value = 
                              _ssidController.text + ":" + 
                                  _passwordController.text + ":" + 
                                  _hardwareIdController.text + ":" + 
                                  _longitudeController.text + ":" + 
                                  _latitudeController.text + ":" + 
                                  _time;
                          _sendMessageToBluetooth(value);
                        },
                      ),
                    ),



                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
