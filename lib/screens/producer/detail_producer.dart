import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/Data/DataUser.dart';
import 'package:flutter_helloworld/dialog/dialog_input_rating.dart';
import 'package:flutter_helloworld/dialog/dialog_view_rating.dart';
import 'package:flutter_helloworld/queries/contract.dart';
import 'package:flutter_helloworld/queries/producer.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../translations.dart';
import 'package:flutter_helloworld/utils/function.dart';
import 'package:flutter_helloworld/utils/function.dart';
import '../../Data/ConvertQueryResult.dart';
import 'package:postgres/postgres.dart';

class ProducerDetails extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new ProducerDetailsState();
  }
}
class ProducerDetailsState extends State<ProducerDetails> {

  AsyncMemoizer<Data> memCache = AsyncMemoizer();
  Future<Data> _getProducer(String idPro) async{
    return memCache.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Producer.queryGetProducer(idPro)),
          encoding: Encoding.getByName("UTF-8")
      );
      if (response.statusCode == 200) {
        Data contract = new Data();
        var p = response.body.indexOf(">");
        var e = response.body.lastIndexOf("<");
        var result = response.body.substring(p + 1, e);
        var jsonData = json.decode(result);
        contract = Data.fromJson(jsonData[0]);
        return contract;
      }else {
        throw("");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = buildPrimaryThemeData(context);
    String idPro = InheritedProvider.of<String>(context);
    return new Scaffold(
      appBar: new AppBar(
        title: Text(Translations.of(context).text('producer_details'),
          style: themeData.primaryTextTheme.caption,
        ),
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
              future: _getProducer(idPro),
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
                            ViewsWidget.buildRowDetails(context, 'producer', '${contract.att2}'),
                            ViewsWidget.buildRowDetails(context,  'contact_name', '${contract.att4} ${contract.att3}'),
                            ViewsWidget.buildRowDetails(context, 'phone', '${contract.att5}'),
                            ViewsWidget.buildRowDetails(context, 'email', '${contract.att17}'),
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
                            ViewsWidget.buildRowDetails(context, 'address', '${contract.att11}'),
                            ViewsWidget.buildRowDetails(context,  'city', '${contract.att12}'),
                            ViewsWidget.buildRowDetails(context, 'state', '${contract.att13}'),
                            ViewsWidget.buildRowDetails(context,  'country', '${contract.att10}'),
                            ViewsWidget.buildRowDetails(context, 'postal_code', '${contract.att14}'),
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
                            ViewsWidget.buildRowDetails(context, 'company_code', '${contract.att18}'),
                            ViewsWidget.buildRowDetails(context, 'establish_year', '${function.convertDateCSDLToDateDefault(contract.att8)}'),
                            ViewsWidget.buildRowDetails(context, 'first_year_vn', '${function.convertDateCSDLToDateDefault(contract.att19)}'),
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
                            ViewsWidget.buildRowDetails(context, 'market_share_cur_year', '${contract.att15}'),
                            ViewsWidget.buildRowDetails(context, 'market_share_three_year', '${contract.att16}'),
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
                            ViewsWidget.buildRowDetailsWithWidget(context, 'hatchery_ranking',
                              new StarRating(rating: double.parse(contract.att20.toString()),size: 20,color: Colors.green,)),
                            ViewsWidget.buildRowDetailsWithWidget(context, 'dfish_ranking',
                                new StarRating(rating: double.parse(contract.att21.toString()),size: 20,color: Colors.red,)),
                          ],
                        ),
                      )
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
