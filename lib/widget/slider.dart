import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mylamp_flutter_v4_stable/network/repository/hardware_detail_repository.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_colors.dart';
import 'package:mylamp_flutter_v4_stable/ui/detail/hardware_detail_bloc.dart';
import 'package:mylamp_flutter_v4_stable/ui/detail/hardware_detail_contract.dart';
import 'package:mylamp_flutter_v4_stable/widget/my_sliders.dart';
import 'package:mylamp_flutter_v4_stable/widget/my_snackbar.dart';

class SliderWidget extends StatefulWidget {
  final int value;
  final String hardwareId;

  SliderWidget({this.value, this.hardwareId});

  @override
  _SliderWidgetState createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HardwareDetailBloc>(
          create: (context) => HardwareDetailBloc(HardwareDetailRepositoryImpl()),
        )
      ],
      child: SliderWidgetContent(value: widget.value,hardwareId: widget.hardwareId,),
    );
  }
}



class SliderWidgetContent extends StatefulWidget {
  final double sliderHeight;
  final int min;
  final int max;
  final fullWidth;
  final int value;
  final hardwareId;

  SliderWidgetContent(
      {this.sliderHeight = 48,
        this.max = 100,
        this.min = 0,
        this.value = 0,
        this.fullWidth = false,
        this.hardwareId});

  @override
  _SliderWidgetStateContent createState() => _SliderWidgetStateContent();
}

class _SliderWidgetStateContent extends State<SliderWidgetContent> {
  double _value;
  HardwareDetailBloc bloc;
  bool isError = false;
  String errorMessage;

  @override
  void initState() {
    super.initState();
    _value = widget.value.toDouble()/100;
    bloc = BlocProvider.of<HardwareDetailBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    double paddingFactor = .2;

    if (this.widget.fullWidth) paddingFactor = .3;

    return BlocListener<HardwareDetailBloc, HardwareDetailState>(
      listener: (context, event) {
        if (event is ErrorState) {
          setState(() {
            errorMessage = event.message;
            isError = true;
          });
          MySnackbar.showToast(errorMessage);
        } else if (event is BrightnessUpdated) {

        }
      },
      child: Container(
        width: this.widget.fullWidth
            ? double.infinity
            : (this.widget.sliderHeight) * 5.5,
        height: (this.widget.sliderHeight),
        decoration: new BoxDecoration(
          borderRadius: new BorderRadius.all(
            Radius.circular((this.widget.sliderHeight * .3)),
          ),
          gradient: new LinearGradient(
              colors: [
                MyColors.brownDark,
                MyColors.brownDark,
                // const Color.fromARGB(255, 252, 170, 87),
                // const Color.fromARGB(255, 251, 127, 21),
              ],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(1.0, 1.00),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(this.widget.sliderHeight * paddingFactor,
              2, this.widget.sliderHeight * paddingFactor, 2),
          child: Row(
            children: <Widget>[
              Icon(Icons.brightness_6, color: Colors.white,),
              Expanded(
                child: Center(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.white.withOpacity(1),
                      inactiveTrackColor: Colors.white.withOpacity(.5),

                      trackHeight: 4.0,
                      thumbShape: CustomSliderThumbCircle(
                        thumbRadius: this.widget.sliderHeight * .4,
                        min: this.widget.min,
                        max: this.widget.max,
                      ),
                      overlayColor: Colors.white.withOpacity(.4),
                      //valueIndicatorColor: Colors.white,
                      activeTickMarkColor: Colors.white,
                      inactiveTickMarkColor: Colors.red.withOpacity(.7),
                    ),
                    child: Slider(
                        value: _value,
                        onChangeEnd: (value){
                          var val = (value*100).toInt();
                          if(val == 100) val = 99;
                          bloc.add(UpdateBrightness(widget.hardwareId, val.toString()));
                        },
                        onChanged: (value) {
                          setState(() {
                            _value = value;
                          });
                        }),
                  ),
                ),
              ),
              SizedBox(
                width: this.widget.sliderHeight * .1,
              ),
              Text(
                (_value * 100).toInt().toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: this.widget.sliderHeight * .3,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      )
    );

  }
}