import 'dart:convert';
import 'package:async/async.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/queries/trader.dart';
import 'package:flutter_helloworld/screens/trader/detail_trader.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_helloworld/utils/function.dart';

class Home_Trader extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new Home_Trader_State();
  }
}
class Home_Trader_State extends State<Home_Trader> {
  AsyncMemoizer<List<dynamic>> memCache = AsyncMemoizer();
  _getAllTrader() async{
    List<dynamic> list = List();
    return memCache.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Trader.query_getAllTrader),
          encoding: Encoding.getByName("UTF-8")
      );
      print("Home_Trader run");
      var p = response.body.indexOf("[");
      var e = response.body.lastIndexOf("]");
      var result = response.body.substring(p,e + 1);
      list = json.decode(result);
      return list;
    });
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  FutureBuilder(
        future: _getAllTrader(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if(snapshot.hasError){
            return ViewsWidget.buildNoInternet(context,(){
              setState(() {
                memCache = AsyncMemoizer();
              });
            });
          }else if(snapshot.hasData){
            return snapshot.data.length > 0 ? ListView.builder(
                padding: EdgeInsets.all(5.0),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) => buildItemTrader(context,snapshot.data, index)
            ):
            ViewsWidget.buildNoResultSearch(context);
          }
          return new Center(
              child: CircularProgressIndicator());
        }
    );
  }
  Widget buildItemTrader(BuildContext ctxt, List<dynamic> list ,int index) {
    ThemeData themeData = buildPrimaryThemeData(ctxt);
    Data trader = Data.fromJson(list[index]);

    return new Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      margin: new EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.0),
      child: Container(
        //decoration: BoxDecoration(color: Color(0xff000000),
        //borderRadius: BorderRadius.circular(25.0)),
          child: ListTile(
            onTap: () {
              Navigator.of(context).push(new MaterialPageRoute<Null>(
                  builder: (_) =>
                      InheritedProvider<String>(
                        child: new TraderDetails(),
                        inheritedData: trader.att1,
                      ))).then((onValue) {
                setState(() {
                  memCache = AsyncMemoizer();
                });
              });
            },
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            title: Text(
              '${trader.att2}', style: themeData.primaryTextTheme.display1,textAlign: TextAlign.center,
            ),
            subtitle: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text('${function.getSpecies(ctxt, trader.att5)}'),
                Text('${function.getType(ctxt, trader.att6)}'),
              ],
            ),
          )
      ),
    );
  }
}