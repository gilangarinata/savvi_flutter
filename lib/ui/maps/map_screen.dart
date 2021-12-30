
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:latlong/latlong.dart';
import 'package:mylamp_flutter_v4_stable/network/model/response/hardware_response.dart';
import 'package:mylamp_flutter_v4_stable/network/model/response/history_response.dart';
import 'package:mylamp_flutter_v4_stable/network/repository/history_repository.dart';
import 'package:mylamp_flutter_v4_stable/pref_manager/pref_data.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_colors.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_strings.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_text.dart';
import 'package:mylamp_flutter_v4_stable/ui/history/history_bloc.dart';
import 'package:mylamp_flutter_v4_stable/ui/history/history_contract.dart';
import 'package:mylamp_flutter_v4_stable/widget/my_snackbar.dart';
import 'package:mylamp_flutter_v4_stable/widget/progress_loading.dart';
import 'package:mylamp_flutter_v4_stable/widget/scenario_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapScreen extends StatefulWidget {
  Result harware;

  MapScreen(this.harware);

  @override
  _MapScreenScreenState createState() => _MapScreenScreenState();
}

class _MapScreenScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HistoryBloc>(
          create: (context) =>
              HistoryBloc(HistoryRepositoryImpl()),
        )
      ],
      child: HistoryContent(widget.harware),
    );
  }
}

class HistoryContent extends StatefulWidget {
  Result hardware;

  HistoryContent(this.hardware);

  @override
  _HistoryContentState createState() => _HistoryContentState();
}

class _HistoryContentState extends State<HistoryContent> {
  HistoryBloc bloc;
  String token;
  List<History> item;
  bool isLoading = false;
  bool isError = false;
  bool firstLoad = true;
  String errorMessage;
  String date;

  void getPrefData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString(PrefData.TOKEN);
    bloc = BlocProvider.of<HistoryBloc>(context);
  }

  @override
  void initState() {
    super.initState();
    debugPrint(widget.hardware.latitude);
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
        title: MyText.myTextHeader1(MyStrings.map, Colors.white),
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
                ? NegativeScenarioView(errorMessage, false, () {})
                : Container(
                    child: FlutterMap(
                      options: new MapOptions(
                        center: new LatLng(
                            double.parse(widget.hardware.latitude),
                            double.parse(widget.hardware.longitude)),
                        zoom: 15.0,
                      ),
                      layers: [
                        new TileLayerOptions(
                            urlTemplate:
                                "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                            subdomains: ['a', 'b', 'c']),
                        new MarkerLayerOptions(
                          markers: [
                            new Marker(
                              width: 80.0,
                              height: 80.0,
                              point: new LatLng(
                                  double.parse(widget.hardware.latitude),
                                  double.parse(widget.hardware.longitude)),
                              builder: (ctx) => new Container(
                                child: widget.hardware.lamp != null
                                    ? widget.hardware.lamp
                                        ? SvgPicture.asset('assets/ic_lamp.svg')
                                        : SvgPicture.asset(
                                            'assets/ic_lamp_off.svg')
                                    : SvgPicture.asset(
                                        'assets/ic_lamp_off.svg'),
                              ),
                            ),
                          ],
                        ),
                      ],
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
