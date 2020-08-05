
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_helloworld/fragments/Home_Account_Admin.dart';
import 'package:flutter_helloworld/fragments/Home_Company.dart';
import 'package:flutter_helloworld/fragments/Home_Company_Co_Quan_QL.dart';
import 'package:flutter_helloworld/fragments/Home_Tim_Viec_Fragment.dart';
import 'package:flutter_helloworld/queries/fcm.dart';
import 'package:flutter_helloworld/screens/trader/request_detail.dart';
import 'package:flutter_helloworld/style/colors.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_helloworld/Data/DataUser.dart';
import 'package:flutter_helloworld/fragments/Home_Account.dart';
import 'package:flutter_helloworld/fragments/Home_DAH_Calendar.dart';
import 'package:flutter_helloworld/fragments/Home_DARD_Calendar.dart';
import 'package:flutter_helloworld/fragments/Home_List_Hatchery.dart';
import 'package:flutter_helloworld/fragments/Home_Postlarvea_Sale_Fragment.dart';
import 'package:flutter_helloworld/fragments/Home_Nauplii_Sale_Fragment.dart';
import 'package:flutter_helloworld/fragments/Home_Producer.dart';
import 'package:flutter_helloworld/fragments/Home_Tank_Fragment.dart';
import 'package:flutter_helloworld/fragments/Home_Hatchery_Request_Fragment.dart';
import 'package:flutter_helloworld/fragments/Home_Broodstock_Import_Fragment.dart';
import 'package:flutter_helloworld/fragments/Home_Broodstock_Sale_Fragment.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/fragments/Home_Trader.dart';
import 'package:flutter_helloworld/fragments/Home_Trader_Request.dart';
import 'package:flutter_helloworld/scoped_model/home_selected_menu.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:flutter_helloworld/utils/function.dart';
import '../main.dart';
import '../navigator.dart';
import '../translations.dart';
import 'CSSX/danh_sach_khu_sx.dart';
import 'admin/danh_sach_co_quan_quan_ly.dart';
import 'admin/danh_sach_co_so_san_xuat.dart';
import 'admin/thong_ke_danh_sach_dang_ky.dart';
import 'contract/process_of_import_contract.dart';
import 'dard/dard_detail_contract.dart';
import 'hatchery/request_details.dart';

class MyHome extends StatefulWidget  {

  Data data;
  MyHome({this.data});

  @override
  State<StatefulWidget> createState() {

    return new HomePageState();
  }


}
class DrawerItem {
  String title;
  String icon;
  bool isGroup;
  bool isChild;
  dynamic body;

  DrawerItem(this.title, this.icon, this.isGroup, this.isChild, this.body);

}
class Choice {
  Choice({this.title, this.check});

  final String title;
  final int check;
}
class HomePageState extends State<MyHome> {



  TextStyle style = TextStyle(fontFamily: 'Google sans', fontSize: 20.0);

  String typeClickNotification;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Data data = new Data();
  Future<Data> getUser = DataUser.getDataUser();

  DateTime currentBackPressTime;


  int _selectedDrawerIndex = 0;
  Widget appBarTitle;
  Icon actionIcon = new Icon(Icons.search);
  var drawerItems = [];


  _filterMenu(BuildContext context){
    var tempt = [];
    String workplace = data.att1.toString();
    int typeLogin = int.parse(data.att2.toString()); //type authority
    String typeOfAccount = data.att3.toString(); //type of account
    if(typeLogin == 0){
      //DanhSachCoQuanQuanLy
      tempt = [ new DrawerItem("Thống kê đăng ký", "assets/images/statistics.png", false,false,new ThongKeDanhSachDangky()),
        new DrawerItem("Cơ quan quản lý", "assets/images/statistics.png", false,false,new DanhSachCoQuanQuanLy()),
        new DrawerItem("Cơ sở sản xuất", "assets/images/statistics.png", false,false,new DanhSachCoSoSanXuat()),
        new DrawerItem(Translations.of(context).text('account'), "assets/images/icon_menu_account.png", false,false,new HomeAccountAdmin())];
    }
    else if(typeLogin == 1 || ( workplace.contains('AUTHO') && typeLogin == 4 && typeOfAccount != "null")){
      String typeAuthority = data.att8.toString(); //Management type CQQL
      if(typeAuthority.contains("1")){
        // Tổng cục Thủy sản
      }else if(typeAuthority.contains("2")){
        // Cục thú y
        tempt = [ new DrawerItem(Translations.of(context).text('clearance'), "assets/images/icon_calendar.png", false,false,new Home_DAH_Calendar()),
          new DrawerItem(Translations.of(context).text('hatchery'), "assets/images/icon_tank.png",false,false,new HomeListHatchery())];
      }else if(typeAuthority.contains("3")){
        // Hải quan
      }else if(typeAuthority.contains("4")){
        // Cơ quan địa phương
        tempt = [ new DrawerItem(Translations.of(context).text('menu_quarantine_clear_quarantine'), "assets/images/icon_calendar.png", false,false,new HomeDARDCalendar()),
          new DrawerItem(Translations.of(context).text('hatchery'), "assets/images/icon_group_people.png",false,false,new HomeListHatchery())];
      }
    }else if(typeLogin == 2 || ( workplace.contains('HATCH') && typeLogin == 4 && typeOfAccount != "null")){
      int typeOfBusiness = int.parse(data.att8.toString());
      //int typeOfHatchery = int.parse(data.att10.toString());
      // new DrawerItem(Translations.of(context).text('menu_tank'), "assets/images/icon_tank.png", false,false,new TankFragment(data: data))

      tempt = [
        new DrawerItem(Translations.of(context).text('menu_request'), "assets/images/icon_request.png", false,false,new Home_Hatchery_Req_Fragment(data: data)),
        new DrawerItem(Translations.of(context).text('contract'),"assets/images/icon_contract.png",true,false,null),
        new DrawerItem(Translations.of(context).text('menu_import_contract'), null,false,true,new Home_Broodstock_Import_Fragment()),
        new DrawerItem(Translations.of(context).text('menu_assignment_broodstock'), null,false,true,new HomeBroodstockSaleFragment()),
        new DrawerItem(Translations.of(context).text('menu_assignment_nauplii'), null,false,true,new HomeNaupliiSaleFragment()),
        new DrawerItem(Translations.of(context).text('menu_assignment_postlarvea'), null,false,true,new HomePostlarveaSaleFragment()),
        new DrawerItem(Translations.of(context).text('producer'), "assets/images/icon_group_people.png", false,false,new Home_Producer()),
        new DrawerItem(Translations.of(context).text('trader'), "assets/images/icon_group_people.png", false,false,new Home_Trader())];
      if(typeOfBusiness < 3) {
        tempt.insertAll(7, [new DrawerItem(Translations.of(context).text('production_cluster'), "assets/images/icon_group_people.png", false,false,new DanhSachKhuSX())]);
      }
    }
    else if(typeLogin == 3){
      // Đơn vị kiểm bệnh
      // workplace.contains('AGENC')
    }else if(typeLogin == 4) {
      // Đội ngũ lao động chưa có việc làm
      // new DrawerItem('Tìm việc', "assets/images/icon_request.png", false,false,new TimViecFragment())
      tempt = [
        new DrawerItem(Translations.of(context).text('hatchery'),
            "assets/images/icon_group_people.png", false, false,
            new HomeListHatchery())
      ];
    }else if(typeLogin == 5){

    }
    /*else if(idStaff.contains("TRAST")){
      tempt = [ new DrawerItem(Translations.of(context).text('menu_request'), "assets/images/icon_request.png", false,false,new Home_Trader_Request()),
        new DrawerItem(Translations.of(context).text('hatchery'), "assets/images/icon_group_people.png",false,false,new HomeListHatchery())];
    }else if(idStaff.contains("DAHST")){
      tempt = [ new DrawerItem("Clearance", "assets/images/icon_calendar.png", false,false,new Home_DAH_Calendar()),
        new DrawerItem(Translations.of(context).text('hatchery'), "assets/images/icon_tank.png",false,false,new HomeListHatchery())];
    }else if(idStaff.contains("DARST")){
      tempt = [ new DrawerItem(Translations.of(context).text('menu_quarantine_clear_quarantine'), "assets/images/icon_calendar.png", false,false,new HomeDARDCalendar()),
        new DrawerItem(Translations.of(context).text('hatchery'), "assets/images/icon_group_people.png",false,false,new HomeListHatchery())];
    }*/
    if(typeLogin > 3){
      //CompanyDetails
      drawerItems.add(new DrawerItem(Translations.of(context).text('account'), "assets/images/icon_menu_account.png", false,false,new HomeAccount()));
    }else {
      if(typeLogin == 1){
        drawerItems.add(new DrawerItem(Translations.of(context).text('company'), "assets/images/icon_menu_account.png", false,false,new CompanyCoQuanQuanLyDetails()));
      }else if(typeLogin == 2){
        drawerItems.add(new DrawerItem(Translations.of(context).text('company'), "assets/images/icon_menu_account.png", false,false,new CompanyDetails()));
      }

    }
    drawerItems.addAll([
      new DrawerItem(Translations.of(context).text('logout'),"assets/images/logout.png", false,false,null)]);
    drawerItems.insertAll(0, tempt);
  }
  _getDrawerItemWidget(int pos) {
    return InheritedProvider<Data>(
      child: drawerItems[pos].body,
      inheritedData: data,
    );
    //return drawerItems[pos].body;
  }
  _onSelectItem(int index) async {
    if(index == drawerItems.length - 1){
      _firebaseMessaging.getToken().then((token){
        _logoutFireBaseIDTask(token);
      });
    }else {
      setState(() => _selectedDrawerIndex = index);
      selectedMenu.changeName(-1);
      selectedMenu.changeDate('');
      initial = 0;
      this.actionIcon = new Icon(Icons.search, color: Colors.white,);
      Navigator.of(context).pop();
    }// close the drawer
  }
  Map<String, List<Choice>> _mapMenu(BuildContext context){
    Map<String, List<Choice>> mapMenu = {Translations.of(context).text('menu_request'):
    [Choice(title: Translations.of(context).text('responded'), check:1),
      Choice(title: Translations.of(context).text('not_yet_responded'), check:2),
      Choice(title: Translations.of(context).text('date'), check: 3)],
      Translations.of(context).text('menu_import_contract'):
      [Choice(title: Translations.of(context).text('all'), check: 1),
        Choice(title: Translations.of(context).text('date'), check: 3)],
      Translations.of(context).text('menu_assignment_broodstock'):
      [Choice(title: Translations.of(context).text('all'), check: 1),
        Choice(title: Translations.of(context).text('date'), check: 3)],
      Translations.of(context).text('menu_assignment_nauplii'):
      [Choice(title: Translations.of(context).text('all'), check: 1),
        Choice(title: Translations.of(context).text('date'), check: 3)],
      Translations.of(context).text('menu_assignment_postlarvea'):
      [Choice(title: Translations.of(context).text('all'), check: 1),
        Choice(title: Translations.of(context).text('date'), check: 3)],
      Translations.of(context).text('hatchery'): null};

    return mapMenu;
  }
  PopupMenu selectedMenu = new PopupMenu();
  Choice _selectedChoice ;
  _select(Choice choice) {

    // Causes the app to rebuild with the new _selectedChoice.
    setState(() {
      _selectedChoice = choice;

    });
    if(_selectedChoice.check < 3){
      selectedMenu.changeName(choice.check);
      selectedMenu.changeDate('');
    }
    if(_selectedChoice.check == 3){
      TextEditingController dateController = new TextEditingController();
      Locale myLocale = Localizations.localeOf(context);
      DatePicker.showDatePicker(context,
          showTitleActions: true, onChanged: (date) {
            //print('change $date');
          }, onConfirm: (date) {
            dateController.text = '${function.formatDateCSDL(date)}';
            selectedMenu.changeName(choice.check);
            selectedMenu.changeDate(dateController.text.toString());
          }, currentTime: DateTime.now(), locale: myLocale.languageCode == 'en' ? LocaleType.en : LocaleType.vi);
    }
  }

  Future showNotificationForeGround(String type, String from, String idData) async {

    var initializationSettingsAndroid =
    new AndroidInitializationSettings('logo_csiro');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onClickNotification);

    if (Platform.isIOS) iOS_Permission();

    String title, content;
    typeClickNotification = type;
    switch(type){
      case "request":
        title = Translations.of(context).text('request');
        content = Translations.of(context).text('you_have_request_from') + " " + from;
        break;
      case "response":
        title = Translations.of(context).text('response');
        content = Translations.of(context).text('you_have_request_from') + " " + from;
        break;
      case "dard_quarantine":
        title = Translations.of(context).text('requesting_quarantine');
        dynamic tempt = from.split("-");
        content = Translations.of(context).text('time_of_broodstock_to_hatchery') + " " + tempt[0] + ": " + tempt[1];
        break;
      case "reminder":
        title = Translations.of(context).text('remider');
        content = Translations.of(context).text('make_report');
        break;
    }

    var vibrationPattern = new Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 5000;
    vibrationPattern[3] = 2000;

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        new Random().nextInt(1000).toString(), 'vn', '',
        importance: Importance.Max, priority: Priority.High,enableVibration: true,
        playSound: true,color: kColorBackground,vibrationPattern: vibrationPattern,
        ongoing: true,enableLights: true);

    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      new Random().nextInt(1000),
      title,
      content,
      platformChannelSpecifics,
      payload: idData,
    );
  }
  Future onClickNotification(String idData) async {
    switch(typeClickNotification){
      case "request":
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TraderRequestDetails(idData),
            ));
        break;
      case "response":
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HatcheryRequestDetails(idData),
            ));
        break;
        /*
      case "create_contract":
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProcessImportContract(idContract: idData),
            ));
        break;

         */
      case "dard_quarantine":
        Navigator.of(context).push(new MaterialPageRoute<Null>(
          builder: (_) => InheritedProvider<String>(
            child: new DARDDetailContract(),
            inheritedData: idData,
          ),
        ));
        break;
        /*
      case "reminder":
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProcessImportContract(idContract: idData),
            ));
        break;

         */
    }

  }
  void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true)
    );
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings)
    {
      print("Settings registered: $settings");
    });
  }
  @override
  void initState(){
    super.initState();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
        Map<dynamic, dynamic> mapMessage = message['data'];
        showNotificationForeGround(mapMessage['data_type'],mapMessage['data_from'],mapMessage['data_id']);
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
        Map<dynamic, dynamic> mapMessage = message['data'];
        _navigateToScreen(mapMessage['data_type'],mapMessage['data_id']);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
        Map<dynamic, dynamic> mapMessage = message['data'];
        _navigateToScreen(mapMessage['data_type'],mapMessage['data_id']);
      },
    );
    selectedMenu = new PopupMenu();
    _selectedChoice = new Choice();
    getUser.then((onValue){
      setState(() {
        data = onValue;
      });
    });
  }
  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Toast.show(Translations.of(context).text('please_click_back_again'), context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      return Future.value(false);
    }
    return Future.value(true);
  }

  Timer searchOnStoppedTyping;
  _onChangeHandler(value) {
    const duration = Duration(milliseconds:500); // set the duration that you want call search() after that.
    if (searchOnStoppedTyping != null) {
      setState(() => searchOnStoppedTyping.cancel()); // clear timer
    }
    setState(() => searchOnStoppedTyping = new Timer(duration, () => selectedMenu.changeDate(value)));
  }

  String initialLocal = "";
  int initial = 0;
  @override
  Widget build(BuildContext ctx) {
    /* use this emergency logout when data error
    void logout() async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('user', null);
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext ctx) => MyLoginPage()));
    }

    logout();
    */
    //context = NavigatorStateFromKeyOrContext.of(context).context;
    Locale myLocale = Localizations.localeOf(context);
    if(myLocale.languageCode != initialLocal){
      initial = 0;
    }
    var drawerOptions = <Widget>[];
    if(initial == 0 && data.att2 != null){
      initialLocal = myLocale.languageCode;
      drawerItems.clear();
      _filterMenu(context);
      initial = 1;
      appBarTitle = new Text(drawerItems[_selectedDrawerIndex].title, style: style);
    }
    for (var i = 0; i < drawerItems.length; i++) {
      var x =drawerItems[i];
      if(x.isGroup){
        var a = drawerItems[i+1];
        var b = drawerItems[i+2];
        var c = drawerItems[i+3];
        var d = drawerItems[i+4];
        drawerOptions.add(
            Theme(data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child:ExpansionTile(
                  leading: Image.asset("assets/images/icon_contract.png", width: 30,height: 30,color: Colors.grey),
                  title: Text(x.title),
                  children: <Widget>[
                    new ListTile(
                      title: Padding(
                        padding: EdgeInsets.only(left: 55.0),
                        child: new Text(a.title),
                      ),
                      selected: (i + 1) == (_selectedDrawerIndex),
                      onTap: () => _onSelectItem(i + 1),
                    ),
                    new ListTile(
                      title: Padding(
                        padding: EdgeInsets.only(left: 55.0),
                        child: new Text(b.title),
                      ),
                      selected: i + 2 == _selectedDrawerIndex,
                      onTap: () => _onSelectItem(i + 2),
                    ),
                    new ListTile(
                      title: Padding(
                        padding: EdgeInsets.only(left: 55.0),
                        child: new Text(c.title),
                      ),
                      selected: i + 3 == _selectedDrawerIndex,
                      onTap: () => _onSelectItem(i + 3),
                    ),
                    new ListTile(
                      title: Padding(
                        padding: EdgeInsets.only(left: 55.0),
                        child: new Text(d.title),
                      ),
                      selected: i + 4 == _selectedDrawerIndex,
                      onTap: () => _onSelectItem(i + 4),
                    ),
                  ],
                ))

        );
        //print("ii = $i");
        //i += 4;
      }else if(!x.isChild){
        drawerOptions.add(
            new ListTile(
              leading: Image.asset("${x.icon}", width: 30,height: 30,color: Colors.grey),
              title: new Text(x.title),
              selected: i == _selectedDrawerIndex,
              onTap: () => _onSelectItem(i),
            )
        );
      }
    }

    return ScopedModel<PopupMenu>(
        model: selectedMenu,
        child: new WillPopScope(
            onWillPop: onWillPop,
            child: ScopedModelDescendant<PopupMenu>(
              builder: (context, child, model) {
                return new Scaffold(
                  appBar: new AppBar(
                    centerTitle: true,
                    flexibleSpace: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF2db7d1), Color(0xff55ceb1)],
                        ),
                      )
                    ),
                    actions: <Widget>[
                      Visibility(
                        child: new IconButton(icon: actionIcon, onPressed: () {
                          setState(() {
                            if (this.actionIcon.icon == Icons.search) {
                              this.actionIcon = new Icon(Icons.close, color: Colors.white,);
                              this.appBarTitle = new TextField(
                                autofocus: true,
                                onChanged: _onChangeHandler,
                                style: new TextStyle(
                                  color: Colors.white,
                                ),
                                decoration: new InputDecoration(
                                  hintText: "Search...",
                                  hintStyle: new TextStyle(color: Colors.white),
                                  border: InputBorder.none,
                                ),
                              );
                            }
                            else {
                              setState(() {
                                selectedMenu.changeDate('');
                              });
                              this.actionIcon = new Icon(Icons.search, color: Colors.white,);
                              this.appBarTitle = new Text(drawerItems[_selectedDrawerIndex].title, style: style);
                            }
                          });
                        },),
                        visible: drawerItems.length > 0 &&_mapMenu(context).containsKey(drawerItems[_selectedDrawerIndex].title) &&
                            _mapMenu(context)[drawerItems[_selectedDrawerIndex].title] == null,
                      ),
                      drawerItems.length > 0 && _mapMenu(context).containsKey(drawerItems[_selectedDrawerIndex].title) &&
                          _mapMenu(context)[drawerItems[_selectedDrawerIndex].title] != null ?
                      PopupMenuButton<Choice>(
                        onSelected: _select,
                        itemBuilder: (BuildContext context) {
                          return _mapMenu(context)[drawerItems[_selectedDrawerIndex].title].map((Choice choice) {
                            return PopupMenuItem<Choice>(
                              value: choice,
                              child: Text(choice.title),
                            );
                          }).toList();
                        },
                      ) : Text('')
                    ],
                    title: appBarTitle,
                  ),
                  drawer: new Drawer(
                    child: new ListView(
                      children: <Widget>[
                        new Container(
                          child: new Column(
                            children: [
                              new DrawerHeader(
                                child: CircleAvatar(
                                  child: ClipOval(
                                    child: Image.asset("assets/images/admin_image.png", width: 130, height: 130, fit: BoxFit.cover)
                                  ),
                                  radius: 80.0,
                                  backgroundColor: Colors.yellow[300],
                                ),
                              ),
                              new Container(
                                child: new Text("${data.att6}"),
                                padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                              ),
                            ],
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF2db7d1), Color(0xff55ceb1)],
                            ),
                          ),
                        ),
                        new SingleChildScrollView(
                          child: new Column(children: drawerOptions),
                        )
                      ],
                    ),
                  ),
                  body: drawerOptions.length > 0 ?_getDrawerItemWidget(_selectedDrawerIndex) : new Center(
                      child: CircularProgressIndicator()),
                      backgroundColor: Color(0xFFF5F5F5),
                );
              },
            )
        )
    );
  }
  /*_saveFireBaseIDTask(String idToken, String group) async {

    http.Response response = await http.post(
        Api.url_update,
        headers: {
          "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
          "Content-Type": "application/x-www-form-urlencoded",
          "cache-control": "no-cache"
        },
        body: utf8.encode(FCM.saveToken(idToken, group)),
        encoding: Encoding.getByName("UTF-8")
    );
    print('query ${FCM.saveToken(idToken, group)}');
    var p = response.body.indexOf(">");
    var e = response.body.lastIndexOf("<");
    var result = response.body.substring(p + 1, e);
    if (result.contains("1")) {
      print('SAVED TOKEN');
    } else {
      print('SAVED TOKEN ERROR !!!!!!!');
    }
  }*/
  _logoutFireBaseIDTask(String idToken) async {
    ProgressDialog pr;
    pr = new ProgressDialog(context,type: ProgressDialogType.Normal);
    pr.style(
      message: Translations.of(context).text('please_wait'),
    );
    pr.show();
    http.Response response = await http.post(
        Api.url_update,
        headers: {
          "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
          "Content-Type": "application/x-www-form-urlencoded",
          "cache-control": "no-cache"
        },
        body: utf8.encode(FCM.notUseToken(idToken)),
        encoding: Encoding.getByName("UTF-8")
    );
    var p = response.body.indexOf(">");
    var e = response.body.lastIndexOf("<");
    var result = response.body.substring(p + 1, e);
    print(result);
    if (result.contains("1")) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('user', null);
        //_removeUser();
        Future.delayed(Duration(seconds: 2)).then((value) {
          pr.hide().whenComplete((){
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (BuildContext ctx) => MyLoginPage()));
        });
      });

    } else {
      Future.delayed(Duration(seconds: 2)).then((value) {
        pr.hide().whenComplete((){
          Toast.show(Translations.of(context).text('error'), context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        });
      });
    }
  }
  /*_removeUser() async {
    final storage = new FlutterSecureStorage();
    await storage.delete(key: 'user');

  }*/
  _navigateToScreen(String type ,String idData) {
    switch(type){
      case "request":
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TraderRequestDetails(idData),
            ));
        break;
      case "response":
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HatcheryRequestDetails(idData),
            ));
        break;
        /*
      case "create_contract":
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProcessImportContract(idContract: idData),
            ));
        break;

         */
      case "dard_quarantine":
        Navigator.of(context).push(new MaterialPageRoute<Null>(
          builder: (_) => InheritedProvider<String>(
            child: new DARDDetailContract(),
            inheritedData: idData,
          ),
        ));
        break;
        /*
      case "reminder":
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProcessImportContract(idContract: idData),
            ));
        break;

         */
    }
  }
}
