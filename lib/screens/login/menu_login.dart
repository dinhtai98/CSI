import 'package:flutter/material.dart';
import 'package:flutter_helloworld/style/colors.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/views/view.dart';

import '../../translations.dart';
import 'login.dart';

class MenuLogin extends StatelessWidget  {

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = buildPrimaryThemeData(context);
    return Material(
      child: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            color: kColorBackground,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset("assets/images/background.jpg",fit: BoxFit.fill,
                    width: MediaQuery.of(context).size.width,
                    height: 200,),
                  Padding(
                    padding: EdgeInsets.fromLTRB(150.0, 10.0, 10.0, 10.0),
                    child: Row(
                      children: [
                        Icon(Icons.arrow_right, color: Colors.white,),
                        Text(Translations.of(context).text('login'),
                            textAlign: TextAlign.center,
                            style: themeData.primaryTextTheme.button),
                        Icon(Icons.arrow_left, color: Colors.white,),
                      ],
                    ),
                  ),
                  ViewsWidget.buildMenu(context,'admin',(){
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Login(type: 0))
                    );
                  }),
                  ViewsWidget.buildMenu(context,'management_authorities',(){
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Login(type: 1,)));
                  }),
                  ViewsWidget.buildMenu(context,'producers',(){
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Login(type: 2,)));
                  }),
                  ViewsWidget.buildMenu(context,'disease_screening_agency',(){
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Login(type: 3,)));
                  }),
                  ViewsWidget.buildMenu(context,'postlarvae_buyers',(){
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Login(type: 4,)));
                  }),
                  ViewsWidget.buildMenu(context,'workforce',(){
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Login(type: 5,)));
                  }),
                  Container(
                    margin: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                    child: Column(
                      children: <Widget>[
                        Image.asset("assets/images/logo_csiro.png",fit: BoxFit.cover,
                          width: 80,height: 80,),
                        Text("Exclusively licensed to Directorate of Fisheries of Vietnam\nAll rights reserved @ CSIRO",
                          style:TextStyle(fontSize: 12,fontStyle: FontStyle.italic,color: Colors.grey[200]),textAlign: TextAlign.center,),
                      ],
                    ),
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
  _onAction(){

  }
}