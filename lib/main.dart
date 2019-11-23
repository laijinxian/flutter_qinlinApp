// Create an infinite scrolling lazily loaded list

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';

import 'widgets/OpenDoor.dart';
import 'widgets/Login.dart';

void main() => runApp(new MyApp());

class Router {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BotToastInit(
      child:MaterialApp(
         navigatorKey: Router.navigatorKey, 
          navigatorObservers: [BotToastNavigatorObserver()],
          home: MyHomePage(),
          theme: new ThemeData(
            primarySwatch: Colors.red,
          ),
          routes: {
            'login': (context) => Login(),
            'openDoor': (context) => OpenDoor()
          }
      )
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  MyHomePage({Key key, this.title}) : super(key: key);
  @override
  _MyHomePage createState() => new _MyHomePage();
}

class _MyHomePage extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OpenDoor(),
    );
  }
}