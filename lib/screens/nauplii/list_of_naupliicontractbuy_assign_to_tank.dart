import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/Data/DataUser.dart';
import 'package:flutter_helloworld/dialog/dialog_hatchery_broodstock_assign_to_tank.dart';
import 'package:flutter_helloworld/dialog/dialog_hatchery_broodstock_assign_to_tank_from_assign.dart';
import 'package:flutter_helloworld/dialog/dialog_hatchery_nauplii_assign_tank_from_assign.dart';
import 'package:flutter_helloworld/queries/broodstock.dart';
import 'package:flutter_helloworld/queries/contract.dart';
import 'package:flutter_helloworld/queries/nauplii.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_helloworld/utils/function.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Data/ConvertQueryResult.dart';
import 'package:postgres/postgres.dart';
import '../../translations.dart';
import '../home_screen.dart';

class ListOfNaupliiAssignTankFromContract extends StatefulWidget {


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new ListOfNaupliiAssignTankFromContractState();
  }
}

class ListOfNaupliiAssignTankFromContractState extends State<ListOfNaupliiAssignTankFromContract> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  ScrollController _hideButtonController;
  var _isVisible;
  List<String> dataGotten;
  String idStaff = "", idHatchery = "";
  List<String> dataContract;
  String idContract;

  AsyncMemoizer<List<dynamic>> memCache = AsyncMemoizer();
  Future<List<dynamic>> _getListAssignToTankFromNaupliiContract(String idContract, String idHatchery) async {
    List<dynamic> list = List();
    return memCache.runOnce(() async {
      http.Response response = await http.post(Api.urlGetDataByPost,
          headers: {
            "SOAPAction":
                "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Nauplii.queryGetListAssignTankFromNaupliiContract(idContract, idHatchery)),
          encoding: Encoding.getByName("UTF-8"));
      print("list of nauplii assgin to tank: ${response.body}");
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
    Future.delayed(Duration(milliseconds: 200)).then((_) {
      _refreshIndicatorKey.currentState?.show();
    });

    _isVisible = true;
    _hideButtonController = new ScrollController();
    _hideButtonController.addListener(_scrollListener);
  }

  _scrollListener() {
    if (_hideButtonController.offset >=
        _hideButtonController.position.maxScrollExtent) {
      if (_isVisible == true) {
        setState(() {
          _isVisible = false;
        });
      }
    }
    if (_hideButtonController.offset <=
            _hideButtonController.position.minScrollExtent ||
        _hideButtonController.position.userScrollDirection ==
            ScrollDirection.forward) {
      if (_isVisible == false) {
        setState(() {
          _isVisible = true;
        });
      }
    }
  }



  Future<Null> _handleRefresh() async {
    await new Future.delayed(new Duration(milliseconds: 200));
    setState(() {
      //_getListAssignToTankOfImportContract(data.att7);
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = buildPrimaryThemeData(context);
    dataGotten = InheritedProvider.of<List<String>>(context);
    idContract = dataGotten[0];
    idHatchery = dataGotten[1];
    idStaff = dataGotten[2];
    return Scaffold(
      appBar: new AppBar(
        title: Text(
          Translations.of(context).text('record_assign_to_tank'),
          style: themeData.primaryTextTheme.caption,
        ),
        centerTitle: true,
        flexibleSpace: Container(
            decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2db7d1), Color(0xff55ceb1)],
          ),
        )),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _handleRefresh,
        child: FutureBuilder(
            future:
                _getListAssignToTankFromNaupliiContract(idContract, idHatchery),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasError) {
                return ViewsWidget.buildNoInternet(context, () {
                  setState(() {
                    //memCache = AsyncMemoizer();
                    build(context);
                  });
                });
              } else if (snapshot.hasData) {
                return snapshot.data.length > 0
                    ? ListView.builder(
                        padding: EdgeInsets.all(5.0),
                        shrinkWrap: true,
                        controller: _hideButtonController,
                        scrollDirection: Axis.vertical,
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) =>
                            buildAssignToTank(
                              context,
                              snapshot.data,
                              index,
                            ))
                    : ViewsWidget.buildNoResultSearch(context);
              }
              return new Center(child: CircularProgressIndicator());
            }),
      ),
      floatingActionButton: new Visibility(
        visible: _isVisible,
        child: new FloatingActionButton(
          onPressed: () {
            openDialog();
          },
          tooltip: 'Increment',
          child: new Icon(Icons.add),
        ),
      ),
    );
  }

  void openDialog() {
    dataContract = new List();
    dataContract.addAll([idContract, idStaff, idHatchery]);
    Navigator.of(context)
        .push(new MaterialPageRoute<Null>(
            builder: (_) => InheritedProvider<List<String>>(
                  child: new NaupliiAssignTankFromContract(),
                  inheritedData: dataContract,
                ),
            fullscreenDialog: true))
        .then((onValue) {
      setState(() {});
    });
  }

  Widget buildAssignToTank(BuildContext ctxt, List<dynamic> list, int index) {
    ThemeData themeData = buildPrimaryThemeData(ctxt);
    Data subBatch = Data.fromJson(list[index]);

    String signDate =
        function.convertDateCSDLToDateTimeDefault('${subBatch.att3}');
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
              /*Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProcessImportContract(idContract : contract.att1 )),
              );*/
            },
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            leading: Container(
                padding: EdgeInsets.only(right: 12.0),
                decoration: new BoxDecoration(
                    border: new Border(
                        right: new BorderSide(
                            width: 1.0, color: Color(0xff007B97)))),
                child: Image.asset("assets/images/icon_tank.png",
                    width: 30, height: 30, color: Colors.blueGrey)),
            title: Text('${subBatch.att1}',
                style: themeData.primaryTextTheme.display1),
            // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                //Icon(Icons.linear_scale, color: Colors.yellowAccent),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.0),
                  child: Text(
                      '${subBatch.att5} - ${subBatch.att4} - ${subBatch.att2}',
                      style: themeData.primaryTextTheme.display2),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.0),
                  child: Text('$signDate',
                      style: themeData.primaryTextTheme.display2),
                ),
              ],
            ),
            //trailing:
            //Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0)
          ),
        ));
  }
}
