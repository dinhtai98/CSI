import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/queries/request.dart';
import '../../translations.dart';
import 'package:flutter_helloworld/utils/function.dart';
import '../../Data/ConvertQueryResult.dart';
import 'package:postgres/postgres.dart';

class HatcheryRequestDetails extends StatefulWidget {
  String idRequest;

  HatcheryRequestDetails(this.idRequest);

  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new HatcheryRequestDetailsState();
  }
}
class HatcheryRequestDetailsState extends State<HatcheryRequestDetails> {
  Future<Data> _getRequest() async{
    Data requestData = new Data();
    http.Response response = await http.post(
        Api.urlGetDataByPost,
        headers: {
          "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
          "Content-Type": "application/x-www-form-urlencoded",
          "cache-control": "no-cache"
        },
        body: utf8.encode(Request.query_findRequest(widget.idRequest)),
        encoding: Encoding.getByName("UTF-8")
    );
    print('request ${response.statusCode}');
    var p = response.body.indexOf("[");
    var e = response.body.lastIndexOf("]");
    var result = response.body.substring(p, e + 1);
    var jsonData = json.decode(result);
    requestData = Data.fromJson(jsonData[0]);
    return requestData;
  }

  Future<Data> _getResponseFromRequest() async{
    http.Response response = await http.post(
        Api.urlGetDataByPost,
        headers: {
          "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
          "Content-Type": "applfication/x-www-form-urlencoded",
          "cache-control": "no-cache"
        },
        body: utf8.encode(Request.query_CheckRequest_Responsed(widget.idRequest)),
        encoding: Encoding.getByName("UTF-8")
    );
    print('response ${response.statusCode}');
    Data responseData = new Data();
    var p = response.body.indexOf("[");
    var e = response.body.lastIndexOf("]");
    var result = response.body.substring(p, e + 1);
    List jsonData = json.decode(result);
    if (jsonData.length > 0) {
      responseData = Data.fromJson(jsonData[0]);
    }

    return responseData;
  }

  @override
  void initState() {
    //responseList = Future.wait([_getRequest(widget.idRequest), _getResponseFromRequest(widget.idRequest)]);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = buildPrimaryThemeData(context);
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: Text(Translations.of(context).text('request_details'),
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
            future: _getRequest(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if(snapshot.hasError){
                return ViewsWidget.buildNoInternet(context,(){
                  setState(() {

                  });
                });
              }else if(snapshot.hasData){
                Data requestData = snapshot.data;
                return Column(
                  children: <Widget>[
                    Card(
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        margin: new EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(Translations.of(context).text('request'), style: themeData.primaryTextTheme.display1,)
                                ],
                              ),
                            ),
                            Column(
                              children: <Widget>[
                                buildRowDetails(context,Translations.of(context).text('request_date'), '${requestData.att7}'),
                                buildRowDetails(context,Translations.of(context).text('trader'), '${requestData.att2}'),
                                buildRowDetails(context,Translations.of(context).text('producer'), '${requestData.att1}'),
                                buildRowDetails(context,Translations.of(context).text('species'), '${function.getSpecies(context,requestData.att3)}'),
                                buildRowDetails(context,Translations.of(context).text('type'), '${function.getType(context,requestData.att4)}'),
                                buildRowDetails(context,Translations.of(context).text('number_of_pair'), '${function.formatNumber(requestData.att5)}'),
                                buildRowDetails(context,Translations.of(context).text('expected_deli_date'), '${requestData.att6}')
                              ],
                            )
                          ],
                        )
                    ),
                    Card(
                      elevation: 5.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      margin: new EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(Translations.of(context).text('response'), style: themeData.primaryTextTheme.display1,)
                              ],
                            ),
                          ),
                          FutureBuilder(
                            future:_getResponseFromRequest(),
                            builder: (BuildContext context, AsyncSnapshot snapshot) {
                              if(snapshot.hasError){
                                return ViewsWidget.buildNoInternet(context,(){
                                  setState(() {

                                  });
                                });
                              }else if(snapshot.hasData){
                                Data requestData = snapshot.data;
                                print(requestData.att5);
                                if(requestData.att1.toString() == "null"){
                                  return Center(
                                    child: new Text(Translations.of(context).text('not_yet_responded'),
                                      style: themeData.primaryTextTheme.display3 ,),
                                  );
                                }
                                return new Column(
                                  children: <Widget>[
                                    buildRowDetails(context,Translations.of(context).text('response_date'), '${requestData.att11}'),
                                    buildRowDetails(context,Translations.of(context).text('producer'), '${requestData.att1}'),
                                    buildRowDetails(context,Translations.of(context).text('species'), '${function.getSpecies(context,requestData.att2)}'),
                                    buildRowDetails(context,Translations.of(context).text('type'), '${function.getType(context,requestData.att3)}'),
                                    buildRowDetails(context,Translations.of(context).text('number_of_pair'), '${function.formatNumber(requestData.att5)}'),
                                    buildRowDetails(context,Translations.of(context).text('unit_price'), '${function.formatNumber(requestData.att4)}'),
                                    buildRowDetails(context,Translations.of(context).text('arrival_port'), '${requestData.att7}'),
                                    buildRowDetails(context,Translations.of(context).text('arrival_port_date'), '${requestData.att8}'),
                                    buildRowDetails(context,Translations.of(context).text('expected_deli_date'), '${requestData.att6}'),
                                    buildRowDetails(context,Translations.of(context).text('bonus'), '${requestData.att9}'),
                                    buildRowDetails(context,Translations.of(context).text('note'), '${requestData.att10}'),
                                  ],
                                );
                              }
                              return new Center(
                                  child: CircularProgressIndicator());
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                );
              }
              return new Center(
                  child: CircularProgressIndicator());
            }),
      )

    );
  }
  Widget buildRowDetails(BuildContext context, String label, String result){
    ThemeData themeData = buildPrimaryThemeData(context);
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Text(label,style: themeData.primaryTextTheme.display4,),
          ),
          Expanded(
            flex: 4,
            child: Text(result,style: themeData.primaryTextTheme.display3,),
          ),
        ],
      ),
    );
  }
}