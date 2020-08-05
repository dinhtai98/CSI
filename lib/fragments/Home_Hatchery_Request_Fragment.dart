import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/dialog/dialog_hatchery_create_new_request.dart';
import 'package:flutter_helloworld/queries/request.dart';
import 'package:flutter_helloworld/scoped_model/home_selected_menu.dart';
import 'package:flutter_helloworld/screens/hatchery/request_details.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/translations.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_helloworld/utils/function.dart';
import 'package:scoped_model/scoped_model.dart';
import '../Data/ConvertQueryResult.dart';
import 'package:postgres/postgres.dart';
import '../navigator.dart';

class Home_Hatchery_Req_Fragment extends StatefulWidget {
  final Data data;
  Home_Hatchery_Req_Fragment({this.data});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new Home_Hatchery_Req_FragmentState();
  }
}
class Home_Hatchery_Req_FragmentState extends State<Home_Hatchery_Req_Fragment> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  Data data;

  ScrollController _hideButtonController;
  var _isVisible;
  AsyncMemoizer<List<dynamic>> memCache = AsyncMemoizer();
  _getAllRequestOfHatchery(String idHatchery,int check, String date) async{
    List<dynamic> listReq = new List();
    List<List<Map<String, dynamic>>> list = new List();
    return memCache.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(check == 3 ?
          Request.queryGetAllRequestsOfHatcheryFilterDate(idHatchery,date):
          Request.query_GetAllRequestsOfHatchery(idHatchery,check)),
          encoding: Encoding.getByName("UTF-8")
      );
      print(response.body);
      var p = response.body.indexOf("[");
      var e = response.body.lastIndexOf("]");
      var result = response.body.substring(p,e + 1);
      listReq = json.decode(result);
      return listReq;
    });

  }
  _scrollListener() {
    if (_hideButtonController.offset >= _hideButtonController.position.maxScrollExtent) {
      if(_isVisible == true) {
        /* only set when the previous state is false
             * Less widget rebuilds
             */
        print("**** ${_isVisible} up"); //Move IO away from setState
        setState((){
          _isVisible = false;
        });
      }
    }
    if (_hideButtonController.offset <= _hideButtonController.position.minScrollExtent ||
        _hideButtonController.position.userScrollDirection == ScrollDirection.forward) {
      if(_isVisible == false) {
        /* only set when the previous state is false
               * Less widget rebuilds
               */
        print("**** ${_isVisible} down"); //Move IO away from setState
        setState((){
          _isVisible = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _isVisible = true;
    _hideButtonController = new ScrollController();
    _hideButtonController.addListener(_scrollListener);
    Future.delayed(Duration(milliseconds: 200)).then((_) {
      _refreshIndicatorKey.currentState?.show();
    });
    /*_hideButtonController.addListener((){
      if(_hideButtonController.position.userScrollDirection == ScrollDirection.reverse){
        if(_isVisible == true) {
          setState((){
            _isVisible = false;
          });
        }
      } else {
        if(_hideButtonController.position.userScrollDirection == ScrollDirection.forward){
          if(_isVisible == false) {
            setState((){
              _isVisible = true;
            });
          }
        }
      }});*/
  }
  Future<Null> _handleRefresh() async {
    await new Future.delayed(new Duration(milliseconds: 200));
    setState(() {
      memCache = AsyncMemoizer();
    });
    return null;
  }
  int check = -1;
  String date = '';
  @override
  Widget build(BuildContext context) {
    data = InheritedProvider.of<Data>(context);
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
              future: _getAllRequestOfHatchery(data.att1,model.name,model.selectedDate),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if(snapshot.hasError){
                  return ViewsWidget.buildNoInternet(context,(){
                    setState(() {
                      memCache = AsyncMemoizer();
                    });
                  });
                }else if(snapshot.hasData){
                  return snapshot.data.length > 0 ? ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(5.0),
                      controller: _hideButtonController,
                      scrollDirection: Axis.vertical,
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) => buildItemRequest(context,snapshot.data, index)
                  ) :
                  ViewsWidget.buildNoResultSearch(context);
                }
                return ViewsWidget.buildPleaseWait();
              }
          );
        },
      ),
      floatingActionButton: new Visibility(
        visible: _isVisible,
        child: new FloatingActionButton(
          onPressed: () {
            openDialog();
          },
          tooltip: Translations.of(context).text('create_new_request'),
          child: new Icon(Icons.add),
        ),
      ),

    );
  }
  void openDialog() {
    Navigator.of(context).push(new MaterialPageRoute<Null>(
        builder: (_) => InheritedProvider<Data>(
          child: new DialogHatcheryCreateRequest(),
          inheritedData: data,
        ))).then((onValue){
      setState(() {
        memCache = AsyncMemoizer();
      });
    });
  }
  Widget buildItemRequest(BuildContext ctxt, List<dynamic> list,int index) {
    ThemeData themeData = buildPrimaryThemeData(ctxt);
    Data request = Data.fromJson(list[index]);
    String reqDate = request.att4;
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
                MaterialPageRoute(builder: (context) => HatcheryRequestDetails(request.att1)),
              );
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                //Icon(Icons.linear_scale, color: Colors.yellowAccent),
                Text('${request.att3}', style: themeData.primaryTextTheme.display2),
                Text('$reqDate', style: themeData.primaryTextTheme.display2)
              ],
            ),
            //trailing:
            //Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0)
        ),
      )
    );
  }
}
