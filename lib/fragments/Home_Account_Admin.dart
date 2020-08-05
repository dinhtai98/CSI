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
import 'package:postgres/postgres.dart';

class HomeAccountAdmin extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new HomeAccountAdminState();
  }
}
class HomeAccountAdminState extends State<HomeAccountAdmin> {
  Data data;
  String idUser;

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

    // TODO: implement build
    return SingleChildScrollView(
        child: Column(
          children: <Widget>[
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
        )
    );
  }
  _onTapChangePassword(BuildContext context){
    Navigator.of(context).push(new MaterialPageRoute<Null>(
        builder: (_) =>
            InheritedProvider<Data>(
              child: new DialogChangePassword(ctx: context, checkAdmin: 1,),
              inheritedData: data,
            ))).then((onValue) {
      setState(() {
        memCache = AsyncMemoizer();
      });
    });
    /*showDialog(
        context: context,
        builder: (_) => InheritedProvider<Data>(
          child: new DialogChangePassword(ctx: context, checkAdmin: 1,) ,
          inheritedData: data,
        )
    ).then((onValue){
      setState(() {
        memCache = AsyncMemoizer();
        //_getTankBroodstock(idSub);
      });
    });*/
  }
}
