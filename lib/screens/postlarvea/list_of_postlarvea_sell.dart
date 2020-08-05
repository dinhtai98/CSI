import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/Data/DataUser.dart';
import 'package:flutter_helloworld/dialog/dialog_hatchery_broodstock_sell.dart';
import 'package:flutter_helloworld/queries/contract.dart';
import 'package:flutter_helloworld/queries/postlarvea.dart';
import 'package:flutter_helloworld/style/colors.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_helloworld/utils/function.dart';
import '../../translations.dart';
import 'detail_postlarvea_contract_sell.dart';
import 'dialog_postlarvea_sell.dart';

class ListOfPostlarveaSell extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new ListOfPostlarveaSellState();
  }
}
class ListOfPostlarveaSellState extends State<ListOfPostlarveaSell> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  ScrollController _hideButtonController;
  var _isVisible;

  Future<Data> getUser = DataUser.getDataUser();
  String idHatchery = "";
  List<String> getData;
  String idSub,idPrepostlarvea,stage;

  //AsyncMemoizer<List<dynamic>> memCache = AsyncMemoizer();
  Future<List<dynamic>> _getListSellOfPostlarvea(String idPrepostlarvea, String idSender) async{
    List<dynamic> list = List();
    http.Response response = await http.post(
        Api.urlGetDataByPost,
        headers: {
          "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
          "Content-Type": "application/x-www-form-urlencoded",
          "cache-control": "no-cache"
        },
        body: utf8.encode(Postlarvea.queryGetListPostlarveaSell(idPrepostlarvea,idSender)),
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

    //return memCache.runOnce(() async {
    //});
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
    getUser.then((onValue){
      setState(() {
        idHatchery = onValue.att1.toString();
        //idStaff = onValue.att1;
      });

    });

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
    });
    return null;
  }
  int initial = 0;
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = buildPrimaryThemeData(context);
    getData = InheritedProvider.of<List<String>>(context);
    if(initial == 0){
      idSub = getData[0];
      idPrepostlarvea = getData[1];
      stage = getData[2];
      initial = 1;
    }


    return Scaffold(
      appBar: new AppBar(
        title: Text(Translations.of(context).text('record_sell'),
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
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _handleRefresh,
        child:  FutureBuilder(
            future: _getListSellOfPostlarvea(idPrepostlarvea, idHatchery),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if(snapshot.hasError){
                return ViewsWidget.buildNoInternet(context,(){
                  setState(() {
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
                    itemBuilder: (BuildContext context, int index) => buildSell(context,snapshot.data, index, )
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

    Navigator.of(context).push(new MaterialPageRoute<Null>(
        builder: (_) => InheritedProvider<List<String>>(
          child: new DialogPostlarveaSell(),
          inheritedData: getData,
        ),
        fullscreenDialog: true)).then((onValue){
      setState(() {
      });
    });
  }
  Widget buildSell(BuildContext ctxt, List<dynamic> list ,int index) {
    ThemeData themeData = buildPrimaryThemeData(ctxt);
    Data contract = Data.fromJson(list[index]);

    String signDate = function.convertDateCSDLToDateTimeDefault('${contract.att4}');
    signDate = signDate.split(' ')[0];
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
            onTap: (){
              Navigator.of(context).push(new MaterialPageRoute<Null>(
                  builder: (_) =>
                      InheritedProvider<String>(
                        child:  new PostlarveaContractSell() ,
                        inheritedData: contract.att1,
                      ))).then((onValue) {
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
                child: Image.asset("assets/images/icon_contract.png", width: 30,height: 30,color: Colors.blueGrey)
            ),
            title: Text(
                '${contract.att1}',
                style: themeData.primaryTextTheme.display1
            ),
            // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                //Icon(Icons.linear_scale, color: Colors.yellowAccent),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.0),
                  child: Text('${contract.att5} (${contract.att6.toString() != "null" ?
                      Translations.of(context).text('hatchery') : Translations.of(context).text('farmer')})',
                      style: themeData.primaryTextTheme.display2),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.0),
                  child: Text('$signDate', style: themeData.primaryTextTheme.display2),
                ),


              ],
            ),
            //trailing:
            //Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0)
          ),
        ));
  }
}