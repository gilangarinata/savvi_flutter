import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fluid_bottom_nav_bar/fluid_bottom_nav_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mylamp_flutter_v4_stable/network/model/UserModel.dart';
import 'package:mylamp_flutter_v4_stable/network/model/response/user_add_device_response.dart';
import 'package:mylamp_flutter_v4_stable/pref_manager/pref_data.dart';
import 'package:mylamp_flutter_v4_stable/network/model/request/update_lamp_request.dart';
import 'package:mylamp_flutter_v4_stable/network/model/response/device_response.dart';
import 'package:mylamp_flutter_v4_stable/network/repository/dashboard_repository.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_button.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_colors.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_field_style.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_strings.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_text.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_variables.dart';
import 'package:mylamp_flutter_v4_stable/ui/bluetooth/DiscoveryPage.dart';
import 'package:mylamp_flutter_v4_stable/ui/bluetooth/setup_bluetooth_dialog.dart';
import 'package:mylamp_flutter_v4_stable/ui/dashboard/add_device_dialog.dart';
import 'package:mylamp_flutter_v4_stable/ui/dashboard/dashboard_bloc.dart';
import 'package:mylamp_flutter_v4_stable/ui/dashboard/dashboard_contract.dart';
import 'package:mylamp_flutter_v4_stable/ui/dashboard/delete_dialog.dart';
import 'package:mylamp_flutter_v4_stable/ui/detail/hardware_detail_screen.dart';
import 'package:mylamp_flutter_v4_stable/ui/filter/add_admin_company.dart';
import 'package:mylamp_flutter_v4_stable/ui/filter/profile_dialog.dart';
import 'package:mylamp_flutter_v4_stable/ui/filter/street_model.dart';
import 'package:mylamp_flutter_v4_stable/ui/filter/user_model.dart';
import 'package:mylamp_flutter_v4_stable/ui/introduction/introduction.dart';
import 'package:mylamp_flutter_v4_stable/ui/signup/signup_screen.dart';
import 'package:mylamp_flutter_v4_stable/ui/userdetail/user_detail_screen.dart';
import 'package:mylamp_flutter_v4_stable/utils/tools.dart';
import 'package:mylamp_flutter_v4_stable/widget/my_snackbar.dart';
import 'package:mylamp_flutter_v4_stable/widget/progress_loading.dart';
import 'package:mylamp_flutter_v4_stable/widget/scenario_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:dropdown_search/dropdown_search.dart';

class FilterScreen extends StatefulWidget {
  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DashboardBloc>(
          create: (context) => DashboardBloc(DashboardRepositoryImpl()),
        )
      ],
      child: DashboardContent(),
    );
  }
}

class DashboardContent extends StatefulWidget {
  @override
  _DashboardContentState createState() => _DashboardContentState();
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
  UserModelNew companySelected;
  StreetModel streetModelSelected;
  String ruasJalanSelected = "";
  String referalFrom;
  List<String> referalFrom2;

  void getPrefData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString(PrefData.USERNAME);
      position = prefs.getString(PrefData.POSITION);
      referral = prefs.getString(PrefData.REFERRAL);
      referalFrom = prefs.getString(PrefData.REFERAL_FROM);
      referalFrom2 = prefs.getStringList(PrefData.REFERAL_FROM_2);
    });

    isControlAllowed = position == KEY_SU_1 ? true : false;

    userId = prefs.getString(PrefData.USER_ID);
    token = prefs.getString(PrefData.TOKEN);
    bloc = BlocProvider.of<DashboardBloc>(context);

  }

  TextEditingController textCompanyController = new TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
    getPrefData();
  }

  Future<void> onRefreshData() async {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          brightness: Brightness.dark,
          title: Image.asset("assets/logo.png", width: 80,),
          iconTheme: IconThemeData(color: MyColors.grey_60),
          actions: <Widget>[
            Visibility(
              visible: isControlAllowed,
              child: IconButton(
                  icon: Icon(
                    Icons.bluetooth,
                    color: MyColors.grey_80,
                  ),
                  onPressed: () {
                    // showDialog(context: context,builder: (_) => SetupBluetoothDialog());
                    Tools.addScreen(
                        context,
                        DiscoveryPage(
                          start: true,
                        ));
                  }),
            ), // overflow menu
          ]),
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
              setState(() {
                isLoading = false;
                isError = false;
                firstLoad = false;
                item = event.items;
                countDevice = item.length;
                isLampLoading = new List(countDevice);
              });
            } else if (event is UpdateLampSuccess) {

            }
          },
          child: ListView(
            children: [
              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                child: Row(
                  children: [
                    InkWell(
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: MyColors.primary,
                        child: CircleAvatar(
                          backgroundImage:
                          AssetImage('assets/img_person.jpg'),
                          radius: 28,
                        ),
                      ),
                      onTap: () async {
                        showDialog(
                            context: context, builder: (_) => ProfileDialog());
                      },
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText.myTextHeader2(
                            username, MyColors.grey_80),
                        MyText.myTextDescription(
                            position, MyColors.primary),
                        MyText.myTextDescription(
                            referral, MyColors.primary)
                      ],
                    ),
                    Expanded(
                      child: SizedBox(),
                    ),
                  ],
                ),
              ),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  color: Colors.white,
                  child: Column(
                    children: [
                      DropdownSearch<UserModelNew>(
                        searchBoxController: textCompanyController,
                        mode: Mode.BOTTOM_SHEET,
                        isFilteredOnline: true,
                        showSearchBox: true,
                        label: 'Instansi',
                        onFind: (String filter) => getDataCompany(filter),
                        onChanged: (UserModelNew data) {
                          setState(() {
                            ruasJalanSelected = "";
                          });

                          if (!isControlAllowed) {
                            if (position == "user") {
                              if (!referalFrom2.contains(data.referal)) {
                                setState(() {
                                  Tools.showToast(
                                      "Kamu tidak bisa memilih instansi ini");
                                });
                                return;
                              }
                            }else {
                              if (data.username != username) {
                                setState(() {
                                  Tools.showToast(
                                      "Kamu tidak bisa memilih instansi ini");
                                });
                                return;
                              }
                            }
                          }

                          setState(() {
                            companySelected = data;
                          });
                        },
                        popupItemDisabled: (data) {
                          return !isControlAllowed
                              ? position == "user"
                                  ? !referalFrom2.contains(data.referal)
                                      ? true
                                      : false
                                  : data?.username != username
                              : false;
                        },
                        dropdownBuilder: _dropDownCompany,
                        popupItemBuilder: _customPopupCompanyBuilderExample,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      DropdownSearch<StreetModel>(
                        searchBoxController: TextEditingController(text: ''),
                        mode: Mode.BOTTOM_SHEET,
                        isFilteredOnline: true,
                        showSearchBox: true,
                        label: MyStrings.ruasJalan,
                        onFind: (String filter) => getDataStreet(filter),
                        onChanged: (StreetModel data) {
                          if (companySelected != null) {
                            if (!data.referalFrom2
                                .contains(companySelected.referal)) {
                              return;
                            }
                          }

                          setState(() {
                            ruasJalanSelected = data.ruasJalan;
                            streetModelSelected = data;
                          });
                        },
                        popupItemDisabled: (data) {
                          if (companySelected != null) {
                            if (data.referalRuasFrom !=
                                companySelected.referal) {
                              return true;
                            } else {
                              return false;
                            }
                          } else {
                            return true;
                          }
                        },
                        dropdownBuilder: _dropDownStreet,
                        popupItemBuilder: _customPopupStreetBuilderExample,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            side: BorderSide(color: MyColors.primary)),
                        onPressed: () {
                          if(companySelected != null){
                            if(ruasJalanSelected.isNotEmpty){
                              Tools.addScreen(
                                  context,
                                  UserDetailScreen(
                                      companySelected.id,
                                      companySelected.position,
                                      companySelected.name,
                                      ruasJalanSelected
                                  ));
                            }else{
                              Tools.showToast("Anda belum memilih ruas jalan");
                            }
                          }else{
                            Tools.showToast("Anda belum memilih instansi");
                          }

                        },
                        padding: EdgeInsets.symmetric(vertical: 10),
                        color: MyColors.primary,
                        textColor: Colors.white,
                        child: Container(
                            width: double.infinity,
                            child: Center(
                                child: Text(MyStrings.tampilkan,
                                    style: TextStyle(fontSize: 12)))),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 50),
                        width: double.infinity,
                        height: 1,
                        color: MyColors.grey_20,
                      ),

                      Visibility(
                        visible: isControlAllowed,
                        child: Column(
                          children: [
                            RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  side: BorderSide(color: MyColors.primary)),
                              onPressed: () {
                                Tools.addScreen(context, SignUpScreen(true,referral));
                              },
                              padding: EdgeInsets.symmetric(vertical: 10),
                              color: Colors.white,
                              textColor: MyColors.primary,
                              child: Container(
                                  width: double.infinity,
                                  child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                      Icon(
                                        Icons.add_business_outlined,
                                        color: MyColors.primary,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text("Tambah Instansi",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: MyColors.primary)),
                                    ],
                                      ))),
                            ),
                            SizedBox(height: 20,),
                            RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  side: BorderSide(color: companySelected == null ? MyColors.grey_20 : MyColors.primary)),
                              onPressed: () {
                                if(companySelected != null){
                                  Tools.addScreen(context, SignUpScreen(false,companySelected.referal));
                                }else{
                                  Tools.showToast("Pilih instansi yang akan ditambahkan.");
                                }
                              },
                              padding: EdgeInsets.symmetric(vertical: 10),
                              color: Colors.white,
                              textColor: MyColors.primary,
                              child: Container(
                                  width: double.infinity,
                                  child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.person_add,color: companySelected == null ? MyColors.grey_20 : MyColors.primary,),
                                          SizedBox(width: 10,),
                                          Text("Tambah Admin",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: companySelected == null
                                                  ? MyColors.grey_20
                                                  : MyColors.primary)),
                                    ],
                                  ))),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  side: BorderSide(
                                      color: companySelected == null
                                          ? MyColors.grey_20
                                          : MyColors.primary)),
                              onPressed: () {
                                if (companySelected != null) {
                                  showDialog(
                                          context: context,
                                          builder: (_) =>
                                              AddAdminDialog(companySelected))
                                      .then((value) {
                                    if (value) {}
                                  });
                                } else {
                                  Tools.showToast(
                                      "Anda belum memilih instansi");
                                }
                              },
                              padding: EdgeInsets.symmetric(vertical: 10),
                              color: Colors.white,
                              textColor: MyColors.primary,
                              child: Container(
                                  width: double.infinity,
                                  child: Center(
                                      child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.group_add_outlined,
                                        color: companySelected == null
                                            ? MyColors.grey_20
                                            : MyColors.primary,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text("Tambah Instansi untuk Admin",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: companySelected == null
                                                  ? MyColors.grey_20
                                                  : MyColors.primary)),
                                    ],
                                  ))),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  side: BorderSide(
                                      color: companySelected == null
                                          ? MyColors.grey_20
                                          : MyColors.primary)),
                              onPressed: () {
                                if (companySelected != null) {
                                  showDialog(
                                      context: context,
                                      builder: (_) => AddDeviceDialog(
                                          userId,
                                          token,
                                          username,
                                          position,
                                          companySelected.referal,
                                          ruasJalanSelected)).then((value) {
                                    if (value) {}
                                  });
                                } else {
                                  Tools.showToast("Pilih instansi yang akan ditambahkan.");
                                }
                              },
                              padding: EdgeInsets.symmetric(vertical: 10),
                              color: Colors.white,
                              textColor: MyColors.primary,
                              child: Container(
                                  width: double.infinity,
                                  child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.lightbulb_outlined,color: companySelected == null ? MyColors.grey_20 : MyColors.primary,),
                                          SizedBox(width: 10,),
                                          Text("Tambah Lampu",
                                              style: TextStyle(fontSize: 12,color: companySelected == null ? MyColors.grey_20 : MyColors.primary)),
                                        ],
                                      ))),
                            ),
                          ],
                        ),
                      )


                    ],
                  ))
            ],
          )),
    );
  }

  Widget _dropDownCompany(
      BuildContext context, UserModelNew item, String itemDesignation) {
    return Container(
      child: (item?.id == null) ||
              (!isControlAllowed
                  ? position == "user"
                      ? !referalFrom2.contains(item.referal)
                          ? true
                          : false
                      : item?.username != username
                  : false)
          ? ListTile(
              contentPadding: EdgeInsets.all(0),
              title: Text(
                MyStrings.noInstansiItemSelected,
                style: TextStyle(color: MyColors.grey_40),
              ),
            )
          : ListTile(
              contentPadding: EdgeInsets.all(0),
              leading: Icon(Icons.person),
              title: Text(item.name),
              subtitle: Text(
                item.username,
              ),
            ),
    );
  }

  Widget _customPopupCompanyBuilderExample(
      BuildContext context, UserModelNew item, bool isSelected) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: !isSelected
          ? null
          : BoxDecoration(
              border: Border.all(color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
      child: ListTile(
        selected: isSelected,
        title: Text(
          item.name,
          style: TextStyle(
              color: !isControlAllowed
                  ? position == "user"
                      ? referalFrom2.contains(item.referal)
                          ? MyColors.grey_80
                          : MyColors.grey_20
                      : username == item.username
                          ? MyColors.grey_80
                          : MyColors.grey_20
                  : MyColors.grey_80),
        ),
        subtitle: Text(
          item.username,
          style: TextStyle(
              color: !isControlAllowed
                  ? position == "user"
                      ? referalFrom2.contains(item.referal)
                          ? MyColors.grey_80
                          : MyColors.grey_20
                      : username == item.username
                          ? MyColors.grey_80
                          : MyColors.grey_20
                  : MyColors.grey_80),
        ),
        leading: Icon(Icons.person,
            color: !isControlAllowed
                ? position == "user"
                    ? referalFrom2.contains(item.referal)
                        ? MyColors.grey_80
                        : MyColors.grey_20
                    : username == item.username
                        ? MyColors.grey_80
                        : MyColors.grey_20
                : MyColors.grey_80),
      ),
    );
  }

  Widget _dropDownStreet(
      BuildContext context, StreetModel item, String itemDesignation) {
    return Container(
      child: (item?.ruasJalan == null) || ruasJalanSelected.isEmpty
          ? ListTile(
              contentPadding: EdgeInsets.all(0),
              title: Text(
                MyStrings.noRuasSelected,
                style: TextStyle(color: MyColors.grey_40),
              ),
            )
          : ListTile(
              contentPadding: EdgeInsets.all(0),
              title: Text(item.ruasJalan),
            ),
    );
  }

  Widget _customPopupStreetBuilderExample(
      BuildContext context, StreetModel item, bool isSelected) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: !isSelected
          ? null
          : BoxDecoration(
              border: Border.all(color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
      child: ListTile(
          selected: isSelected,
          title: Text(
            item.ruasJalan,
            style: TextStyle(
                color:
                    isSelectable(item) ? MyColors.grey_80 : MyColors.grey_20),
          )),
    );
  }

  bool isSelectable(StreetModel item) {
    if (companySelected != null) {
      if (item.referalRuasFrom == companySelected.referal) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }

    // if(companySelected != null){
    //   if(item.referalFrom == companySelected.referal){
    //     return true;
    //   }else{
    //     return false;
    //   }
    // }else{
    //   return true;
    // }
  }

  Future<List<UserModelNew>> getDataCompany(filter) async {
    String query = filter == '' ? '0' : filter;
    String url = "http://" +
        FlavorConfig.instance.variables[MyVariables.baseUrl] +
        FlavorConfig.instance.variables[MyVariables.getUserQuery] +
        "/" +
        query;
    var response = await Dio().get(url);
    List<UserModelNew> models = UserModelNew.fromJsonList(response.data);
    return models;
  }

  Future<List<StreetModel>> getDataStreet(filter) async {
    String query = filter == '' ? '0' : filter;
    var params = {
      "query": query,
    };
    String url = "http://" +
        FlavorConfig.instance.variables[MyVariables.baseUrl] +
        FlavorConfig.instance.variables[MyVariables.getStreet];

    Response response = await Dio().post(url,
      options: Options(headers: {
        HttpHeaders.contentTypeHeader: "application/json",
      }),
      data: jsonEncode(params),
    );

    List<StreetModel> models = StreetModel.fromJsonList(response.data);
    return models;
  }

}
