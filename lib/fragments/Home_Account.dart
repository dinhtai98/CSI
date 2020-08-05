import 'dart:async';
import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/dialog/dialog_change_password.dart';
import 'package:flutter_helloworld/dialog/dialog_input_rating.dart';
import 'package:flutter_helloworld/dialog/dialog_input_transportation_information.dart';
import 'package:flutter_helloworld/dialog/dialog_view_rating.dart';
import 'package:flutter_helloworld/dialog/dialog_view_transportation.dart';
import 'package:flutter_helloworld/queries/contract.dart';
import 'package:flutter_helloworld/queries/dah.dart';
import 'package:flutter_helloworld/queries/dard.dart';
import 'package:flutter_helloworld/queries/hatchery.dart';
import 'package:flutter_helloworld/queries/nguoilaodong.dart';
import 'package:flutter_helloworld/queries/trader.dart';
import 'package:flutter_helloworld/screens/hatchery/detail_hatchery.dart';
import 'package:flutter_helloworld/screens/hatchery/history_working_staff.dart';
import 'package:flutter_helloworld/screens/photo/view_image.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_helloworld/utils/function.dart';

import '../translations.dart';


class HomeAccount extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new HomeAccountState();
  }
}
class HomeAccountState extends State<HomeAccount> {
  Data data;
  String querySQL,idUser;

  AsyncMemoizer<Data> memCache = AsyncMemoizer();
  Future<Data> _getInfoStaff(String query) async{
    return memCache.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(query),
          encoding: Encoding.getByName("UTF-8")
      );
      print(response.body);
      Data contract = new Data();
      var p = response.body.indexOf(">");
      var e = response.body.lastIndexOf("<");
      var result = response.body.substring(p + 1, e);
      var jsonData = json.decode(result);
      contract = Data.fromJson(jsonData[0]);
      return contract;
    });
  }
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = buildPrimaryThemeData(context);
    data = InheritedProvider.of<Data>(context);
    idUser = data.att10.toString();
    int typeLogin = int.parse(data.att2.toString());
    if(typeLogin == 4){
      querySQL = NguoiLaoDong.queryGetThongTinCaNhanNguoiLaoDong(idUser);
    }
    // TODO: implement build
    return SingleChildScrollView(
        child: FutureBuilder(
            future: _getInfoStaff(querySQL),
            builder: (BuildContext context, AsyncSnapshot snapshot){
              if(snapshot.hasError){
                return ViewsWidget.buildNoInternet(context,(){
                  setState(() {
                    memCache = AsyncMemoizer();
                  });
                });
              }else if(snapshot.hasData){
                Data user = snapshot.data;
                return new Column(
                  children: <Widget>[
                    Card(
                      elevation: 5.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      margin: new EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: <Widget>[
                                GestureDetector(
                                    child: new Container(
                                        padding: EdgeInsets.all(10.0),
                                        width: 80.0,
                                        height: 80.0,
                                        decoration: new BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: new DecorationImage(
                                                fit: BoxFit.fill,
                                                image: new CachedNetworkImageProvider(
                                                    "${Api.urlImageHatcheryStaff}${user.att1}",
                                                    errorListener: () => new Image.network("http://27.71.233.181:99/Images/icon_avatar.png") )
                                            )
                                        )
                                    ),
                                    onTap: () {
                                      Navigator.of(context).push(new MaterialPageRoute<Null>(
                                          builder: (_) =>
                                              InheritedProvider<String>(
                                                child: new ViewImage() ,
                                                inheritedData: "${Api.urlImageHatcheryStaff}${user.att1}",
                                              ))).then((onValue) {
                                        setState(() {
                                          memCache = AsyncMemoizer();
                                        });
                                      });
                                    }
                                ),

                                Visibility(
                                  child: new StarRating(rating: 5.0,size: 15),
                                  visible: typeLogin > 3,
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 7,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Text('${user.att3}',style: themeData.primaryTextTheme.display3,),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Text('${Translations.of(context).text('address')}: ${user.att7}',style: themeData.primaryTextTheme.display3,),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Text('${Translations.of(context).text('phone')}: ${user.att5}',style: themeData.primaryTextTheme.display3,),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Text('Email: ${user.att6.toString() != "null" ? user.att6.toString() : ''}',style: themeData.primaryTextTheme.display3,),
                                )
                              ],
                            ),
                          ),

                        ],
                      )
                    ),
                    ViewsWidget.buildRowAction(context,'change_password', _onTapChangePassword,
                        Image.asset("assets/images/icon_change_password.png", width: 30,height: 30,color: Colors.blue)),
                    /*Visibility(
                      child: Card(
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        margin: new EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(new MaterialPageRoute<Null>(
                                builder: (_) =>
                                    InheritedProvider<String>(
                                      child: new HatcheryDetails(),
                                      inheritedData: user.att7,
                                    ))).then((onValue) {
                              setState(() {
                                memCache = AsyncMemoizer();
                              });
                            });
                          },
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: Image.asset("assets/images/icon_location.png", width: 20,height: 20,color: Colors.red),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Text('${user.att7.toString() != "null" ? user.att7.toString() : ''}'
                                          ,style: themeData.primaryTextTheme.display3),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: Icon(Icons.access_time,size: 20,),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Text('${user.att9.toString() != "null" ?
                                      '${Translations.of(context).text('since')} ${function.convertDateCSDLToDateDefault(user.att9.toString())}' :
                                      ''}',style: themeData.primaryTextTheme.display3),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      visible: true,
                    ),*/
                    /*Visibility(
                      child:ViewsWidget.buildRowAction(context,'working_history',_onTapHistory, Image.asset("assets/images/icon_history.png", width: 30,height: 30,color: Colors.blue)),
                      visible: user.att1.contains('HATST'),
                    )*/

                  ],
                );
              }
              return new Center(
                  child: CircularProgressIndicator());
            }
        )
    );
  }
  _onTapChangePassword(BuildContext context){
    Navigator.of(context).push(new MaterialPageRoute<Null>(
        builder: (_) => InheritedProvider<Data>(
          child: new DialogChangePassword(ctx: context, checkAdmin: 0) ,
          inheritedData: data,
        )
    )).then((onValue){
      setState(() {
        memCache = AsyncMemoizer();
        //_getTankBroodstock(idSub);
      });
    });
  }
  /*
  _onTapHistory(){
    showDialog(
        context: context,
        builder: (_) => InheritedProvider<String>(
          child: new HistoryWorkingStaff() ,
          inheritedData: idUser,
        )
    ).then((onValue){
      setState(() {
        memCache = AsyncMemoizer();
        //_getTankBroodstock(idSub);
      });

    });
  }

   */
}
