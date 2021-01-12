import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mylamp_flutter_v4_stable/network/repository/dashboard_repository.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_strings.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_text.dart';
import 'package:mylamp_flutter_v4_stable/ui/dashboard/dashboard_bloc.dart';
import 'package:mylamp_flutter_v4_stable/ui/dashboard/dashboard_contract.dart';
import 'package:mylamp_flutter_v4_stable/widget/my_snackbar.dart';
import 'package:mylamp_flutter_v4_stable/widget/progress_loading.dart';

class CustomEventDialog extends StatelessWidget {
  String deviceId;
  String token;
  String hardwareId;


  CustomEventDialog(this.deviceId, this.token, this.hardwareId);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DashboardBloc>(
          create: (context) => DashboardBloc(DashboardRepositoryImpl()),
        )
      ],
      child: DialogContent(deviceId, token,hardwareId),
    );
  }
}


class DialogContent extends StatefulWidget {

  String deviceId;
  String token;
  String hardwareId;


  DialogContent(this.deviceId,this.token,this.hardwareId);

  @override
  DialogContentState createState() => new DialogContentState();
}

class DialogContentState extends State<DialogContent>{

  DashboardBloc bloc;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<DashboardBloc>(context);
  }

  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  void fcmUnSubscribe(String topic) {
    firebaseMessaging.unsubscribeFromTopic(topic);
  }


  @override
  Widget build(BuildContext context){
    return BlocListener<DashboardBloc, DashboardState>(
    listener: (context, event) {
      if (event is LoadingState) {
        setState(() {
          isLoading = true;
        });
      } else if(event is ErrorState){
        setState(() {
          isLoading = false;
        });
        MySnackbar.showToast(event.message);
      } else if (event is UpdateLampSuccess){
        fcmUnSubscribe("seti-app-${widget.hardwareId}");
        setState(() {
          isLoading = false;
        });
        Navigator.pop(context, true);
      }
    },
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(width: 160,
          child: Card(
            shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(4),),
            color: Colors.white,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Wrap(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(20),
                  width : double.infinity, color: Colors.red[300],
                  child: Column(
                    children: <Widget>[
                      Container(height: 10),
                      Icon(Icons.delete, color: Colors.white, size: 30),
                      Container(height: 10),
                      Text(MyStrings.deleteDevice, style: MyText.title(context).copyWith(color: Colors.white)),
                      Container(height: 10),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  width : double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Stack(
                        children: [
                          Visibility(
                            visible: !isLoading,
                            child: FlatButton(
                              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 80),
                              shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(18.0)
                              ),
                              child: Text(MyStrings.delete, style: TextStyle(color: Colors.white),),
                              color: Colors.red[300],
                              onPressed: (){
                                bloc.add(DeleteDevice(widget.deviceId, widget.token));
                              },
                            ),
                          ),
                          Visibility(
                              visible: isLoading,
                              child: ProgressLoading(),
                          )
                        ],
                      ),
                      FlatButton(
                        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 80),
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(18.0)
                        ),
                        child: Text(MyStrings.cancel, style: TextStyle(color: Colors.white),),
                        color: Colors.grey[400],
                        onPressed: (){
                          Navigator.pop(context, false);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
