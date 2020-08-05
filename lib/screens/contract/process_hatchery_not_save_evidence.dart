import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/queries/hatchery.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_helloworld/screens/home_screen.dart';
import '../../translations.dart';

class HatcheryNotYetSaveEvidence extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new HatcheryNotYetSaveEvidenceState();
  }
}
class HatcheryNotYetSaveEvidenceState extends State<HatcheryNotYetSaveEvidence> {
  ProgressDialog pr;
  Future<File> imageFile;
  File file;
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
        } else if (snapshot.error != null) {
          return const Text(
            'Error Picking Image',
            textAlign: TextAlign.center,
          );
        } else if(file == null){
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

  _uploadImageAndSaveEvidence(BuildContext context, String idCon) async {
    SharedPreferences shared_User = await SharedPreferences.getInstance();
    Map userMap = jsonDecode(shared_User.getString('user'));
    Data user = Data.fromJson(userMap);
    if (file == null) {

      Toast.show(Translations.of(context).text('please_choose_image'), context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    } else {
      pr = new ProgressDialog(context,type: ProgressDialogType.Normal);
      //pr.setMessage(Translations.of(context).text('please_wait'));
      pr.style(
        message: Translations.of(context).text('please_wait'),
      );
      pr.show();
      String idStaff = '${user.att10.toString()}';
      String photo = '${Api.urlImageCustomClearance}$idCon.jpg';
      String querySQL = Hatchery.queryHatcherySaveEvidence(
          idCon, idStaff, photo);
      // open a bytestream
      Stream stream = new http.ByteStream(
          DelegatingStream.typed(file.openRead()));
      // get file length
      var length = await file.length();

      // string to uri
      var uri = Uri.parse(Api.url_insert_postimage_json);

      // create multipart request
      var request = new http.MultipartRequest("POST", uri);
      // multipart that takes file
      var multipartFile = new http.MultipartFile('att4', stream, length,
          filename: idCon);
      request.fields['att1'] = "customclearance";
      request.fields['att2'] = querySQL;
      request.fields['att3'] = idCon;
      // add file to multipart
      request.files.add(multipartFile);

      // send
      var response = await request.send();
      // listen for response
      response.stream.transform(utf8.decoder).listen((value) {
        var p = value.indexOf(">");
        var e = value.lastIndexOf("<");
        var result = value.substring(p + 1, e);
        print('status ${response.statusCode}');
        if (result == "1") {
          Future.delayed(Duration(seconds: 2)).then((value) {
            pr.hide().whenComplete((){
              Toast.show(Translations.of(context).text('saved'), context,
                  duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
              Navigator.pop(context);
            });
          });
        } else {
          Future.delayed(Duration(seconds: 2)).then((value) {
            pr.hide().whenComplete(() {
              Navigator.pop(context);
              Toast.show(Translations.of(context).text('error'), context,
                  duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
            });
          });
        }
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    ThemeData themeData = buildPrimaryThemeData(context);
    String idCon = InheritedProvider.of<String>(context);
    //Data data = InheritedProvider.of<Data>(context);
    return new Scaffold(
        appBar: new AppBar(
          title: Text(
              Translations.of(context).text('hatchery_save_evidence')
          ),
          centerTitle: true,
          flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2db7d1), Color(0xff55ceb1)],
                ),
              )
          ),
          actions: <Widget>[
            // action button
            IconButton(
              icon: Icon(Icons.photo),
              onPressed: () {
                pickImageFromGallery();
              },
            ),
            // action button
            IconButton(
              icon: Icon(Icons.photo_camera),
              onPressed: () {
                openCamera();
              },
            ),
            // overflow menu
          ],
        ),
        body://ScopedModelDescendant<Data>(
            //builder: (BuildContext context, Widget child, Data staffData) {
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    showImage(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 25.0),
                          width: 120,
                          child: Material(
                            elevation: 5.0,
                            borderRadius: BorderRadius.circular(30.0),
                            color: Color(0xff01A0C7),
                            child: MaterialButton(
                              //minWidth: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.fromLTRB(
                                  20.0, 15.0, 20.0, 15.0),
                              onPressed: () {
                                _uploadImageAndSaveEvidence(
                                    context, idCon);
                              },
                              child: Text(Translations.of(context).text('save'),
                                  textAlign: TextAlign.center,
                                  style: themeData.primaryTextTheme.button),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              )
            //})
    );
  }

}
