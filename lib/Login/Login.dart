import 'package:flutter/material.dart';
import '../bottomNav/BottomNav.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Bootup/Bootup.dart';

class Logins extends StatefulWidget {
  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Logins> {
  bool Login = false;

//验证登录
void isLogin() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
print("这个是地址1"+prefs.getString("address").isEmpty.toString());
print("123"+prefs.getString("address").toString());
  if(prefs.getString("address").isEmpty){
setState(() {
  Login = false;
});
  }else{
setState(() {
  Login = true;
});
  }
}
@override
void initState() {
    super.initState();
    
  isLogin();
  }
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme:new ThemeData(
        
        // accentColor:const Color.fromRGBO(241, 243, 244, 1),
        primaryColor: const Color.fromRGBO(241, 243, 244, 1),
      ),
      home: Login ? BottomNavigationWidget() : BootupPage(),
      //注册路由表 
      routes: <String,WidgetBuilder>{
        // "/StartCreact":(BuildContext context) => new StartCreact(),
        // "/Creact":(BuildContext context) => new creact(),
        // "/Import":(BuildContext context) => new importWord(),
        "/BottomNav":(BuildContext context) => new BottomNavigationWidget(),

      }, 

    );
  }
}