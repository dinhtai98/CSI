import 'package:flutter_helloworld/queries/hatchery.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/utils/function.dart';

import 'package:flutter_helloworld/translations.dart';

class HistoryWorkingStaff extends StatefulWidget {
  //final data = InheritedProvider.of<Data>(context);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new HistoryWorkingStaffState();
  }
}
class HistoryWorkingStaffState extends State<HistoryWorkingStaff> {
  AsyncMemoizer<List<dynamic>> memCache = AsyncMemoizer();
  Future<List<dynamic>> _getHistoryWorking(String idStaff) async{
    List<dynamic> list = List();
    return memCache.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: Hatchery.queryWorkingHistory(idStaff),
          encoding: Encoding.getByName("UTF-8")
      );
      var p = response.body.indexOf("[");
      var e = response.body.lastIndexOf("]");
      var result = response.body.substring(p, e + 1);
      var jsonData = json.decode(result);
      for (var json in jsonData) {
        list.add(json);
      }
      return list;
    });
  }

  @override
  void initState() {
    super.initState();

  }



  @override
  Widget build(BuildContext context) {
    ThemeData themeData = buildPrimaryThemeData(context);
    String idStaff = InheritedProvider.of<String>(context);
    return Scaffold(
        appBar:new AppBar(
          title: Text(Translations.of(context).text('history_working'),
            style: themeData.primaryTextTheme.caption,),
        ),
        body: FutureBuilder(
            future: _getHistoryWorking(idStaff),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if(snapshot.hasError){
                return ViewsWidget.buildNoInternet(context,(){
                  setState(() {
                    memCache = AsyncMemoizer();
                  });
                });
              }else if(snapshot.hasData){
                return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(5.0),
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) => buildItemHistory(context,snapshot.data, index, )
                );
              }
              return new Center(
                  child: CircularProgressIndicator());
            }
        )
    );
  }
  Widget buildItemHistory(BuildContext ctxt, List<dynamic> list ,int index) {
    ThemeData themeData = buildPrimaryThemeData(ctxt);
    Data history = Data.fromJson(list[index]);
    return new Card(
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        margin: new EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.0),
        child: Column(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.all(10.0),
                child: Text('${history.att1}',
                  style: themeData.primaryTextTheme.display1,
                  textAlign: TextAlign.center,)
            ),
            //ViewsWidget.buildRowDetails(context, 'hatchery', '${hatchery.att2}'),
            ViewsWidget.buildRowDetails(context,  'since', '${function.convertDateCSDLToDateDefault(history.att2)} '
                '${Translations.of(context).text('to')} ${function.convertDateCSDLToDateDefault(history.att3)}'),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Text(Translations.of(context).text('comment'),
                      style: themeData.primaryTextTheme.display4,),
                  ),
                  Flexible(
                    flex: 4,
                    child: Text(
                      "${history.att4.toString() != "null" ? history.att4.toString() : ''}",
                      textAlign: TextAlign.justify,
                      overflow: TextOverflow.ellipsis,
                      style: themeData.primaryTextTheme.display3,
                      maxLines: 10,),
                  ),
                ],
              ),
            ),
            ViewsWidget.buildRowDetailsWithWidget(context, 'ranking', new StarRating(rating: double.parse(history.att5.toString()),size: 20,color: Colors.amber)),
          ],
        ),
    );
  }
}

