import 'package:flutter/material.dart';
// import "./Login/Login.dart";
import './test/test.dart';


void main() => runApp(new MyApp());

class MyApp extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Welcome to Flutter',
   
     home: new Home(),
      // routes: <String,WidgetBuilder>{
      //   "/Login":(BuildContext context) => new Login(),
      //   "/BottomNav":(BuildContext context) => new BottomNavigationWidget(),
      //   // "/BottomNav":(BuildContext context) => new BottomNavigationWidget(),
      // }, 
    );
  }
}

