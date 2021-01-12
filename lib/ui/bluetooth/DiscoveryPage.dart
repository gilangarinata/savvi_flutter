import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:mylamp_flutter_v4_stable/ui/bluetooth/setup_bluetooth_dialog.dart';
import 'package:mylamp_flutter_v4_stable/utils/tools.dart';

import './BluetoothDeviceListEntry.dart';

class DiscoveryPage extends StatefulWidget {
  /// If true, discovery starts on page start, otherwise user must press action button.
  final bool start;

  const DiscoveryPage({this.start = true});

  @override
  _DiscoveryPage createState() => new _DiscoveryPage();
}

class _DiscoveryPage extends State<DiscoveryPage> with WidgetsBindingObserver {

  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice _device;
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  int _deviceState;
  bool _isButtonUnavailable = false;
  bool _connected = false;
  BluetoothConnection connection;
  // To track whether the device is still connected to Bluetooth
  bool get isConnected => connection != null && connection.isConnected;
  bool isDisconnecting = false;

  // Request Bluetooth permission from the user
  Future<void> enableBluetooth() async {
    // Retrieving the current Bluetooth state
    _bluetoothState = await FlutterBluetoothSerial.instance.state;

    // If the bluetooth is off, then turn it on first
    // and then retrieve the devices that are paired.
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
      return true;
    } else {
      await getPairedDevices();
    }
    return false;
  }


  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    // It is an error to call [setState] unless [mounted] is true.
    if (!mounted) {
      return;
    }

    // Store the [devices] list in the [_devicesList] for accessing
    // the list outside this class
    setState(() {
      _devicesList = devices;
    });

    if(_devicesList.isEmpty){
      FlutterBluetoothSerial.instance.openSettings();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    _deviceState = 0; // neutral

    // If the bluetooth of the device is not enabled,
    // then request permission to turn on bluetooth
    // as the app starts up
    enableBluetooth();

    // Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
        if (_bluetoothState == BluetoothState.STATE_OFF) {
          _isButtonUnavailable = true;
        }
        getPairedDevices();
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {
        getPairedDevices();
      });
    }
  }

  @override
  void dispose() {
    // Avoid memory leak and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Paired Devices"),
      ),
      body: ListView.builder(
        itemCount: _devicesList.length,
        itemBuilder: (BuildContext context, index) {
          BluetoothDevice result = _devicesList[index];
          return BluetoothDeviceListEntry(
            device: result,
            onTap: () async {
              setState(() {
                _isButtonUnavailable = true;
              });
                if (!result.isConnected) {
                  await BluetoothConnection.toAddress(result.address)
                      .then((_connection) {
                    connection = _connection;
                    setState(() {
                      _connected = true;
                    });

                    showDialog(context: context,builder: (_) => SetupBluetoothDialog(connection)).then((value) {
                      if (value) {

                      }
                    });


                    connection.input.listen(null).onDone(() {
                      if (isDisconnecting) {
                        print('Disconnecting locally!');
                      } else {
                        print('Disconnected remotely!');
                      }
                      if (this.mounted) {
                        setState(() {});
                      }
                    });
                  }).catchError((error) {
                    print('Cannot connect, exception occurred');
                    print(error);
                  });
                  setState(() => _isButtonUnavailable = false);
                }

                if(connection != null){
                  showDialog(context: context,builder: (_) => SetupBluetoothDialog(connection)).then((value) {
                    if (value) {

                    }
                  });

                }

            },
          );
        },
      ),
    );
  }

}
