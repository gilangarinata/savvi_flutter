import 'dart:async';
import 'dart:convert';
import 'dart:io' as Io;
import 'dart:isolate';
import 'dart:ui';

import 'package:dio/dio.dart';

// import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:marquee/marquee.dart';
import 'package:mylamp_flutter_v4_stable/network/model/response/device_response.dart';
import 'package:mylamp_flutter_v4_stable/network/model/response/hardware_response.dart'
    as HR;
import 'package:mylamp_flutter_v4_stable/network/repository/dashboard_repository.dart';
import 'package:mylamp_flutter_v4_stable/pref_manager/pref_data.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_colors.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_text.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_variables.dart';
import 'package:mylamp_flutter_v4_stable/ui/dashboard/dashboard_bloc.dart';
import 'package:mylamp_flutter_v4_stable/ui/dashboard/dashboard_contract.dart';
import 'package:mylamp_flutter_v4_stable/ui/dashboard/delete_dialog.dart';
import 'package:mylamp_flutter_v4_stable/ui/detail/hardware_detail_screen.dart';
import 'package:mylamp_flutter_v4_stable/ui/history/history_screen_monthly.dart';
import 'package:mylamp_flutter_v4_stable/ui/maps/gmap_screen.dart';
import 'package:mylamp_flutter_v4_stable/ui/maps/map_screen.dart';
import 'package:mylamp_flutter_v4_stable/ui/photo/photo_screen.dart';
import 'package:mylamp_flutter_v4_stable/ui/userdetail/KmlModel.dart';
import 'package:mylamp_flutter_v4_stable/utils/tools.dart';
import 'package:mylamp_flutter_v4_stable/widget/progress_loading.dart';
import 'package:mylamp_flutter_v4_stable/widget/scenario_view.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';



class UserDetailScreen extends StatefulWidget {
  String userId;
  String position;
  String username;
  String ruasJalan;

  UserDetailScreen(this.userId,this.position, this.username,this.ruasJalan);

  @override
  _UserDetailScreenState createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {

  @override
  Widget build(BuildContext context) {

    final platform = Theme.of(context).platform;

    return MultiBlocProvider(
      providers: [
        BlocProvider<DashboardBloc>(
          create: (context) => DashboardBloc(DashboardRepositoryImpl()),
        )
      ],
      child: DashboardContent(widget.userId, widget.position, widget.username,widget.ruasJalan,platform),
    );
  }
}

class DashboardContent extends StatefulWidget {
  String userId;
  String position;
  String username;
  String ruasJalan;
  final TargetPlatform platform;


  DashboardContent(this.userId, this.position, this.username,this.ruasJalan,this.platform);

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
  String _localPath;

  _DashboardContentState(this.username, this.position, this.userId);

  String authUser = "";
  String authPosition = "";

  // void downloadFile(String url){
  //   html.AnchorElement anchorElement =  new html.AnchorElement(href: url);
  //   anchorElement.download = url;
  //   anchorElement.click();
  // }

  void getPrefData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      authPosition = prefs.getString(PrefData.POSITION);
      authUser = prefs.getString(PrefData.USERNAME);
    });
    isControlAllowed = true;
    token = prefs.getString(PrefData.TOKEN);
    bloc = BlocProvider.of<DashboardBloc>(context);
    bloc.add(FetchDevice(userId, token, widget.ruasJalan));
  }

  Future<KmlModel> getDataEarth(Result result) async {
    var params = {
      "longitude" : result.hardware.longitude,
      "latitude" : result.hardware.latitude,
      "name" : result.name,
      "hid" : result.hardware.hardwareId
    };
    String url = "http://" +
        FlavorConfig.instance.variables[MyVariables.baseUrl] +
        FlavorConfig.instance.variables[MyVariables.getKml];

    Response response = await Dio().post(url,
      data: jsonEncode(params),
    );

    KmlModel models = KmlModel.fromJsonObject(response.data);
    return models;
  }

  Future<void> _prepareSaveDir() async {
    _localPath =
        (await _findLocalPath()) + Io.Platform.pathSeparator + 'Downloadsavvi';

    final savedDir = Io.Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }

  Future<String> _findLocalPath() async {
    final directory = widget.platform == TargetPlatform.android
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory?.path;
  }

  @override
  void initState() {
    super.initState();
    getPrefData();
    _prepareSaveDir();
    initDownloader();

    const oneSec = const Duration(seconds: 5);
    new Timer.periodic(oneSec, (Timer t) => getPrefData());
  }


  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    print(
        'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
    final SendPort send =
    IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }


  void initDownloader() async {
    WidgetsFlutterBinding.ensureInitialized();
    await FlutterDownloader.initialize(
        debug: true // optional: set false to disable printing logs to console
    );
    FlutterDownloader.registerCallback(downloadCallback);
  }



  Future<void> onRefreshData() async {
    bloc.add(FetchDevice(userId, token, widget.ruasJalan));
  }

  void downloadKml(String downloadUrl, String filename) async {
    print("download di : " + _localPath);
    await FlutterDownloader.enqueue(
      url: downloadUrl,
      savedDir: _localPath,
      showNotification: false, // show download progress in status bar (for Android)
      openFileFromNotification: false, // click on notification to open downloaded file (for Android)
    );
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
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back,
                color: MyColors.grey_40,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            // Flexible(
            //   child: RichText(
            //     maxLines: 1,
            //     textAlign: TextAlign.center,
            //     overflow: TextOverflow.ellipsis,
            //     text: TextSpan(
            //       style: TextStyle(color: MyColors.grey_40,  fontSize: 16.0),
            //       text: username + " | " + widget.ruasJalan,
            //     ),
            //   ),
            // ),
            Expanded(
              flex: 1,
              child: Container(
                width: 70,
                height: 20,
                child: Marquee(
                    text: username + " | " + widget.ruasJalan + "     ",
                    style: TextStyle(fontWeight: FontWeight.w300)),
              ),
              ),
              RaisedButton(
                padding: EdgeInsets.symmetric(vertical: 0,horizontal: 0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: BorderSide(color: MyColors.primary)),
                onPressed: () {
                  Tools.addScreen(context, HistoryScreenMonthly(widget.userId, widget.ruasJalan));
                },
                color: Colors.white,
                textColor: MyColors.primary,
                child: Container(
                    width: 50,
                    child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("kWh/m",
                                style: TextStyle(
                                    fontSize: 13,
                                    color: MyColors.primary)),
                          ],
                        ))),
              )
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
            if(event.items.isNotEmpty){
              if(event.items[0].kml_filename.isNotEmpty && event.items[0].kml_url.isNotEmpty){
                try{
                  // downloadKml(event.items[0].kml_url, event.items[0].kml_filename);
                }catch(e){
                  print("gagal download file " + e);
                }
              }
            }
            // List<Result> lastNewDevice = [];
            // List<String> segments = [];
            // for(Result result in event.items){
            //   var pos = result.name.lastIndexOf('-');
            //
            //   if(pos != null){
            //     var segment = result.name.substring(pos + 1, result.name.length);
            //     if(!segments.contains(segment)){
            //       segments.add(segment);
            //     }
            //   }
            // }
            //
            // for(String segment in segments){
            //   List<Result> veryNewDevices = [];
            //   List<Result> res = [];
            //   Result resSelectedAp;
            //   for(Result result in event.items){
            //     if(result.name.contains(segment)){
            //       res.add(result);
            //     }
            //   }
            //
            //   List<int> aints = [];
            //   for (Result newRes in res){
            //     var aStr = newRes.hardware.hardwareId.replaceAll(new RegExp(r'[^0-9]'),'');
            //     var aInt = int.parse(aStr);
            //     aints.add(aInt);
            //   }
            //
            //
            //   var minimum = aints.reduce(min);
            //   for (Result newRes in res){
            //     var aStr = newRes.hardware.hardwareId.replaceAll(new RegExp(r'[^0-9]'),'');
            //     var aInt = int.parse(aStr);
            //     if(minimum == aInt){
            //       resSelectedAp = newRes;
            //       newRes.setconnectedTo("AP");
            //       veryNewDevices.add(newRes);
            //     }else{
            //       veryNewDevices.add(newRes);
            //       // var correctInt = aInt - 1;
            //       // Result resSelected;
            //       // for (Result newRes2 in res) {
            //       //   var aStr = newRes2.hardware.hardwareId.replaceAll(
            //       //       new RegExp(r'[^0-9]'), '');
            //       //   var aInt = int.parse(aStr);
            //       //   if(aInt == correctInt){
            //       //     resSelected = newRes2;
            //       //   }
            //       // }
            //       // if(resSelected != null){
            //       //   newRes.setconnectedTo(resSelected.name);
            //       // }else{
            //       //   newRes.setconnectedTo("");
            //       // }
            //       // veryNewDevices.add(newRes);
            //     }
            //     aints.add(aInt);
            //   }
            //
            //   for (Result newRes in veryNewDevices){
            //     if(newRes.connectedTo != "AP"){
            //       if(resSelectedAp != null){
            //         newRes.setconnectedTo(resSelectedAp.name);
            //       }
            //       lastNewDevice.add(newRes);
            //     }else{
            //       lastNewDevice.add(newRes);
            //     }
            //   }
            // }

            setState(() {
              isLoading = false;
              isError = false;
              firstLoad = false;

              if (authPosition == "user") {
                List<Result> newDevice = [];
                for (Result result in event.items) {
                  if (result.username == authUser) {
                    newDevice.add(result);
                  }
                }


                item = newDevice;
              } else {
                print("no user" + authUser);
                item = event.items;
              }
              countDevice = item.length;
              isLampLoading = new List(countDevice);
            });
          } else if (event is UpdateLampSuccess) {
            bloc.add(FetchDevice(userId, token, widget.ruasJalan));
          }
        },
        child: isLoading
            ? ProgressLoading()
            : isError
                ? NegativeScenarioView(errorMessage,false, (){
                  bloc.add(FetchDevice(userId, token, widget.ruasJalan));
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
                              return getLampLayout(item, pos, context);
                              // if(item[pos].position == position){
                              //
                              // }else{
                              //   return getUserLayout(item, pos, context);
                              // }
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
            Tools.addScreen(context, HardwareDetailScreen(item[pos].hardware.id, item[pos].name, item[pos].connectedTo));
          },
          onLongPress: (){
            showDialog(context: context,builder: (_) => CustomEventDialog(item[pos].id, token, item[pos].hardware.hardwareId)).then((value) {
              if (value) {
                bloc.add(FetchDevice(userId, token, widget.ruasJalan));
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
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            MyText.myTextHeader2(
                                item[pos].name, MyColors.grey_80),
                            Container(height: 5),
                            Row(
                              children: [
                                Container(
                                  width: 50,
                                  child: MyText.myTextDescription(
                                      'X', MyColors.grey_40),
                                ),
                                MyText.myTextDescription(
                                    ': ', MyColors.grey_40),
                                MyText.myTextDescription(
                                    '${item[pos].hardware.latitude}',
                                    MyColors.grey_40),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 50,
                                  child: MyText.myTextDescription(
                                      'Y', MyColors.grey_40),
                                ),
                                MyText.myTextDescription(
                                    ': ', MyColors.grey_40),
                                MyText.myTextDescription(
                                    '${item[pos].hardware.longitude}',
                                    MyColors.grey_40),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 50,
                                  child: MyText.myTextDescription(
                                      'admin', MyColors.grey_40),
                                ),
                                MyText.myTextDescription(
                                    ': ', MyColors.grey_40),
                                MyText.myTextDescription(
                                    '${item[pos].username}', MyColors.grey_40),
                              ],
                            ),
                          ],
                        ),
                        Spacer(),
                        Container(
                          width: 60,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lightbulb,
                                color: item[pos].hardware.active
                                    ? !item[pos].hardware.lamp
                                        ? item[pos]
                                                    .hardware
                                                    .brightnessSchedule ==
                                                0
                                            ? Colors.red
                                            : Colors.green
                                        : item[pos].hardware.brightness == 0
                                            ? Colors.red
                                            : Colors.green
                                    : Colors.grey,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Visibility(
                                visible: true,
                                child: Text(
                                    item[pos].hardware.active
                                        ? "Online"
                                        : "Offline",
                                    style: TextStyle(fontSize: 10)),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () {
                            if (item[pos].hardware.latitude != null &&
                                item[pos].hardware.longitude != null) {
                              if(kIsWeb){
                                Tools.addScreen(context, GmapSceen(double.parse(item[pos].hardware.latitude),double.parse(item[pos].hardware.longitude), false));
                                // Tools.addScreen(context, MapWeb());
                              }else {
                                HR.Result hardware = new HR.Result(
                                    latitude: item[pos].hardware.latitude,
                                    longitude: item[pos].hardware.longitude,
                                    lamp: item[pos].hardware.lamp);
                                Tools.addScreen(context, MapScreen(hardware));
                              }
                            }
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Color(0xfffcc19e),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.map,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                Text(
                                  "Map",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10),
                                )
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            final ProgressDialog pr = ProgressDialog(context,isDismissible: false);

                            if(kIsWeb){
                              Tools.addScreen(context, GmapSceen(double.parse(item[pos].hardware.latitude),double.parse(item[pos].hardware.longitude), true));
                              // KmlModel kmlModel = await getDataEarth(item[pos]);
                              // downloadFile(kmlModel.downloadUrl);
                            }else{
                              await pr.show();
                              KmlModel kmlModel = await getDataEarth(item[pos]);
                              if(kmlModel != null){
                                print("download kml : " + kmlModel.downloadUrl);
                                downloadKml(kmlModel.downloadUrl, kmlModel.filename);
                                Timer(Duration(seconds: 3), () {
                                  print("open file : " + kmlModel.filename);
                                  openFile(kmlModel.filename);
                                  pr.hide();
                                });
                              }

                            }


                            // try{
                            //   openFile(item[pos].kml_filename);
                            // }catch(e){
                            //   print("gagal buka file " + e);
                            // }


//                             //read and write
//                             final filename = 'test.pdf';
//                             var bytes = await rootBundle.load("assets/apj2.kmz");
//                             String dir = (await getApplicationDocumentsDirectory()).path;
//                             writeToFile(bytes,'$dir/$filename');
// //write to app path
//                             Future<void> writeToFile(ByteData data, String path) {
//                             final buffer = data.buffer;
//                             return new File(path).writeAsBytes(
//                             buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
//                             }
//
//                             final directory = await getapp();
//                             OpenFile.open("assets/apj2.kmz");

                            // HR.Result hardware = new HR.Result(
                            //     latitude: item[pos].hardware.latitude,
                            //     longitude: item[pos].hardware.longitude,
                            //     lamp: item[pos].hardware.lamp);
                            // Tools.addScreen(context, EarthScreen(hardware));
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Color(0xffac9eff),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.streetview,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                Text(
                                  "Street",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10),
                                )
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            if (item[pos].hardware.photoPath != null) {
                              Tools.addScreen(
                                  context,
                                  PhotoScreen("000",
                                      item[pos].hardware.photoPath, "360", "",""));
                            } else {
                              Tools.showToast("Foto belum tersedia");
                            }
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                // color: Color(0xff1367ac),
                                color: Color(0xfffb9e9e)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                Text(
                                  "Photo",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget getUserLayout(List<Result> item, int pos, BuildContext context){
  //   return Container(
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(
  //           horizontal: 10, vertical: 5),
  //       child: InkWell(
  //         onTap: (){
  //           Tools.addScreen(context, UserDetailScreen(item[pos].user, item[pos].position, item[pos].username));
  //         },
  //         onLongPress: (){
  //           // showDialog(context: context,builder: (_) => CustomEventDialog(item[pos].id, token, item[pos].hardware.hardwareId)).then((value) {
  //           //   if (value) {
  //           //     bloc.add(FetchDevice(userId, token));
  //           //   }
  //           // });
  //         },
  //         child: Ink(
  //           color: Colors.red,
  //           child: Card(
  //             shape: RoundedRectangleBorder(
  //                 borderRadius:
  //                 BorderRadius.circular(6)),
  //             color: Colors.white,
  //             elevation: 3,
  //             clipBehavior: Clip.antiAliasWithSaveLayer,
  //             child: Container(
  //               padding: EdgeInsets.all(15),
  //               child: Row(
  //                 crossAxisAlignment:
  //                 CrossAxisAlignment.center,
  //                 children: <Widget>[
  //                   Container(
  //                     width: 60,
  //                       child: Icon(Icons.person, color: Colors.black38,)),
  //                   Container(width: 15),
  //                   Column(
  //                       crossAxisAlignment:
  //                       CrossAxisAlignment.start,
  //                       children: <Widget>[
  //                         MyText.myTextDescription(
  //                             item[pos].username,
  //                             MyColors.grey_80),
  //                         Container(height: 5),
  //                         MyText.myTextDescription(
  //                             item[pos].position,
  //                             MyColors.grey_40),
  //                       ]),
  //                   Spacer(),
  //                   SizedBox(
  //                     width: 40,
  //                     height: 40,
  //                     child: Icon(Icons.arrow_forward_ios_sharp, color: Colors.black38,)
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Future<void> openFile(String filename) async {
    final filePath = _localPath + '/' + filename;
    print(filePath);
    await OpenFile.open(filePath);
  }
}


