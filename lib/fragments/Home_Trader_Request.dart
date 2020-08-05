import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/scoped_model/home_selected_menu.dart';
import 'package:flutter_helloworld/screens/trader/request_detail.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_helloworld/utils/function.dart';
import 'package:flutter_helloworld/queries/request.dart';
import 'package:scoped_model/scoped_model.dart';


class Home_Trader_Request extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new Home_Trader_RequestState();
  }
}
class Home_Trader_RequestState extends State<Home_Trader_Request> {

  AsyncMemoizer<List<dynamic>> memCache = AsyncMemoizer();
  _getAllRequestOfTrader(String idTra, int check, String date) async{
    List<dynamic> listReq = List();
    return memCache.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(check == 3 ?
          Request.queryGetAllRequestsOfTraderFilterDate(idTra,date) :
          Request.queryGetAllRequestsOfTrader(idTra,check)),
          encoding: Encoding.getByName("UTF-8")
      );
      print("Home_Trader_Request run");
      var p = response.body.indexOf("[");
      var e = response.body.lastIndexOf("]");
      var result = response.body.substring(p, e + 1);
      setState(() {
        var jsonData = json.decode(result);
        for (var json in jsonData) {
          listReq.add(json);
        }
      });
      return listReq;
    });
  }

  int check = -1;
  String date = '';

  @override
  Widget build(BuildContext context) {
    Data data = InheritedProvider.of<Data>(context);
    // TODO: implement build
    return Scaffold(
      body: ScopedModelDescendant<PopupMenu>(
        builder: (context, child, model) {
          if(check != model.name || date != model.selectedDate){
            memCache = AsyncMemoizer();
            check = model.name;
            date = model.selectedDate;
          }
          return FutureBuilder(
              future: _getAllRequestOfTrader(data.att7,model.name,model.selectedDate),
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
                      itemBuilder: (BuildContext context, int index) => buildItemRequest(context,snapshot.data, index)
                  ) :
                  ViewsWidget.buildNoResultSearch(context);
                }
                return new Center(
                    child: CircularProgressIndicator());
              }
          );
        },
      )
    );
  }
  Widget buildItemRequest(BuildContext ctxt, List<dynamic> list, int index) {
    ThemeData themeData = buildPrimaryThemeData(ctxt);
    Data request = Data.fromJson(list[index]);

    String reqDate = function.convertDateCSDLToDateDefault('${request.att4}');
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TraderRequestDetails(request.att1)),
              ).then((onValue){
                setState(() {

                });
              });
            },
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            leading: Container(
              padding: EdgeInsets.only(right: 12.0),
              decoration: new BoxDecoration(
                  border: new Border(
                      right: new BorderSide(width: 1.0, color: Color(0xff007B97)))),
              child: request.att2.toString() != "null"  ? Image.asset("assets/images/icontick.png",width: 30,height: 30,color: Colors.green,) :
              Image.asset("assets/images/icon_request.png",width: 30,height: 30,color: Colors.grey,),
            ),
            title: Text(
                '${request.att1}', style: themeData.primaryTextTheme.display1
            ),
            // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

            subtitle: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                //Icon(Icons.linear_scale, color: Colors.yellowAccent),
                Expanded(
                  flex: 2,
                  child: Text('${request.att3}', style: themeData.primaryTextTheme.display2),
                ),
                Expanded(
                  child: Text('$reqDate', style: themeData.primaryTextTheme.display2),
                ),

              ],
            ),
            //trailing:
            //Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0)
          ),
        ));
  }
}