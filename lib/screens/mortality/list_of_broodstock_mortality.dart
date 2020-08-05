import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/Data/DataUser.dart';
import 'package:flutter_helloworld/dialog/dialog_create_spawning.dart';
import 'package:flutter_helloworld/dialog/dialog_hatchery_broodstock_assign_to_tank.dart';
import 'package:flutter_helloworld/queries/broodstock.dart';
import 'package:flutter_helloworld/queries/contract.dart';
import 'package:flutter_helloworld/queries/mortality.dart';
import 'package:flutter_helloworld/screens/spawning/spawning_assign_to_tank.dart';
import 'package:flutter_helloworld/screens/spawning/spawning_sell.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_helloworld/utils/function.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../translations.dart';
import '../home_screen.dart';
import 'dialog_record_mortality.dart';
import 'mortality_detail.dart';

class ListOfBroodStockMortality extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new ListOfBroodStockMortalityState();
  }
}
class ListOfBroodStockMortalityState extends State<ListOfBroodStockMortality> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  ScrollController _hideButtonController;
  var _isVisible;

  String idSub;

  AsyncMemoizer<List<dynamic>> memCache = AsyncMemoizer();

  Future<List<dynamic>> _getListBroodstockMortality(String idSub) async{
    List<dynamic> list = List();
    return memCache.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(
              Mortality.queryGetALlMortalityOfBroodstockSub(idSub)),
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
  _scrollListener() {
    if (_hideButtonController.offset >= _hideButtonController.position.maxScrollExtent) {
      if(_isVisible == true) {
        setState((){
          _isVisible = false;
        });
      }
    }
    if (_hideButtonController.offset <= _hideButtonController.position.minScrollExtent ||
        _hideButtonController.position.userScrollDirection == ScrollDirection.forward) {
      if(_isVisible == false) {
        setState((){
          _isVisible = true;
        });
      }
    }
  }
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 200)).then((_) {
      _refreshIndicatorKey.currentState?.show();
    });

    _isVisible = true;
    _hideButtonController = new ScrollController();
    _hideButtonController.addListener(_scrollListener);
  }

  Future<Null> _handleRefresh() async {
    await new Future.delayed(new Duration(milliseconds: 200));
    setState(() {
      memCache = AsyncMemoizer();
    });
    return null;
  }
  @override
  Widget build(BuildContext context) {

    ThemeData themeData = buildPrimaryThemeData(context);
    idSub = InheritedProvider.of<String>(context);
    return Scaffold(
      appBar: new AppBar(
        title: Text(Translations.of(context).text('record_mortality'),
          style: themeData.primaryTextTheme.caption,),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _handleRefresh,
        child:  FutureBuilder(
            future: _getListBroodstockMortality(idSub),
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
                    controller: _hideButtonController,
                    scrollDirection: Axis.vertical,
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) => buildMortality(context,snapshot.data, index, )
                );
              }
              return new Center(
                  child: CircularProgressIndicator());
            }),
      ),
      floatingActionButton: new Visibility(
        visible: _isVisible,
        child: new FloatingActionButton(
          onPressed: () {
            openDialog();
          },
          child: new Icon(Icons.add),
        ),
      ),

    );
  }
  void openDialog() {
    showDialog(
        context: context,
        builder: (_) => InheritedProvider<String>(
          child: new DialogRecordMortality(),
          inheritedData: idSub,
        )
    ).then((onValue){
      setState(() {
        memCache = AsyncMemoizer();
      });

    });
  }
  Widget buildMortality(BuildContext ctxt, List<dynamic> list ,int index) {
    ThemeData themeData = buildPrimaryThemeData(ctxt);
    Data mortality = Data.fromJson(list[index]);

    String detectTime = function.convertDateCSDLToDateTimeDefault('${mortality.att3}');
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
              Navigator.of(ctxt).push(new MaterialPageRoute<Null>(
                  builder: (_) =>
                      InheritedProvider<String>(
                        child: new MortalityDetails(),
                        inheritedData: mortality.att1,
                      ))).then((onValue) {
                setState(() {
                  memCache = AsyncMemoizer();
                });
              });
            },
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            leading: Container(
                padding: EdgeInsets.only(right: 12.0),
                child: Image.asset("assets/images/icon_item_mortality.png", width: 30,height: 30)
            ),
            title: Text('${mortality.att2}',style: themeData.primaryTextTheme.display3,),
            // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

            subtitle: Text('$detectTime',style: themeData.primaryTextTheme.display3,),
          ),
        )
    );
  }
}