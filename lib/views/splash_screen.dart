import 'dart:async';

import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../res/app_colors.dart';
import '../utils/routes.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(const Duration(seconds: 5), () {
      //Navigator.push(context, MaterialPageRoute(builder: (context) => Login() ));
      Navigator.pushReplacementNamed(context, loginRoute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        body: Column(
            children:<Widget> [
        Expanded(

        flex: 9,
        child: Align(
        alignment: Alignment.center,
              child:Container(
                width: 200,
                height: 200,
                alignment: Alignment.center,

                child:Image.asset("assets/images/wiss.jpg"),

              ),)),
      Expanded(
          flex: 1,
        child: Align(
          alignment: Alignment.bottomCenter,

              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
              child:LinearPercentIndicator(
                animation: true,
                lineHeight: 15,
                animationDuration: 3000,
                percent: 1,
                linearStrokeCap: LinearStrokeCap.roundAll,
                progressColor: orange,

              ),)))

            ],

          ),

        );
  }
}
