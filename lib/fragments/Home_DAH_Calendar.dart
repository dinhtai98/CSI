import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/queries/dah.dart';
import 'package:flutter_helloworld/screens/dah/dah_detail_contract.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_helloworld/utils/function.dart';

import '../translations.dart';

class Home_DAH_Calendar extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new Home_DAH_CalendarState();
  }
}
class Home_DAH_CalendarState extends State<Home_DAH_Calendar> with TickerProviderStateMixin{
  TextStyle weekday = TextStyle(fontFamily: 'Google sans', fontSize: 12.0);
  TextStyle weekend = TextStyle(fontFamily: 'Google sans', fontSize: 12.0,color: Colors.blue[800] );
  TextStyle styleTitle = TextStyle(fontFamily: 'Google sans', fontSize: 14.0);
  TextStyle styleSelectedDate = TextStyle(fontFamily: 'Google sans', fontSize: 14.0,color: Colors.blue[800]);
  String idDAH = "", idStaff = "", idProvince = "";
  DateFormat format = new DateFormat("MM/dd/yyyy hh:mm:ss a");
  DateFormat format1 = new DateFormat("yyyy-MM-dd");
  var _selectedDay;
  AnimationController _animationController;
  var _calendarController;

  AsyncMemoizer< Map<DateTime, List> > memCache = AsyncMemoizer();

  Future<Map<DateTime, List>> _getDAHEvents(String idProvince) async{
    Map<DateTime, List> list = Map();
    return memCache.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(DAH.queryDAHEventsDate(idProvince)),
          encoding: Encoding.getByName("UTF-8")
      );
      var p = response.body.indexOf("[");
      var e = response.body.lastIndexOf("]");
      var result = response.body.substring(p, e + 1);
      var jsonData = json.decode(result);
      for (var json in jsonData) {
        Data data = Data.fromJson(json);
        list[format.parse(data.att1.toString())] = ['OK'];
      }
      return list;
    });
  }

  Future<List<dynamic>> _getDAHEventsByDate(String idProvince, String date) async{
    List<dynamic> listContract = List();

      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(DAH.queryGetAllImportContractDAHClearanceByDate(idProvince,date)),
          encoding: Encoding.getByName("UTF-8")
      );
      var p = response.body.indexOf("[");
      var e = response.body.lastIndexOf("]");
      var result = response.body.substring(p, e + 1);
      var jsonData = json.decode(result);
      for (var json in jsonData) {
        listContract.add(json);
      }
      return listContract;

  }

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _calendarController = CalendarController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    Locale myLocale = Localizations.localeOf(context);
    final data = InheritedProvider.of<Data>(context);
    print(data);
    idStaff = data.att10.toString();
    idDAH = data.att1.toString();
    idProvince = data.att11.toString();
    // TODO: implement build
    return FutureBuilder(
        future: _getDAHEvents(idProvince),
        builder: (BuildContext context, AsyncSnapshot snapshot)
        {
          if(snapshot.hasError)
          {
            return ViewsWidget.buildNoInternet(context, (){
              setState(() {
                memCache = AsyncMemoizer();
              });
            });
          }else if(snapshot.hasData){
            return  OrientationBuilder(
              builder: (context, orientation) {
                return orientation == Orientation.portrait ? Column(
                  children: <Widget>[
                    _buildTableCalendarWithBuilders(myLocale,snapshot.data),
                    const SizedBox(height: 8.0),
                    const SizedBox(height: 8.0),
                    Expanded(child: _buildEventList(format1.format(_selectedDay))),
                  ],
                ) : Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    //_buildTableCalendar(),
                    Expanded(
                      child:SingleChildScrollView(
                        child: _buildTableCalendarWithBuilders(myLocale,snapshot.data),
                      ),
                    ),
                    Expanded(child: _buildEventList(format1.format(_selectedDay))),
                  ],
                );
              },
            );
          }
          return new Center(
              child: CircularProgressIndicator()
          );
        });
  }

  void _onDaySelected(DateTime day, List events) {
    print('CALLBACK: _onDaySelected');
    setState(() {
      //memCache = AsyncMemoizer();
      _selectedDay = day;
    });
  }
  void _onVisibleDaysChanged(DateTime first, DateTime last, CalendarFormat format) {

  }
  Widget _buildTableCalendarWithBuilders(Locale local, Map<DateTime,List<dynamic>> _events) {

    return TableCalendar(
      initialSelectedDay: _selectedDay,
      rowHeight: 40.0,
      locale: '${local.languageCode}',
      calendarController: _calendarController,
      events: _events,
      initialCalendarFormat: CalendarFormat.month,
      formatAnimation: FormatAnimation.slide,
      startingDayOfWeek: StartingDayOfWeek.monday,
      availableGestures: AvailableGestures.all,
      availableCalendarFormats: const {
        CalendarFormat.month: '',
        //CalendarFormat.week: '',
      },
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekdayStyle: weekday ,
        weekendStyle: weekend,
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: weekday ,
        weekendStyle: weekend,
      ),
      headerStyle: HeaderStyle(
        titleTextStyle: styleTitle,
        centerHeaderTitle: true,
        formatButtonVisible: false,
      ),
      builders: CalendarBuilders(
        selectedDayBuilder: (context, date, _) {
          return Card(
            elevation: 0,
            color: Colors.transparent,
            shape: RoundedRectangleBorder(
                side: new BorderSide(color: Colors.blue , width: 2.0),
                borderRadius: BorderRadius.circular(50.0)),
            child: Container(
              margin: const EdgeInsets.all(2.0),
              padding: const EdgeInsets.all(5.0),
              width: 40,
              height: 40,
              child: Center(
                child: Text(
                  '${date.day}',
                  style: styleSelectedDate,
                ),
              )
            ),
          );
        },
        todayDayBuilder: (context, date, _) {
          return Card(
            elevation: 0,
            color: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0),
              side: new BorderSide(color: Colors.grey , width: 1.5)
            ),

            child: Container(
              margin: const EdgeInsets.all(2.0),
              padding: const EdgeInsets.all(5.0),
              width: 40,
              height: 40,
              child: Center(
                child: Text(
                  '${date.day}',
                  style: weekday,
                ),
              )
            ),
          );
        },
        markersBuilder: (context, date, events, holidays) {
          final children = <Widget>[];
          if (events.isNotEmpty) {
            children.add(
              Positioned(
                bottom: -1,
                child: _buildEventsMarker(date, events),
              ),
            );
          }

          return children;
        },
      ),
      onDaySelected: (date, events) {
        _onDaySelected(date, events);
        _animationController.forward(from: 0.0);
      },
      onVisibleDaysChanged: _onVisibleDaysChanged,
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return Center(
      child: Icon(Icons.bookmark,color: Colors.green[400],size: 12,),
    );
  }


  Widget _buildEventList(String date) {
    return FutureBuilder(
        future: _getDAHEventsByDate(idProvince,date),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return ViewsWidget.buildNoInternet(context, () {
              setState(() {

              });
            });
          }
          else if (snapshot.hasData) {
            return snapshot.data.length > 0 ? ListView.builder(
                padding: EdgeInsets.all(5.0),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) => buildItemEvent(context,snapshot.data, index, )
            ) : 
            Center(
              child: Text(
                Translations.of(context).text('no_events'),
                style: new TextStyle(
                  fontFamily: 'Google sans',
                  fontSize: 18.0,
                  color: Colors.black45,
                ),
              ),
            );
          }
          return new Center(
              child: CircularProgressIndicator());
        });
  }
  Widget buildItemEvent(BuildContext context, List<dynamic> list ,int index) {
    Data event = Data.fromJson(list[index]);
    String arrivalPortTime = function.convertTime24ToAPM('${event.att3}');
    //signDate = signDate.split(' ')[0];
    return new Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: new BoxDecoration(
          border: new Border(
              bottom: new BorderSide(width: 1.0, color: Color(0xff007B97))
          )
      ),
      child: ListTile(
        onTap: (){
          Navigator.of(context).push(new MaterialPageRoute<Null>(
              builder: (_) => InheritedProvider<List<String>>(
                child: new DAHDetailContract(),
                inheritedData: [event.att1, idStaff, idDAH],
              ),)).then((onValue){
            setState(() {

            });
          });
        },
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        title: Column(
          children: <Widget>[
            ViewsWidget.buildRowEvents(context,'clearance', '${event.att1}'),
          ],
        ),
        subtitle: ViewsWidget.buildRowEvents(context,'port', '${event.att4}\n$arrivalPortTime'),
        trailing: new Opacity(opacity: event.att5.toString() == "1" ? 1.0 : 0.0,
            child: Image.asset("assets/images/icontick.png",width: 25,height: 25,color: Colors.green,)
        )
      ),
    );
  }
}