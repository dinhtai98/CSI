import 'dart:async';
import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/Data/DataUser.dart';
import 'package:flutter_helloworld/dialog/dialog_change_password.dart';
import 'package:flutter_helloworld/dialog/dialog_input_rating.dart';
import 'package:flutter_helloworld/dialog/dialog_view_rating.dart';
import 'package:flutter_helloworld/queries/contract.dart';
import 'package:flutter_helloworld/queries/hatchery.dart';
import 'package:flutter_helloworld/queries/producer.dart';
import 'package:flutter_helloworld/queries/timviec.dart';
import 'package:flutter_helloworld/queries/trader.dart';
import 'package:flutter_helloworld/screens/photo/view_image.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'dart:convert';
import 'package:flutter_helloworld/utils/function.dart';

import '../translations.dart';

class CompanyDetails extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new CompanyDetailsState();
  }
}
class CompanyDetailsState extends State<CompanyDetails> {
  Data data;
  String idHatchery;

  AsyncMemoizer<Data> memCache = AsyncMemoizer();
  Future<Data> _getCompany(String idWorkplace) async{
    return memCache.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Hatchery.queryGetHatchery(idWorkplace)),
          encoding: Encoding.getByName("UTF-8")
      );
      if (response.statusCode == 200) {
        Data data = new Data();
        var p = response.body.indexOf(">");
        var e = response.body.lastIndexOf("<");
        var result = response.body.substring(p + 1, e);
        var jsonData = json.decode(result);
        data = Data.fromJson(jsonData[0]);
        return data;
      }else {
        throw("");
      }
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imageCache.clear();
  }
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = buildPrimaryThemeData(context);
    data = InheritedProvider.of<Data>(context);
    idHatchery = data.att1.toString();
    return FutureBuilder(
        future: _getCompany(idHatchery),
        builder: (BuildContext context, AsyncSnapshot snapshot){
          if(snapshot.hasError){
            return ViewsWidget.buildNoInternet(context,(){
              setState(() {
                memCache = AsyncMemoizer();
              });
            });
          }else if(snapshot.hasData){
            Data hatchery = snapshot.data;
            return SingleChildScrollView(
              child: new Column(
                children: <Widget>[
                  GestureDetector(
                      child: new ClipRRect(
                          borderRadius: new BorderRadius.only(
                              bottomLeft : const Radius.circular(15.0),
                              bottomRight: const Radius.circular(15.0)
                          ),
                          child: Image.network("${Api.urlImageHatchery}${hatchery.att6}",
                            height: 180,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.fill,
                            //imageUrl: "",
                            //placeholder: (context, url) => new CircularProgressIndicator(),
                            //errorWidget: (context, url, error) => new Icon(Icons.error)
                          )
                      ),
                      onTap: () {
                        Navigator.of(context).push(new MaterialPageRoute<Null>(
                            builder: (_) =>
                                InheritedProvider<String>(
                                  child: new ViewImage() ,
                                  inheritedData: "${Api.urlImageHatchery}${hatchery.att6}",
                                ))).then((onValue) {
                          setState(() {
                            memCache = AsyncMemoizer();
                          });
                        });
                      }
                  ),
                  Card(
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    margin: new EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.0),
                    child: Column(
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text('${hatchery.att2}',
                              style: themeData.primaryTextTheme.display1,
                              textAlign: TextAlign.center,)
                        ),
                        ViewsWidget.buildRowDetails(context,  'owner', '${hatchery.att3}'),
                        ViewsWidget.buildRowDetails(context,  'username', '${hatchery.att7}'),
                        ViewsWidget.buildRowDetails(context, 'phone', '${hatchery.att5}'),
                        ViewsWidget.buildRowDetails(context, 'address', '${hatchery.att4}'),
                        ViewsWidget.buildRowDetails(context, 'province', '${hatchery.att10}'),
                      ],
                    ),
                  ),
                  Card(
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    margin: new EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.0),
                    child: Column(
                      children: <Widget>[
                        ViewsWidget.buildRowDetails(context, 'type_of_business', '${function.getTypeOfBusinessCSSX(hatchery.att13)}'),
                        ViewsWidget.buildRowDetails(context, 'species_producted_or_marketed', '${function.getListSpeciesProducing(context, hatchery.att12)}'),
                        ViewsWidget.buildRowDetails(context, 'n_of_production_cluster', '${hatchery.att11}'),
                      ],
                    ),
                  ),
                  Card(
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    margin: new EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.0),
                    child: Column(
                      children: <Widget>[
                        ViewsWidget.buildRowDetails(context, 'business_number', '${hatchery.att9}'),
                        ViewsWidget.buildRowDetails(context, 'establish_year', '${function.convertDateCSDLToYear(hatchery.att8)}'),
                      ],
                    ),
                  ),
                  ViewsWidget.buildRowAction(context,'change_password', _onTapChangePassword,
                      Image.asset("assets/images/icon_change_password.png", width: 30,height: 30,color: Colors.blue)),
                ],
              ),
            );
          }
          return ViewsWidget.buildPleaseWait();
        }
    );
  }
  _onTapChangePassword(BuildContext context){
    Navigator.of(context).push(new MaterialPageRoute<Null>(
        builder: (_) =>
            InheritedProvider<Data>(
              child: new DialogChangePassword(ctx: context, checkAdmin: 0),
              inheritedData: data,
            ))).then((onValue) {
      setState(() {
        memCache = AsyncMemoizer();
      });
    });
  }
}
