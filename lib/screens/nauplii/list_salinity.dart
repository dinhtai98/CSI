import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/Data/DataUser.dart';
import 'package:flutter_helloworld/dialog/dialog_record_salinity.dart';
import 'package:flutter_helloworld/queries/nauplii.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_helloworld/utils/function.dart';
import '../../translations.dart';

class ListOfSalinity extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new ListOfSalinityState();
  }
}
class ListOfSalinityState extends State<ListOfSalinity> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  ScrollController _hideButtonController;
  var _isVisible;

  List<String> getData;
  String idSub;
  Future<List<dynamic>> _getSalinityOfSubBatch(String idSub) async{
    List<dynamic> list = List();
    http.Response response = await http.post(
        Api.urlGetDataByPost,
        headers: {
          "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
          "Content-Type": "application/x-www-form-urlencoded",
          "cache-control": "no-cache"
        },
        body: utf8.encode(Nauplii.queryGetListSalinityOfSBNauplii(idSub)),
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
      _getSalinityOfSubBatch(idSub);
    });
    return null;
  }
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = buildPrimaryThemeData(context);
    idSub = InheritedProvider.of<String>(context);

    return Scaffold(
      appBar: new AppBar(
        title: Text(Translations.of(context).text('record_salinity'),
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
            future: _getSalinityOfSubBatch(idSub),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if(snapshot.hasError){
                return ViewsWidget.buildNoInternet(context,(){
                  setState(() {
                    //memCache = AsyncMemoizer();
                    build(context);
                  });
                });
              }else if(snapshot.hasData){
                return ListView.builder(
                    padding: EdgeInsets.all(5.0),
                    shrinkWrap: true,
                    controller: _hideButtonController,
                    scrollDirection: Axis.vertical,
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) => buildSalinity(context,snapshot.data, index, )
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
            _openDialogSalinity(context);
          },
          child: new Icon(Icons.add),
        ),
      ),

    );
  }
  _openDialogSalinity(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => InheritedProvider<String>(
          child: new DialogRecordSalinity(),
          inheritedData: idSub,
        )
    ).then((onValue){
      setState(() {

      });

    });
  }
  Widget buildSalinity(BuildContext ctxt, List<dynamic> list ,int index) {
    ThemeData themeData = buildPrimaryThemeData(ctxt);
    Data salinity = Data.fromJson(list[index]);

    String startDate = function.convertDateCSDLToDateTimeDefault('${salinity.att4}'),
    completionDate = function.convertDateCSDLToDateTimeDefault('${salinity.att5}');

    return new Card(
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        margin: new EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.0),
        child: Column(
          children: <Widget>[
            ViewsWidget.buildRowDetails(context, 'initial_salinity', '${salinity.att2}'),
            ViewsWidget.buildRowDetails(context, 'targer_salinity', '${salinity.att3}'),
            ViewsWidget.buildRowDetails(context, 'start_time', '$startDate'),
            ViewsWidget.buildRowDetails(context, 'completion_time', '$completionDate'),
          ],
        )
    );
  }
}