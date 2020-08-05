import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/screens/login/menu_login.dart';
import 'package:flutter_helloworld/screens/signup/menu_signup.dart';
import 'package:flutter_helloworld/style/colors.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path/path.dart' as prefix0;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import './screens/home_screen.dart';
import 'dart:convert';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'navigator.dart';
import 'translations.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import './queries/hatchery.dart';
import './queries/trader.dart';
import './queries/dard.dart';
import './queries/dah.dart';
import './utils/api.dart';
import './utils/function.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'Data/Data.dart';

Widget widgetInit() {
  return MaterialApp(debugShowCheckedModeBanner: false, home: new FutureBuilder<dynamic>(
    future: loadDataUser(), // a Future<String> or null
    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
      switch (snapshot.connectionState) {
        case ConnectionState.done: return MyApp(user: snapshot.data,);
        case ConnectionState.waiting: return new Text('Awaiting result...');
        default:
          if (snapshot.hasError)
            return new Text('Error: ${snapshot.error}');
          else
            return new Text('Result: ${snapshot.data}');
      }
    },
  ));
  return MaterialApp(debugShowCheckedModeBanner: false, home: FutureBuilder<dynamic>(
    future: loadDataUser(),
    builder: (buildContext, snapshot) {
      print(' hasData ${snapshot.hasData}');
      print('data ${snapshot.data}');
      if (snapshot.hasData) {
        return MyApp(user: snapshot.data,);
      }
      return SplashScreen(user: snapshot.data,);

    },
  ));
}
Future<String> loadDataUser() async {
  var sharedPreferences = await SharedPreferences.getInstance();
  var user = sharedPreferences.getString('user');
  return user;
}
/*_loadDataUser() async {
  final storage = new FlutterSecureStorage();
  String user = await storage.read(key: 'user');
  print('user aaa $user');
  return user;
}*/
void main() async {
  //String user = _loadDataUser();
  final GlobalKey navigator = GlobalKey<NavigatorState>(debugLabel: 'AppNavigator');
  WidgetsFlutterBinding.ensureInitialized();
  //SharedPreferences preferences = await SharedPreferences.getInstance();
  //String user = preferences.getString('user');
  runApp(
    NavigatorStateFromKeyOrContext(
      navigatorKey: navigator,
      child: widgetInit(),
    ),
  );
  //runApp(widgetInit());
}

class MyApp extends StatelessWidget {
  String user;
  MyApp({this.user});
  @override
  Widget build(BuildContext context) {
    print('userrr $user');
    return new MaterialApp(
      navigatorKey: NavigatorStateFromKeyOrContext.getKey(context),
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      supportedLocales: [
        const Locale('vi', 'VI'),
        const Locale('en', 'US')
      ],
      localizationsDelegates: [
        const TranslationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      localeResolutionCallback: (Locale locale, Iterable<Locale> supportedLocales) {
        if (locale == null) {
          //debugPrint("*language locale is null!!!");
          return supportedLocales.first;
        }
        for (Locale supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode || supportedLocale.countryCode == locale.countryCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      home: user == null ? MyLoginPage() : MyHome(),
    );
  }
}

class MyLoginPage extends StatefulWidget {
  MyLoginPage({Key key, this.title}) : super(key: key);

  final String title;


  @override
  _MyLoginPageState createState() => new _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {

  @override
  Widget build(BuildContext context) {
    double heightScreen = MediaQuery.of(context).size.height;
    ThemeData themeData = buildPrimaryThemeData(context);
    final loginButton = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2db7d1), Color(0xff55ceb1)],
        ),
          color: Color(0xFF00bfa5),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF007272),
              offset: const Offset(3.0, 3.0),
              blurRadius: 3.0,
              spreadRadius: 2.0,
            )
          ]
      ),
      //margin: EdgeInsets.all(5),
      child: MaterialButton(

          minWidth: MediaQuery.of(context).size.width / 1.5,
          padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => MenuLogin()));
          },
          child: Text(Translations.of(context).text('login'),
              textAlign: TextAlign.center,
              style: themeData.primaryTextTheme.button
          )
      ),
    );
    final signupButton = Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2db7d1), Color(0xff55ceb1)],
          ),
          color: Color(0xFF00bfa5),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF007272),
              offset: const Offset(3.0, 3.0),
              blurRadius: 3.0,
              spreadRadius: 2.0,
            )
          ]
      ),
      //margin: EdgeInsets.all(5),
      child: MaterialButton(

          minWidth: MediaQuery.of(context).size.width / 1.5,
          padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => MenuSignup()));
          },
          child: Text(Translations.of(context).text('signup'),
              textAlign: TextAlign.center,
              style: themeData.primaryTextTheme.button
          )
      ),
    );
    return SingleChildScrollView(
      child: Material(
        child: Container(
          color: kColorBackground,
          alignment: Alignment.center,
          padding: const EdgeInsets.fromLTRB(10, 50, 10, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(text: 'CSI: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22,color: Color(0xFFFFFF39))),
                    TextSpan(text: 'HỆ THỐNG QUẢN LÝ\nCHẤT LƯỢNG & NGUỒN GỐC\nTÔM GIỐNG',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22,color: Colors.white)),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Image.asset("assets/images/logo_csiro.png",fit: BoxFit.cover,
                  width: 150,height: 150,),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Text('created by\nCommonwealth Scientific & Industrial Research\nOrganization of Australia'
                  ,style:TextStyle(fontSize: 12,fontStyle: FontStyle.italic,color: Colors.grey[200]),textAlign: TextAlign.center,),
              ),
              Padding(
                padding: EdgeInsets.all(5),
                child: loginButton,
              ),
              Padding(
                padding: EdgeInsets.all(5),
                child: signupButton,
              ),
              SizedBox(height: 150.0),
              Text("Exclusively licensed to\nDirectorate of Fisheries of Vietnam\nAll rights reserved @ CSIRO",
                style:TextStyle(fontSize: 12,fontStyle: FontStyle.italic,color: Colors.grey[200]),textAlign: TextAlign.center,),
            ],
          ),
        ),
      )
    );
  }
}

class SplashScreen extends StatefulWidget {
  String user;
  SplashScreen({this.user});

  @override
  SplashScreenState createState() => new SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    new Future.delayed(
        const Duration(seconds: 3),
            () => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (BuildContext ctx) => MyApp()),
        ));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Image.asset(
                'assets/images/logo_csiro.png',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

