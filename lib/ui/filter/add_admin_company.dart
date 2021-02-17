import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:mylamp_flutter_v4_stable/network/repository/dashboard_repository.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_colors.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_strings.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_variables.dart';
import 'package:mylamp_flutter_v4_stable/ui/dashboard/dashboard_bloc.dart';
import 'package:mylamp_flutter_v4_stable/ui/dashboard/dashboard_contract.dart';
import 'package:mylamp_flutter_v4_stable/ui/filter/user_model.dart';
import 'package:mylamp_flutter_v4_stable/utils/tools.dart';
import 'package:mylamp_flutter_v4_stable/widget/my_snackbar.dart';
import 'package:mylamp_flutter_v4_stable/widget/progress_loading.dart';

class AddAdminDialog extends StatelessWidget {
  UserModelNew company;

  AddAdminDialog(this.company);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DashboardBloc>(
          create: (context) => DashboardBloc(DashboardRepositoryImpl()),
        )
      ],
      child: AddAdminCompany(company),
    );
  }
}

class AddAdminCompany extends StatefulWidget {
  UserModelNew company;

  AddAdminCompany(this.company);

  @override
  _DialogContentState createState() => _DialogContentState();
}

class _DialogContentState extends State<AddAdminCompany> {
  DashboardBloc bloc;
  bool isLoading = false;

  UserModelNew selectedUserAdmin;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<DashboardBloc>(context);
    // bloc.add(FetchUsers(widget.position, widget.referal));
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
        child: Column(
          children: <Widget>[
            Material(
              color: MyColors.primary,
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
                            onTap: () async {
                              if (selectedUserAdmin != null) {
                                setState(() {
                                  isLoading = true;
                                });
                                String url = "http://" +
                                    FlavorConfig.instance
                                        .variables[MyVariables.baseUrl] +
                                    FlavorConfig.instance
                                        .variables[MyVariables.addReferalFrom] +
                                    '/' +
                                    selectedUserAdmin.id +
                                    '/' +
                                    widget.company.referal;

                                var response = await Dio().get(url);
                                if (response.statusCode == 200) {
                                  Navigator.pop(context);
                                } else {
                                  Tools.showToast("Terjadi kesalahan.");
                                }
                              } else {
                                Tools.showToast("Anda belum memilih admin");
                              }
                            },
                          ),
                          visible: true,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Visibility(
                            child: ProgressLoading(
                              color: Colors.white,
                              size: 10,
                              stroke: 1,
                            ),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        widget.company.name + "(${widget.company.username})",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  Center(
                    child: Text("Akan ditambahkan kepada :"),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  DropdownSearch<UserModelNew>(
                    searchBoxController: TextEditingController(),
                    mode: Mode.DIALOG,
                    isFilteredOnline: true,
                    label: 'Admin',
                    showSearchBox: true,
                    onFind: (String filter) async {
                      String query = filter == '' ? '0' : filter;
                      String url = "http://" +
                          FlavorConfig.instance.variables[MyVariables.baseUrl] +
                          FlavorConfig
                              .instance.variables[MyVariables.getAllUserAdmin] +
                          '/' +
                          query;

                      var response = await Dio().get(url);
                      List<UserModelNew> models =
                          UserModelNew.fromJsonList(response.data);
                      return models;
                    },
                    onChanged: (UserModelNew data) {
                      setState(() {
                        selectedUserAdmin = data;
                      });
                    },
                    popupItemDisabled: (item) {
                      return item.referalFrom2.contains(widget.company.referal)
                          ? true
                          : false;
                    },
                    dropdownBuilder: (BuildContext context, UserModelNew item,
                        String itemDesignation) {
                      return Container(
                        child: (item?.id == null)
                            ? ListTile(
                                contentPadding: EdgeInsets.all(0),
                                title: Text(
                                  "Tidak ada admin yang dipilih",
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
                    },
                    popupItemBuilder: (BuildContext context, UserModelNew item,
                        bool isSelected) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        decoration: !isSelected
                            ? null
                            : BoxDecoration(
                                border: Border.all(
                                    color: Theme.of(context).primaryColor),
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.white,
                              ),
                        child: ListTile(
                          selected: isSelected,
                          title: Text(
                            item.name,
                            style: TextStyle(
                                color: item.referalFrom2
                                        .contains(widget.company.referal)
                                    ? MyColors.grey_20
                                    : MyColors.grey_80),
                          ),
                          subtitle: Text(
                            item.username,
                            style: TextStyle(
                                color: item.referalFrom2
                                        .contains(widget.company.referal)
                                    ? MyColors.grey_20
                                    : MyColors.grey_80),
                          ),
                          leading: Icon(
                            Icons.person,
                            color: item.referalFrom2
                                    .contains(widget.company.referal)
                                ? MyColors.grey_20
                                : MyColors.grey_80,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Container(height: 30)
          ],
        ),
      )),
    );
  }
}
