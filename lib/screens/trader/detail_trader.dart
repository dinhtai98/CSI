import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/Data/DataUser.dart';
import 'package:flutter_helloworld/dialog/dialog_input_rating.dart';
import 'package:flutter_helloworld/dialog/dialog_view_rating.dart';
import 'package:flutter_helloworld/queries/contract.dart';
import 'package:flutter_helloworld/queries/producer.dart';
import 'package:flutter_helloworld/queries/trader.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../translations.dart';
import 'package:flutter_helloworld/utils/function.dart';

class TraderDetails extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new TraderDetailsState();
  }
}
class TraderDetailsState extends State<TraderDetails> {

  AsyncMemoizer<Data> memCache = AsyncMemoizer();
  Future<Data> _getTrader(String idTra) async{
    return memCache.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Trader.queryGetTrader(idTra)),
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
  Widget build(BuildContext context) {
    ThemeData themeData = buildPrimaryThemeData(context);
    String idTrader = InheritedProvider.of<String>(context);
    return new Scaffold(
      appBar: new AppBar(
        title: Text(Translations.of(context).text('trader_details'),
          style: themeData.primaryTextTheme.caption,),
        centerTitle: true,
        flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2db7d1), Color(0xff55ceb1)],
              ),
            )
        ),
      ),
      body: SingleChildScrollView(
          child: FutureBuilder(
              future: _getTrader(idTrader),
              builder: (BuildContext context, AsyncSnapshot snapshot){
                if(snapshot.hasError){
                  return ViewsWidget.buildNoInternet(context,(){
                    setState(() {
                      memCache = AsyncMemoizer();
                    });
                  });
                }else if(snapshot.hasData){
                  Data contract = snapshot.data;
                  return new Column(
                    children: <Widget>[
                      Card(
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        margin: new EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.0),
                        child: Column(
                          children: <Widget>[
                            ViewsWidget.buildRowDetails(context, 'trader', '${contract.att2}'),
                            ViewsWidget.buildRowDetails(context,  'contact_name', '${contract.att4} ${contract.att3}'),
                            ViewsWidget.buildRowDetails(context, 'phone', '${contract.att5}'),
                            ViewsWidget.buildRowDetails(context, 'email', '${contract.att13}'),
                            ViewsWidget.buildRowDetails(context, 'address', '${contract.att10}'),
                            ViewsWidget.buildRowDetails(context, 'province', '${contract.att15}'),
                            ViewsWidget.buildRowDetails(context,  'city', '${contract.att11}'),
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
                            ViewsWidget.buildRowDetails(context, 'species', '${function.getSpecies(context,contract.att6)}'),
                            ViewsWidget.buildRowDetails(context, 'type', '${function.getType(context,contract.att7)}'),
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
                            ViewsWidget.buildRowDetails(context, 'business_number', '${contract.att9}'),
                            ViewsWidget.buildRowDetails(context, 'company_code', '${contract.att14}'),
                            ViewsWidget.buildRowDetails(context, 'establish_year', '${function.convertDateCSDLToDateDefault(contract.att8)}'),
                            ViewsWidget.buildRowDetails(context, 'operated_year', '${function.convertDateCSDLToDateDefault(contract.att12)}'),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return new Center(
                    child: CircularProgressIndicator());
              }
          )
      ),
    );
  }

}
