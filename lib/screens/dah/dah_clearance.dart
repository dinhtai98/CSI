import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/queries/dah.dart';
import 'package:flutter_helloworld/queries/hatchery.dart';
import 'package:flutter_helloworld/screens/photo/view_image.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_helloworld/utils/function.dart';
import '../../translations.dart';

class DAHClearance extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new DAHClearanceState();
  }
}
class DAHClearanceState extends State<DAHClearance> {
  List<String> getData;
  String idCon = "",idStaff = "", idDAH = "";
  String idDAR, senderName, receiverName, content, hatcheryName, arrivalTimeHatchery;
  bool checkVisible = false;
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
  AsyncMemoizer<Data> memCache = AsyncMemoizer();

  Future<Data> _DAHInfoClearance(String idCon) {
    return memCache.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(
              DAH.queryDAHFindDARDAndArrivalTimeHatFromContract(idCon)),
          encoding: Encoding.getByName("UTF-8")
      );
      Data data = new Data();
      var p = response.body.indexOf("[");
      var e = response.body.lastIndexOf("]");
      var result = response.body.substring(p, e + 1);
      //setState(() {
      List jsonData = json.decode(result);
      if(jsonData.length > 0){
        data = Data.fromJson(jsonData[0]);
        if(data.att5.toString() == "null"){
          setState(() {
            checkVisible = true;
          });
        }
      }

      return data;
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

  _dahUploadImageAndClearance(BuildContext context, String idCon) async {
    if (file == null) {
      Toast.show(Translations.of(context).text('please_choose_image'), context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    } else {
      pr = new ProgressDialog(context,type: ProgressDialogType.Normal);
      pr.style(
        message: Translations.of(context).text('please_wait'),
      );
      pr.show();
      String photo = '${Api.urlImageDAHClearance}$idCon.jpg';
      String querySQL = DAH.queryDAHClearanceInfoToDARD(
          idCon, idStaff, photo,idDAH,idDAR,senderName,receiverName,content);
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
      request.fields['att1'] = "dahclearance";
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
        if (result == "1") {
          Future.delayed(Duration(seconds: 2)).then((value) {
            pr.hide().whenComplete((){
              function.pushNotification(
                  context, '$idDAR^dard_quarantine^$idCon^$hatcheryName-$arrivalTimeHatchery');
              Toast.show(Translations.of(context).text('saved'), context,
                  duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
              Navigator.pop(context);
            });
          });
        } else {
          Future.delayed(Duration(seconds: 2)).then((value) {
            pr.hide().whenComplete((){
              Toast.show(Translations.of(context).text('error'), context,
                  duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
            });
          });
        }
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = buildPrimaryThemeData(context);
    getData = InheritedProvider.of<List<String>>(context);
    idCon = getData[0];
    idStaff = getData[1];
    idDAH = getData[2];
    //Data data = InheritedProvider.of<Data>(context);
    return new Scaffold(
        appBar: new AppBar(
          title: Text(
              Translations.of(context).text('custom_clearance')),
          actions: <Widget>[
            Visibility(
              child: IconButton(
                icon: Icon(Icons.photo),
                onPressed: () {
                  pickImageFromGallery();
                },
              ),
              visible: checkVisible,
            ),
            Visibility(
              child: IconButton(
                icon: Icon(Icons.photo_camera),
                onPressed: () {
                  openCamera();
                },
              ),
              visible: checkVisible,
            ),
          ],
        ),
        body: new FutureBuilder(
            future:_DAHInfoClearance(idCon),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if(snapshot.hasError){
                return ViewsWidget.buildNoInternet(context,(){
                  setState(() {
                    memCache = AsyncMemoizer();
                  });
                });
              }else if(snapshot.hasData && snapshot.connectionState == ConnectionState.done){
                Data data = snapshot.data;

                String checkClearance = data.att5.toString();
                idDAR = data.att1.toString();
                senderName = "null";
                receiverName = data.att4.toString();
                content = "quarantine at hatchery";
                hatcheryName = data.att3.toString();
                print('data2 ${data.att2.toString()}');
                arrivalTimeHatchery = function.convertDateCSDLToDateTimeDefault(data.att2.toString());
                return checkClearance != "null" ? dahClearanceDone(data) : dahClearanceNotYet(themeData);
              }
              return ViewsWidget.buildPleaseWait();
            }),
    );
  }
  Widget dahClearanceDone(Data data){
    imageCache.clear();
    return  Card(
      //elevation: 5.0,
      child: Column(
        children: <Widget>[
          ViewsWidget.buildRowDetails(context, 'id_contract', data.att5.toString()),
          ViewsWidget.buildRowDetails(context, 'staff', data.att9.toString()),
          ViewsWidget.buildRowDetails(context, 'status', data.att8.toString() == "1" ?
          Translations.of(context).text('approve') : Translations.of(context).text('unapprove')),
          ViewsWidget.buildRowDetails(context, 'date', '${function.convertDateCSDLToDateTimeDefault(data.att7)}'),
          GestureDetector(
              child: CachedNetworkImage(
                  height: 450,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.fill,
                  imageUrl: "${data.att6}",
                  placeholder: (context, url) => ViewsWidget.buildPleaseWait(),
                  errorWidget: (context, url, error) => new Icon(Icons.error)
              ),
              onTap: () {
                Navigator.of(context).push(new MaterialPageRoute<Null>(
                    builder: (_) =>
                        InheritedProvider<String>(
                          child: new ViewImage() ,
                          inheritedData: "${data.att6}",
                        ))).then((onValue) {
                  setState(() {
                    memCache = AsyncMemoizer();
                  });
                });
              }
          ),
        ],
      ),
    );
  }
  Widget dahClearanceNotYet(ThemeData themeData){
    TextStyle styleButton = TextStyle(fontFamily: 'Google sans', fontSize: 16.0,color: Colors.white);
    return  Column(
      children: <Widget>[
        showImage(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
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

                  },
                  child: Text(Translations.of(context).text('unapprove'),
                      textAlign: TextAlign.center,
                      style: styleButton),
                ),
              ),
            ),
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
                    _dahUploadImageAndClearance(
                        context, idCon);
                  },
                  child: Text(Translations.of(context).text('approve'),
                      textAlign: TextAlign.center,
                      style: styleButton),
                ),
              ),
            )

          ],
        ),
      ],
    );
  }
}
