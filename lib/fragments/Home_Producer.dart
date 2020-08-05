import 'dart:convert';
import 'package:async/async.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/queries/producer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/screens/producer/detail_producer.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_helloworld/utils/function.dart';
import '../Data/ConvertDataList.dart';
import 'package:postgres/postgres.dart';
import '../Data/ConvertQueryResult.dart';

class Home_Producer extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new Home_Producer_State();
  }
}
class Home_Producer_State extends State<Home_Producer> {


  AsyncMemoizer<List<dynamic>> memCache = AsyncMemoizer();
  _getAllProducer() async{
    List<dynamic> listProducer = List();
    return memCache.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Producer.query_GetAllProducers),
          encoding: Encoding.getByName("UTF-8")
      );
      var p = response.body.indexOf("[");
      var e = response.body.lastIndexOf("]");
      var result = response.body.substring(p,e + 1);
      listProducer = json.decode(result);
      return listProducer;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  FutureBuilder(
        future: _getAllProducer(),
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
                itemBuilder: (BuildContext context, int index) => buildItemProducer(context,snapshot.data, index)
            ):
            ViewsWidget.buildNoResultSearch(context);
          }
          return new Center(
              child: CircularProgressIndicator());
        }
    );

  }
  Widget buildItemProducer(BuildContext ctxt, List<dynamic> list ,int index) {
    ThemeData themeData = buildPrimaryThemeData(ctxt);
    Data producer = Data.fromJson(list[index]);
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
                        child: new ProducerDetails(),
                        inheritedData: producer.att1,
                      ))).then((onValue) {
                setState(() {
                  memCache = AsyncMemoizer();
                });
              });
            },
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            title: Text(
                '${producer.att2}', style: themeData.primaryTextTheme.display1,textAlign: TextAlign.center,
              ),
            subtitle: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('${function.getSpecies(ctxt, producer.att4)}'),
                  Text('${function.getType(ctxt, producer.att3)}'),
                  new StarRating(rating: double.parse('${producer.att5}'),size: 20,color: Colors.green,),
                  new StarRating(rating: double.parse('${producer.att6}'),size: 20,color: Colors.red),
                ],
              ),
            )
          ),
        );
  }
}