import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_helloworld/screens/login/menu_login.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/translations.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:image_picker/image_picker.dart';

class DeclareAuthoriry extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new DeclareAuthoriryState();
  }

// This widget is the root of your application.

}
class DeclareAuthoriryState extends State<DeclareAuthoriry> {
  TextStyle styleButton = TextStyle(fontFamily: 'Google sans', fontSize: 16.0,color: Colors.white);
  File file;
  Future<File> imageFile;

  var  txtWebsite = new TextEditingController(), txtAvatar = new TextEditingController(),
      txtAddress = new TextEditingController(), txtImmediateSupervising = new TextEditingController(),
      txtPhone = new TextEditingController(), txtNStaff = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = buildPrimaryThemeData(context);
    // TODO: implement build
    return SafeArea(
      child: Scaffold(
        appBar: ViewsWidget.getAppBar(context,'declaration'),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  showImage(),
                  Positioned(
                    child: IconButton(
                      icon: Icon(Icons.photo, size: 30),
                      onPressed: () {
                        pickImageFromGallery();
                      },
                    ),
                    bottom: 10,
                    right: 10,
                  ),
                  Positioned(
                    child:IconButton(
                      icon: Icon(Icons.photo_camera, size: 30),
                      onPressed: () {
                        openCamera();
                      },
                    ),
                    bottom: 10,
                    right: 50,
                  )
                ],
              ),
              ViewsWidget.buildInputRow(context, txtWebsite,'website', 'hint_website',themeData ),
              ViewsWidget.buildInputRow(context, txtAddress,'address_authority', 'hint_address_authority',themeData ),
              ViewsWidget.buildInputPhoneNumberRow(context, txtPhone,'mobile_phone', 'hint_mobile_phone',themeData ),
              ViewsWidget.buildInputRow(context, txtNStaff,'number_of_staff', 'hint_number_of_staff',themeData ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                width: 120,
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(25.0),
                  color: Color(0xff01A0C7),
                  child: MaterialButton(
                    //minWidth: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                    onPressed: (){
                     // _dahUploadImageAndClearance(context, idCon);
                    },
                    child: Text(Translations.of(context).text('confirm'),
                        textAlign: TextAlign.center,
                        style: styleButton),
                  ),
                ),
              )
            ],
          )
        )
      ),
    );
  }
  Widget showImage() {
    return FutureBuilder<File>(
      future: imageFile,
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          file = snapshot.data;
          return Container(
            width: MediaQuery.of(context).size.width,
            height: 450,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fill,
                image: FileImage(file),
              ),
            ),
          );
        } else if (snapshot.error != null || file == null) {
          return Container(
            width: MediaQuery.of(context).size.width,
            height: 450,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage('assets/images/noimage.png'),
              ),
            ),
          );
        }else if(file != null){
          if(snapshot.connectionState == ConnectionState.waiting){
            return new Center(
                child: CircularProgressIndicator());
          }
          return Container(
            width: MediaQuery.of(context).size.width,
            height: 450,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fill,
                image: FileImage(file),
              ),
            ),
          );
        }
        else{
          return new Center(
              child: CircularProgressIndicator());
        }

      },
    );
  }
  pickImageFromGallery() {
    setState(() {
      imageFile = ImagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 75,
          maxHeight: 1200,
          maxWidth: 1200
      );
    });
  }
  openCamera(){
    setState(() {
      imageFile = ImagePicker.pickImage(source: ImageSource.camera, imageQuality: 75,maxHeight: 1200, maxWidth: 1200);
    });
  }
}