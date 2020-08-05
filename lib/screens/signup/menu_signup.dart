
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/screens/CSSX/declare_hatchery.dart';
import 'package:flutter_helloworld/screens/NguoiLaoDong/dangky_nguoilaodong.dart';
import 'package:flutter_helloworld/screens/NguoiMuaTomGiong/dangky_nguoimuatomgiong.dart';
import 'package:flutter_helloworld/style/colors.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/views/view.dart';

import '../../translations.dart';

class MenuSignup extends StatelessWidget  {

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = buildPrimaryThemeData(context);
    return Material(
      child: Stack(
        children: <Widget>[
          Container(
            //alignment: Alignment.center,
            height: MediaQuery.of(context).size.height,
            color: kColorBackground,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Image.asset("assets/images/background.jpg",fit: BoxFit.fill,
                    width: MediaQuery.of(context).size.width,
                    height: 200,),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(Translations.of(context).text('signup'),
                        textAlign: TextAlign.center,
                        style: themeData.primaryTextTheme.button),
                  ),
                  /*
                  ViewsWidget.buildMenu(context,'producers',(){
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => DeclareHatchery()));
                  }),

                   */
                  ViewsWidget.buildMenu(context,'postlarvae_buyers',(){
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SignUpBuyer()));
                  }),
                  ViewsWidget.buildMenu(context,'workforce',(){
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SignUpWorker()));
                  }),
                  SizedBox(height: 100.0),
                  Column(
                    children: <Widget>[
                      Image.asset("assets/images/logo_csiro.png",fit: BoxFit.cover,
                        width: 80,height: 80,),
                      Text("Exclusively licensed to Directorate of Fisheries of Vietnam\nAll rights reserved @ CSIRO",
                        style:TextStyle(fontSize: 12,fontStyle: FontStyle.italic,color: Colors.grey),textAlign: TextAlign.center,),
                    ],
                  )
                ],
              ),
            )
          ),
          Positioned(
            left: 20,
            top: 20,
            child: IconButton(
              icon: Icon(Icons.arrow_back,color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          )
        ],
      ),
    );
  }
}

